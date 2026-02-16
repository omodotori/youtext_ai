package utils

import (
	"encoding/json"
	"errors"
	"net/http"
	"owner/internal/lib/apperrors"
)

var (
	ErrPasswordLong = errors.New("Password must be between 8 and 32 characters")
)

func ResponseInJson(w http.ResponseWriter, statusCode int, object interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(object)
}

func ErrResponseInJson(w http.ResponseWriter, err error) {
	statusCode := apperrors.CheckError(err)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
}
