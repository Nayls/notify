package client

import (
	"bytes"
	"fmt"

	"io/ioutil"
	"net/http"

	"github.com/hashicorp/go-retryablehttp"
)

func RetryClient(url string, data string) {
	var jsonData = fmt.Sprintf(`{"content":"test [%d]."}`)
	var jsonStr = []byte(jsonData)
	req, err := http.NewRequest(
		"POST",
		"",
		bytes.NewBuffer(jsonStr),
	)
	req.Header.Set("Content-Type", "application/json")

	retryClient := retryablehttp.NewClient()
	resp, err := retryClient.StandardClient().Do(req)
	if err != nil {
		er(err)
	}
	defer resp.Body.Close()

	fmt.Println("response Status:", resp.Status)
	fmt.Println("response Headers:", resp.Header)
	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Println("response Body:", string(body))
}
