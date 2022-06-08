package test

import (
	"testing"
)

func TestNoCNAMEExample(t *testing.T) {
	testCloudFront(t, "no-cname")
}
