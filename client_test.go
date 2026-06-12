package espn

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

// serve starts a test HTTP server that always responds with the given status and body.
// The caller must defer srv.Close(). The returned Client is wired to the server.
func serve(t *testing.T, status int, body string) (*Client, *httptest.Server) {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(status)
		fmt.Fprint(w, body)
	}))
	return New(WithBaseURL(srv.URL)), srv
}

// Client construction

func TestNew_defaults(t *testing.T) {
	c := New()
	if c.baseURL != DefaultBaseURL {
		t.Errorf("baseURL = %q, want %q", c.baseURL, DefaultBaseURL)
	}
	if c.userAgent != DefaultUserAgent {
		t.Errorf("userAgent = %q, want %q", c.userAgent, DefaultUserAgent)
	}
	if c.httpClient == nil {
		t.Fatal("httpClient is nil")
	}
	if c.httpClient.Timeout != DefaultTimeout {
		t.Errorf("timeout = %v, want %v", c.httpClient.Timeout, DefaultTimeout)
	}
}

func TestWithBaseURL(t *testing.T) {
	c := New(WithBaseURL("https://example.com"))
	if c.baseURL != "https://example.com" {
		t.Errorf("baseURL = %q, want https://example.com", c.baseURL)
	}
}

func TestWithTimeout(t *testing.T) {
	c := New(WithTimeout(5 * time.Second))
	if c.httpClient.Timeout != 5*time.Second {
		t.Errorf("timeout = %v, want 5s", c.httpClient.Timeout)
	}
}

func TestWithHTTPClient(t *testing.T) {
	custom := &http.Client{Timeout: 99 * time.Second}
	c := New(WithHTTPClient(custom))
	if c.httpClient != custom {
		t.Fatal("httpClient was not replaced by custom client")
	}
}

func TestWithUserAgent(t *testing.T) {
	c := New(WithUserAgent("TestAgent/1.0"))
	if c.userAgent != "TestAgent/1.0" {
		t.Errorf("userAgent = %q, want TestAgent/1.0", c.userAgent)
	}
}

// Scoreboard

func TestScoreboard_success(t *testing.T) {
	c, srv := serve(t, http.StatusOK, scoreboardFixture)
	defer srv.Close()

	board, err := c.Scoreboard(context.Background(), SportSoccer, LeagueSlugFIFAWorld)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(board.Leagues) != 1 {
		t.Errorf("len(Leagues) = %d, want 1", len(board.Leagues))
	}
	if len(board.Events) != 1 {
		t.Errorf("len(Events) = %d, want 1", len(board.Events))
	}
}

func TestScoreboard_notFound(t *testing.T) {
	c, srv := serve(t, http.StatusNotFound, `{"code":404,"message":"not found"}`)
	defer srv.Close()

	_, err := c.Scoreboard(context.Background(), SportSoccer, "no.such.league")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
	if !errors.Is(err, ErrNotFound) {
		t.Errorf("expected ErrNotFound, got %v", err)
	}
}

func TestScoreboard_unexpectedStatus(t *testing.T) {
	c, srv := serve(t, http.StatusInternalServerError, `{"code":500,"message":"oops"}`)
	defer srv.Close()

	_, err := c.Scoreboard(context.Background(), SportSoccer, LeagueSlugFIFAWorld)
	if err == nil {
		t.Fatal("expected error, got nil")
	}
	if errors.Is(err, ErrNotFound) {
		t.Error("got ErrNotFound for a 500, want a generic error")
	}
}

func TestScoreboard_decodeError(t *testing.T) {
	c, srv := serve(t, http.StatusOK, `not valid json`)
	defer srv.Close()

	_, err := c.Scoreboard(context.Background(), SportSoccer, LeagueSlugFIFAWorld)
	if err == nil {
		t.Fatal("expected decode error, got nil")
	}
}

func TestScoreboard_nonJSONErrorBody(t *testing.T) {
	// 404 with a non-JSON body falls through to the generic status error,
	// not ErrNotFound (no valid APIError was decoded).
	c, srv := serve(t, http.StatusNotFound, `Not Found`)
	defer srv.Close()

	_, err := c.Scoreboard(context.Background(), SportSoccer, LeagueSlugFIFAWorld)
	if err == nil {
		t.Fatal("expected error, got nil")
	}
	if errors.Is(err, ErrNotFound) {
		t.Error("got ErrNotFound for non-JSON 404, want generic error")
	}
}

// WithDate

func TestWithDate_queryParam(t *testing.T) {
	var gotPath string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotPath = r.URL.RawQuery
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprint(w, scoreboardFixture)
	}))
	defer srv.Close()

	c := New(WithBaseURL(srv.URL))
	d := time.Date(2026, 6, 12, 0, 0, 0, 0, time.UTC)
	if _, err := c.Scoreboard(context.Background(), SportSoccer, LeagueSlugFIFAWorld, WithDate(d)); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(gotPath, "dates=20260612") {
		t.Errorf("query string %q does not contain dates=20260612", gotPath)
	}
}

// Summary

func TestSummary_success(t *testing.T) {
	c, srv := serve(t, http.StatusOK, summaryFixture)
	defer srv.Close()

	resp, err := c.Summary(context.Background(), SportSoccer, LeagueSlugFIFAWorld, "760415")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(resp.Boxscore.Form) != 1 {
		t.Errorf("len(Form) = %d, want 1", len(resp.Boxscore.Form))
	}
}

func TestSummary_notFound(t *testing.T) {
	c, srv := serve(t, http.StatusNotFound, `{"code":404,"message":"event not found"}`)
	defer srv.Close()

	_, err := c.Summary(context.Background(), SportSoccer, LeagueSlugFIFAWorld, "999999")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
	if !errors.Is(err, ErrNotFound) {
		t.Errorf("expected ErrNotFound, got %v", err)
	}
}

func TestSummary_eventQueryParam(t *testing.T) {
	var gotQuery string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotQuery = r.URL.RawQuery
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprint(w, summaryFixture)
	}))
	defer srv.Close()

	c := New(WithBaseURL(srv.URL))
	if _, err := c.Summary(context.Background(), SportSoccer, LeagueSlugFIFAWorld, "760415"); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !strings.Contains(gotQuery, "event=760415") {
		t.Errorf("query string %q does not contain event=760415", gotQuery)
	}
}

// Request headers

func TestGet_userAgentHeader(t *testing.T) {
	var gotUA string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotUA = r.Header.Get("User-Agent")
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprint(w, scoreboardFixture)
	}))
	defer srv.Close()

	c := New(WithBaseURL(srv.URL), WithUserAgent("CustomAgent/2.0"))
	if _, err := c.Scoreboard(context.Background(), SportSoccer, LeagueSlugFIFAWorld); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if gotUA != "CustomAgent/2.0" {
		t.Errorf("User-Agent = %q, want CustomAgent/2.0", gotUA)
	}
}
