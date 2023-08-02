package buildstagetests

import (
	"log"
	"os"
	"os/exec"
	"testing"

	. "github.com/Kiwibank/kb-go-modules/tfquality"
	"github.com/stretchr/testify/require"
)

var rd = os.Getenv("CICD_TEST_RESULT_DIR_JUNITXML")
var sd = os.Getenv("SOURCE_DIRECTORY")
var ttr = os.Getenv("TFC_TEAM_TOKEN")

func init() {
	log.Print("Starting test suite setup")
	c := exec.Command(sd + "/test/build/tfquality/tflintRunner.sh")
	err := c.Run()
	if err != nil {
		log.Fatal(err)
	}
	log.Print("Test suite setup complete")
}

//func TestTfInit(t *testing.T) {
//	require.True(t, AreAllWorkspacesInitialisedSuccessfully(t, sd+"/"+rd))
//}
//
//func TestTfValidate(t *testing.T) {
//	require.True(t, AreConfigurationsValid(sd+"/"+rd, getIgnoredDiagnostics))
//}

func TestTfLint(t *testing.T) {
	r, err := AreJUnitFailsPresentByFileSuffix(sd+"/"+rd, "_lint.xml")
	if err != nil {
		t.Fatal(err.Error())
	}
	require.False(t, r)
}

func TestTfSec(t *testing.T) {
	r, err := AreJUnitFailsPresentByFileSuffix(sd+"/"+rd, "_TFSec.xml")
	if err != nil {
		t.Fatal(err.Error())
	}
	require.False(t, r)
}

func TestTfFmt(t *testing.T) {
	sd := os.Getenv("SOURCE_DIRECTORY")
	ttr := os.Getenv("TFC_TEAM_TOKEN")

	c := exec.Command("terraform", "fmt", "-no-color", "-recursive", "-check", "-diff")
	if RunCommand(t, sd, ttr, c) != 0 {
		t.Fatal()
	}
}
