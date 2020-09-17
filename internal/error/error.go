package error

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

// Er ...
func Er(msg interface{}) {
	fmt.Println("Error:", msg)
	os.Exit(1)
}

type successfulJSONResponse struct {
	Success bool   `json:"success"`
	Message string `json:"errorMessage"`
}

type unsuccessfulJSONResponse struct {
	Success      bool   `json:"success"`
	ErrorMessage string `json:"errorMessage"`
}

func writeSuccessfulResponse(w http.ResponseWriter, message string) {
	w.WriteHeader(http.StatusOK)
	if message == "" {
		w.Write([]byte(`{"success":true}`))
	} else {
		response, _ := json.Marshal(&successfulJSONResponse{
			Success: false,
			Message: message,
		})
		w.Write(response)
	}
}

func writeUnsuccessfulResponse(w http.ResponseWriter, errorMessage string) {
	response, _ := json.Marshal(&unsuccessfulJSONResponse{
		Success:      false,
		ErrorMessage: errorMessage,
	})
	w.WriteHeader(http.StatusBadRequest)
	w.Write(response)
}

// writeUnsuccsessfulResponse(w, "Cant not parse JSON: ") + err.Error())
