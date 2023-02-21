package main

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

type customClaims struct {
	UserName  string `json:"userName"`
	UserEmail string `json:"userEmail"`
	ID        string `json:"id"`
	jwt.RegisteredClaims
}

func validateToken(token string) (*customClaims, error) {
	validToken, err := jwt.ParseWithClaims(
		token,
		&customClaims{},
		func(token *jwt.Token) (interface{}, error) {
			return []byte(os.Getenv("JWT_SECRET_KEY")), nil
		},
	)

	if err != nil {
		return nil, err
	}

	claims, ok := validToken.Claims.(*customClaims)
	if !ok {
		return nil, errors.New("couldn't parse claims")
	}

	if claims.ExpiresAt.Unix() < time.Now().UTC().Unix() {
		return nil, errors.New("jwt is expired")
	}

	return claims, nil
}
