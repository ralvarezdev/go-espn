package espn

import (
	"errors"
	"fmt"
)

// ErrNotFound is returned when the ESPN API responds with a 404 status.
// Use errors.Is to check for it.
var ErrNotFound = errors.New("espn: resource not found")

// APIError is an error response body returned by the ESPN API.
type APIError struct {
	Message string `json:"message"`
	Code    int    `json:"code"`
}

func (e *APIError) Error() string {
	return fmt.Sprintf("espn: API error %d: %s", e.Code, e.Message)
}

// Is maps a 404 APIError to ErrNotFound so callers can write errors.Is(err, espn.ErrNotFound).
func (e *APIError) Is(target error) bool {
	return target == ErrNotFound && e.Code == 404
}
