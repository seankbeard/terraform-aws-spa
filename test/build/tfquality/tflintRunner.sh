#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

resultsPath="${SOURCE_DIRECTORY}/${CICD_TEST_RESULT_DIR_JUNITXML}"
echo "Results Path = $resultsPath"

function initWorkspaces {
  dirBase=$(basename "$1")
  resultsPath="$2"
  echo "Changing to $1" >>"$resultsPath/tfInit.log"
  cd "$1" || echo "Unable to change to directory $1" >>"$resultsPath/tfInit.log"
  echo "now in $(pwd)" >>"$resultsPath/tfInit.log"

  echo "Starting Terraform init $1..." >>"$resultsPath/tfInit.log"
  terraform init -no-color >"$resultsPath/${dirBase}_init.log" 2>&1
  echo "Terraform init $1 returned $?" >>"$resultsPath/tfInit.log"

  echo "Starting Terraform validate $1..." >>"$resultsPath/tfInit.log"
  terraform validate -json -no-color >"$resultsPath/${dirBase}_validate.json" 2>&1
  echo "Terraform validate $1 returned $?" >>"$resultsPath/tfInit.log"
}
export -f initWorkspaces

function lintWorkspaces {
  dirBase=$(basename "$1")
  resultsPath="$2"
  echo "Changing to $1" >>"$resultsPath/tfLint.log"
  cd "$1" || echo "Unable to change to directory $1" >>"$resultsPath/tfLint.log"
  echo "now in $(pwd)" >>"$resultsPath/tfLint.log"

  echo "Starting Terraform lint $1..." >>"$resultsPath/tfLint.log"
  tflint --config="${SOURCE_DIRECTORY}/test/build/tfquality/tflintConfig.hcl" -f junit \
    >"${SOURCE_DIRECTORY}/${CICD_TEST_RESULT_DIR_JUNITXML}/${dirBase}_lint.xml" 2>&1
  echo "Terraform lint $1 returned $?" >>"$resultsPath/tfLint.log"
}
export -f lintWorkspaces

function tfSecWorkspaces {
  dirBase=$(basename "$1")
  resultsPath="$2"
  echo "Changing to $1" >>"$resultsPath/TFSec.log"
  cd "$1" || echo "Unable to change to directory $1" >>"$resultsPath/TFSec.log"
  echo "now in $(pwd)" >>"$resultsPath/TFSec.log"

  echo "Starting TFSec $1..." >>"$resultsPath/TFSec.log"
  tfsec --format junit \
    --minimum-severity HIGH \
    --no-colour \
    --no-module-downloads \
    --exclude aws-ec2-no-public-egress-sgr \
    --out "${SOURCE_DIRECTORY}/${CICD_TEST_RESULT_DIR_JUNITXML}/${dirBase}_TFSec.xml" 2>&1
  echo "TFSec $1 returned $?" >>"$resultsPath/TFSec.log"
}
export -f tfSecWorkspaces

tflint --config="${SOURCE_DIRECTORY}/test/build/tfquality/tflintConfig.hcl" --init >>"$resultsPath/tflintInit.log"

#files=$(find "$SOURCE_DIRECTORY" \
#  -name "*.tf" \
#  -not -path '*.terraform*' \
#  -not -path '*/overrides/*' \
#  -not -path '*/modules/*' \
#  -exec dirname {} \; |
#  sort |
#  uniq |
#  xargs realpath)
#echo "running Init checks on $files" >>"$resultsPath/tfInit.log"
## shellcheck disable=SC2046
#parallel initWorkspaces {} "$resultsPath" ::: "$files"

files=$(find "$SOURCE_DIRECTORY" \
  -name "*.tf" \
  -not -path '*.terraform*' \
  -not -path '*/overrides/*' \
  -exec dirname {} \; |
  sort |
  uniq |
  xargs realpath)
echo "running Lint checks on $files" >>"$resultsPath/tfLint.log"
parallel lintWorkspaces {} "$resultsPath" ::: "$files"
parallel tfSecWorkspaces {} "$resultsPath" ::: "$files"
wait
