// Package espn provides a sport-agnostic Go client for ESPN's public sports API
// (site.api.espn.com/apis/site/v2/sports). No API key is required.
//
// Callers are responsible for rate-limiting and caching; the client handles HTTP
// transport, JSON decoding, and typed error mapping.
//
// Typical usage:
//
//	c := espn.New()
//	board, err := c.Scoreboard(ctx, espn.SportSoccer, espn.LeagueSlugFIFAWorld)
package espn

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

const (
	// DefaultBaseURL is the ESPN site API base path.
	DefaultBaseURL = "https://site.api.espn.com/apis/site/v2/sports"
	// DefaultUserAgent satisfies ESPN's minimal bot-detection.
	DefaultUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
	// DefaultTimeout is applied to the http.Client created by New when no WithHTTPClient option is given.
	DefaultTimeout = 10 * time.Second
)

type (
	// Client is a concurrent-safe ESPN API client. Construct one with New and reuse it.
	Client struct {
		httpClient *http.Client
		baseURL    string
		userAgent  string
	}

	// Option configures a Client at construction time.
	Option func(*Client)
)

// WithBaseURL overrides the ESPN API base URL.
func WithBaseURL(u string) Option {
	return func(c *Client) { c.baseURL = u }
}

// WithTimeout creates a fresh http.Client with the given timeout and assigns it to the Client.
// Has no effect when applied before WithHTTPClient in the same New call; the custom client
// provided by WithHTTPClient takes precedence.
func WithTimeout(d time.Duration) Option {
	return func(c *Client) { c.httpClient = &http.Client{Timeout: d} }
}

// WithHTTPClient replaces the underlying *http.Client entirely. Use this when transport-level
// customisation (proxies, TLS, connection pooling) is required.
func WithHTTPClient(hc *http.Client) Option {
	return func(c *Client) { c.httpClient = hc }
}

// WithUserAgent overrides the User-Agent header sent with every request.
func WithUserAgent(ua string) Option {
	return func(c *Client) { c.userAgent = ua }
}

// New constructs a Client with sensible defaults. Pass Option values to override them.
func New(opts ...Option) *Client {
	c := &Client{
		baseURL:    DefaultBaseURL,
		userAgent:  DefaultUserAgent,
		httpClient: &http.Client{Timeout: DefaultTimeout},
	}
	for _, opt := range opts {
		opt(c)
	}
	return c
}

// get performs a GET request to rawURL, decodes the JSON body into v, and maps
// non-200 status codes to typed errors. Go's default transport transparently
// handles gzip decompression when the server sends Content-Encoding: gzip.
func (c *Client) get(ctx context.Context, rawURL string, v any) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, rawURL, http.NoBody)
	if err != nil {
		return fmt.Errorf("espn: build request: %w", err)
	}
	req.Header.Set("User-Agent", c.userAgent)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("espn: http: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		var apiErr APIError
		if json.NewDecoder(resp.Body).Decode(&apiErr) == nil && apiErr.Code != 0 {
			return &apiErr
		}
		return fmt.Errorf("espn: unexpected status %d", resp.StatusCode)
	}

	if err := json.NewDecoder(resp.Body).Decode(v); err != nil {
		return fmt.Errorf("espn: decode: %w", err)
	}
	return nil
}
