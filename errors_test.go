package espn

import (
	"errors"
	"testing"
)

func TestAPIError_Error(t *testing.T) {
	e := &APIError{Code: 404, Message: "not found"}
	if got := e.Error(); got != "espn: API error 404: not found" {
		t.Fatalf("Error() = %q, want \"espn: API error 404: not found\"", got)
	}
}

func TestAPIError_Is_notFound(t *testing.T) {
	e := &APIError{Code: 404, Message: "not found"}
	if !errors.Is(e, ErrNotFound) {
		t.Fatal("expected errors.Is(APIError{404}, ErrNotFound) = true")
	}
}

func TestAPIError_Is_other(t *testing.T) {
	e := &APIError{Code: 500, Message: "server error"}
	if errors.Is(e, ErrNotFound) {
		t.Fatal("expected errors.Is(APIError{500}, ErrNotFound) = false")
	}
}

func TestAPIError_Is_zeroCopde(t *testing.T) {
	e := &APIError{Code: 0, Message: ""}
	if errors.Is(e, ErrNotFound) {
		t.Fatal("expected errors.Is(APIError{0}, ErrNotFound) = false")
	}
}

func TestErrNotFound_isNotNil(t *testing.T) {
	if ErrNotFound == nil {
		t.Fatal("ErrNotFound is nil")
	}
}
