package utils

import (
	"net"
	"owner/internal/domain/models"
	"owner/internal/lib/apperrors"
	"regexp"
	"strings"
)

func ValidateReg(data models.User) error {
	if len(data.Password) < 8 || len(data.Password) > 32 {
		return apperrors.ErrPasswordLong
	}

	if ok := isValidEmailMX(data.Email); !ok {
		return apperrors.ErrInvalidEmail
	}

	if len(data.Nickname) <= 2 {
		return apperrors.ErrNickShort
	}

	return nil
}

func isValidEmailMX(email string) bool {
	re := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !re.MatchString(email) {
		return false
	}

	domain := email[strings.LastIndex(email, "@")+1:]
	mx, err := net.LookupMX(domain)
	return err == nil && len(mx) > 0
}
