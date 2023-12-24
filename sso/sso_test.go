package sso_test

import (
	"testing"

	"github.com/alecthomas/assert/v2"
)

type SSOProvider interface {
	getLoginURL() string
}

type SSOCookie interface {
	getCookie(URL string) string
}

type PreLogin struct {
	SSOProvider SSOProvider
	SSOCookie   SSOCookie
}

type InMemorySSOProvider struct{}

func (i *InMemorySSOProvider) getLoginURL() string {
	return "http://localhost/auth/prelogin"
}

type LoginClient struct{}

func (l *LoginClient) getCookie(url string) string {
	return "cookie1234"
}

func TestSSO(t *testing.T) {
	t.Parallel()

	inMemorySSOProvider := InMemorySSOProvider{}
	loginClient := LoginClient{}

	runSSO(t, PreLogin{SSOProvider: &inMemorySSOProvider, SSOCookie: &loginClient})
}

func runSSO(tb testing.TB, client PreLogin) {
	tb.Helper()

	want := "cookie1234"
	cookie := client.SSOCookie.getCookie(client.SSOProvider.getLoginURL())

	assert.Equal(tb, cookie, want)
}
