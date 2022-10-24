package test

import (
	"fmt"
	"os"
	"testing"
	"time"

	httpHelper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func testCloudFront(t *testing.T, variant string) {
	t.Parallel()

	primaryHostedZone := os.Getenv("TF_VAR_primary_hosted_zone")

	if primaryHostedZone == "" {
		t.Fatal("TF_VAR_primary_hosted_zone must be set to run tests. e.g. 'export TF_VAR_primary_hosted_zone=example.org'")
	}

	terraformDir := fmt.Sprintf("../examples/%s", variant)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		LockTimeout:  "5m",
	}

	defer func() {
		terraform.Destroy(t, terraformOptions)
	}()

	expectedName := fmt.Sprintf("example-tf-cloudfront-%s", variant)
	expectedDomainName := fmt.Sprintf("%s.%s", expectedName, primaryHostedZone)

	terraform.Init(t, terraformOptions)

	if variant == "policies" {
		// This is a workaround due to the fact that Terraform
		// doesn't like it when it can't figure out what resources
		// are being created for a given piece of state without resolving
		// dynamic inputs.
		terraformTargetOptions := &terraform.Options{
			TerraformDir: terraformDir,
			Targets: []string{
				"module.s3",
				"module.response_headers_policy",
				"module.origin_request_policy",
				"module.cache_policy",
			},
			LockTimeout: "5m",
		}
		terraform.Apply(t, terraformTargetOptions)
	}

	terraform.Apply(t, terraformOptions)

	domainName := terraform.Output(t, terraformOptions, "domain_name")

	if variant != "no-cname" {
		assert.Equal(t, domainName, expectedDomainName)
	} else {
		assert.Contains(t, domainName, "cloudfront.net")
	}

	indexURL := fmt.Sprintf("https://%s/", domainName)
	expectedIndex, err := getFileAsString(t, "nginx-index.html")

	if err != nil {
		t.Fatal(err)
	}

	httpHelper.HttpGetWithRetry(t, indexURL, nil, 200, expectedIndex, 300, 3*time.Second)
}
