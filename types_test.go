package espn

import (
	"encoding/json"
	"testing"
)

// TestESPNTimeUnmarshal verifies that ESPNTime decodes both ESPN's seconds-less
// timestamp format and standard RFC3339, and tolerates null/empty values.
func TestESPNTimeUnmarshal(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		want    string // expected UTC value formatted as RFC3339, "" for zero
		wantErr bool
	}{
		{
			name:  "espn seconds-less format",
			input: `"2026-06-11T04:00Z"`,
			want:  "2026-06-11T04:00:00Z",
		},
		{
			name:  "full rfc3339 with seconds",
			input: `"2026-06-11T04:00:30Z"`,
			want:  "2026-06-11T04:00:30Z",
		},
		{
			name:  "seconds-less with offset",
			input: `"2026-06-11T04:00-05:00"`,
			want:  "2026-06-11T09:00:00Z",
		},
		{
			name:  "json null",
			input: `null`,
			want:  "",
		},
		{
			name:  "empty string",
			input: `""`,
			want:  "",
		},
		{
			name:    "unparseable",
			input:   `"not-a-date"`,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var got ESPNTime
			err := json.Unmarshal([]byte(tt.input), &got)
			if tt.wantErr {
				if err == nil {
					t.Fatalf("expected error, got nil (value %v)", got.Time)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if tt.want == "" {
				if !got.IsZero() {
					t.Fatalf("expected zero time, got %v", got.Time)
				}
				return
			}
			if g := got.UTC().Format("2006-01-02T15:04:05Z07:00"); g != tt.want {
				t.Fatalf("got %q, want %q", g, tt.want)
			}
		})
	}
}

// TestESPNTimeEmbeddedInEvent verifies the real-world failure case: decoding an
// Event whose date uses ESPN's seconds-less format, which broke standard
// time.Time unmarshaling on every request.
func TestESPNTimeEmbeddedInEvent(t *testing.T) {
	const raw = `{"date":"2026-06-11T04:00Z","id":"760415"}`

	var ev Event
	if err := json.Unmarshal([]byte(raw), &ev); err != nil {
		t.Fatalf("decode Event: %v", err)
	}
	if got := ev.Date.UTC().Format("2006-01-02T15:04:05Z07:00"); got != "2026-06-11T04:00:00Z" {
		t.Fatalf("Event.Date = %q, want 2026-06-11T04:00:00Z", got)
	}

	// Re-marshaling round-trips through the embedded time.Time (RFC3339 output).
	out, err := json.Marshal(ev.Date)
	if err != nil {
		t.Fatalf("marshal Event.Date: %v", err)
	}
	if string(out) != `"2026-06-11T04:00:00Z"` {
		t.Fatalf("marshaled Event.Date = %s, want \"2026-06-11T04:00:00Z\"", out)
	}
}
