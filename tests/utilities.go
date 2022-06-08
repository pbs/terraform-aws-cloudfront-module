package test

import (
	"io/ioutil"
	"testing"
)

func getFileAsString(t *testing.T, fileName string) (string, error) {
	content, err := ioutil.ReadFile(fileName)
	if err != nil {
		t.Fatal(err)
		return "", err
	}

	text := string(content)
	return text, nil
}
