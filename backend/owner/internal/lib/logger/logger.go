package logger

import (
	"fmt"
	"log"
	"os"
	"time"
)

const (
	reset  = "\033[0m"
	red    = "\033[31m"
	green  = "\033[32m"
	yellow = "\033[33m"
	blue   = "\033[34m"
	gray   = "\033[90m"
)

type Logger struct {
	prefix string
}

func New(prefix string) *Logger {
	return &Logger{prefix: prefix}
}

func (l *Logger) log(level string, color string, msg string, args ...interface{}) {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	formatted := fmt.Sprintf(msg, args...)
	log.Printf("%s[%s] [%s] %s: %s%s\n", color, timestamp, level, l.prefix, formatted, reset)
}

func (l *Logger) Info(msg string, args ...interface{}) {
	l.log("INFO", blue, msg, args...)
}

func (l *Logger) Success(msg string, args ...interface{}) {
	l.log("SUCCESS", green, msg, args...)
}

func (l *Logger) Warn(msg string, args ...interface{}) {
	l.log("WARN", yellow, msg, args...)
}

func (l *Logger) Error(msg string, args ...interface{}) {
	l.log("ERROR", red, msg, args...)
}

func (l *Logger) Debug(msg string, args ...interface{}) {
	if os.Getenv("DEBUG") == "true" {
		l.log("DEBUG", gray, msg, args...)
	}
}
