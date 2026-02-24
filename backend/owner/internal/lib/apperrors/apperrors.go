package apperrors

import "net/http"

type AppError struct {
	Message string // Сообщение для пользователя
	Code    int    // HTTP статус код (400, 404, 500)
	Err     error  // Реальная ошибка (для логов)
}

func (e *AppError) Error() string {
	if e.Err != nil {
		return e.Message + ": " + e.Err.Error()
	}
	return e.Message
}

func NewAuthError(msg string) *AppError {
	return &AppError{
		Message: msg,
		Code:    http.StatusUnauthorized, // 401
	}
}

func NewBadRequest(msg string) *AppError {
	return &AppError{
		Message: msg,
		Code:    http.StatusBadRequest, // 400
	}
}

func NewInternal(err error) *AppError {
	return &AppError{
		Message: "Something went wrong",
		Code:    http.StatusInternalServerError, // 500
		Err:     err,
	}
}

var (
	ErrPasswordLong = NewBadRequest("Password must be between 8 and 32 characters")
	ErrInvalidEmail = NewBadRequest("Invalid email")
	ErrNickShort    = NewBadRequest("Nickname is too short")
)

func CheckError(err error) int {
	if appErr, ok := err.(*AppError); ok {
		return appErr.Code
	}

	return http.StatusInternalServerError
}
