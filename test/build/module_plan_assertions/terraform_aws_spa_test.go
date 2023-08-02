package buildstagetests

import (
	"encoding/json"
	"testing"

	"github.com/Kiwibank/kb-tf-terraunit/terraunit"

	. "github.com/Kiwibank/kb-go-modules/terraunit_helpers"
	"github.com/stretchr/testify/suite"
)

const (
	infraModulePath = "./"
)

type TestSuite struct {
	terraunit.UnitTest
}

func TestAWSSPAModule(t *testing.T) {
	suite.Run(t, &TestSuite{
		UnitTest: terraunit.UnitTest{
			ModulePath:  infraModulePath,
			IgnorePaths: []string{"test"}, // relative to TerraformRoot
		},
	})
}

func (ts *TestSuite) Test_ReadSPABucketPolicyDocument() {
	statements, err := GetJSONFromPlanByAddressAndKey(
		ts.Plan(),
		"data.aws_iam_policy_document.spa_bucket_policy_document",
		"statement")
	if err != nil {
		ts.FailNow("Unable to retrieve stagements from bucket policy")
	}
	ts.Require().NotEmpty(statements)
}

func (ts *TestSuite) Test_AWSCloudfrontDistribution_SPACF_CreationAndMapping() {
	cloudfrontDistributionJSON, err := GetJSONFromPlanByAddress(ts.Plan(), "aws_cloudfront_distribution.spa_cf")
	if err != nil {
		ts.FailNow("Unable to retrieve Cloudfront Distribution:\n" + err.Error())
	}
	var cloudfrontDistributionFromPlan cloudfrontDistribution
	err = json.Unmarshal([]byte(cloudfrontDistributionJSON), &cloudfrontDistributionFromPlan)
	if err != nil {
		ts.FailNow("Unable to unmarshall cloudfront distribution: \n" + err.Error())
	}
	ts.Require().Len(cloudfrontDistributionFromPlan.DefaultCacheBehavior, 1)
	for _, method := range []string{
		"DELETE",
		"GET",
		"HEAD",
		"OPTIONS",
		"PATCH",
		"POST",
		"PUT"} {
		ts.Require().Contains(
			cloudfrontDistributionFromPlan.DefaultCacheBehavior[0].AllowedMethods,
			method)
	}
	ts.Require().Exactly("index.html", cloudfrontDistributionFromPlan.DefaultRootObject)
	ts.Require().Exactly(
		"none",
		cloudfrontDistributionFromPlan.
			Restrictions[0].
			GeoRestriction[0].
			RestrictionType)
	ts.Require().Exactly(
		"s3-website",
		cloudfrontDistributionFromPlan.Origin[0].
			OriginId)
	expectedViewerCertificate := viewCertificate{
		AcmCertificateArn:            "arn:aws:acm:us-east-1:000000000000:certificate/00000000-1111-2222-3333-444444444444",
		CloudfrontDefaultCertificate: false,
		IamCertificateId:             nil,
		MinimumProtocolVersion:       "TLSv1.2_2021",
		SslSupportMethod:             "sni-only",
	}
	ts.Require().Len(cloudfrontDistributionFromPlan.ViewerCertificate, 1)
	ts.Require().Equal(expectedViewerCertificate, cloudfrontDistributionFromPlan.ViewerCertificate[0])
}

func (ts *TestSuite) Test_AWSCloudfrontOriginAccessIdentity_SPAOrigin_Creation() {
	comment, err := GetJSONFromPlanByAddressAndKey(
		ts.Plan(),
		"aws_cloudfront_origin_access_identity.spa_origin",
		"comment")
	if err != nil {
		ts.FailNow("Unable to retrieve comment from OAI:\n" + err.Error())
	}
	ts.Require().Exactly("OAI for s3 website access", comment)
}

func (ts *TestSuite) Test_AWSS3Bucket_SPABucket_Creation() {
	name, err := GetJSONFromPlanByAddressAndKey(
		ts.Plan(),
		"aws_s3_bucket.spa_bucket",
		"bucket")
	if err != nil {
		ts.FailNow("Unable to retrieve name from bucket:\n" + err.Error())
	}
	ts.Require().Exactly("FakeBucketName", name)
}

func (ts *TestSuite) Test_AWSS3BucketPublicAccessBlock_SPABucket_Creation() {
	publicAccessBlockFromPlanJSON, err := GetJSONFromPlanByAddress(ts.Plan(),
		"aws_s3_bucket_public_access_block.spa_bucket_public_block")
	if err != nil {
		ts.FailNow("Unable to retrieve public access block:\n" + err.Error())
	}
	var publicAccessBlockFromPlan publicAccessBlock
	err = json.Unmarshal([]byte(publicAccessBlockFromPlanJSON), &publicAccessBlockFromPlan)
	if err != nil {
		ts.FailNow("Unable to unmarshall public access block:\n" + err.Error())
	}
	expectedPublicAccessBlock := publicAccessBlock{
		BlockPublicAcls:       true,
		BlockPublicPolicy:     true,
		Bucket:                "FakeBucketName",
		IgnorePublicAcls:      true,
		RestrictPublicBuckets: true,
	}
	ts.Require().Equal(expectedPublicAccessBlock, publicAccessBlockFromPlan)
}

func (ts *TestSuite) Test_AWSS3BucketServerSideEncryptionConfiguration_SPABucketSSEC() {
	var encryptionConfigurationFromPlan encryptionConfiguration
	err := GetChangesAfterAsType(
		ts.Plan(),
		"aws_s3_bucket_server_side_encryption_configuration.spa_bucket_ssec",
		&encryptionConfigurationFromPlan)
	if err != nil {
		ts.FailNow(err.Error())
	}
	ts.Require().Exactly("FakeBucketName", encryptionConfigurationFromPlan.Bucket)
	ts.Require().Len(encryptionConfigurationFromPlan.Rule, 1,
		"Number of rules unexpected")
	ts.Require().Len(encryptionConfigurationFromPlan.Rule[0].ApplyServerSideEncryptionByDefault, 1,
		"Number of apply server side configuration by default elements unexpected.")
	ts.Require().Exactly("AES256", encryptionConfigurationFromPlan.Rule[0].ApplyServerSideEncryptionByDefault[0].SseAlgorithm)
}

func (ts *TestSuite) Test_BucketOwnershipControl_SPABucketOwnership_Creation() {
	type rule struct {
		ObjectOwnership string `json:"object_ownership"`
	}
	type rules []rule
	rulesJSON, err := GetJSONFromPlanByAddressAndKey(
		ts.Plan(),
		"aws_s3_bucket_ownership_controls.spa_bucket_ownership",
		"rule")
	var rulesFromPlan rules
	err = json.Unmarshal([]byte(rulesJSON), &rulesFromPlan)
	if err != nil {
		ts.FailNow("Unable to unmarshall rules:\n" + err.Error())
	}
	expectedRules := rules{rule{
		ObjectOwnership: "BucketOwnerEnforced",
	}}
	ts.Require().Equal(expectedRules, rulesFromPlan)
}

func (ts *TestSuite) Test_AWSS3BucketWebsiteConfiguration_SPABucketWebsiteConfig_Creation() {
	type errorDocument struct {
		Key string `json:"key"`
	}
	type indexDocument struct {
		Suffix string `json:"suffix""`
	}

	type websiteConfiguration struct {
		Bucket                string          `json:"bucket"`
		ErrorDocument         []errorDocument `json:"error_document"`
		ExpectedBucketOwner   interface{}     `json:"expected_bucket_owner"`
		IndexDocument         []indexDocument `json:"index_document"`
		RedirectAllRequestsTo []interface{}   `json:"redirect_all_requests_to"`
	}

	websiteConfigurationFromPlanJSON, err := GetJSONFromPlanByAddress(
		ts.Plan(),
		"aws_s3_bucket_website_configuration.spa_bucket_website_config")
	if err != nil {
		ts.FailNow("Unable to retrieve website configuration:\n" + err.Error())
	}

	var websiteConfigurationFromPlan websiteConfiguration
	err = json.Unmarshal([]byte(websiteConfigurationFromPlanJSON), &websiteConfigurationFromPlan)
	if err != nil {
		ts.FailNow("Unable to unmarshall website configuration:\n" + err.Error())
	}

	expectedWebsiteConfiguration := websiteConfiguration{
		Bucket:                "FakeBucketName",
		ErrorDocument:         nil,
		ExpectedBucketOwner:   nil,
		IndexDocument:         nil,
		RedirectAllRequestsTo: []interface{}{},
	}

	expectedWebsiteConfiguration.ErrorDocument = append(
		expectedWebsiteConfiguration.ErrorDocument, errorDocument{Key: "error.html"})
	expectedWebsiteConfiguration.IndexDocument = append(
		expectedWebsiteConfiguration.IndexDocument, indexDocument{Suffix: "index.html"})
	ts.Require().Equal(expectedWebsiteConfiguration, websiteConfigurationFromPlan)
}
