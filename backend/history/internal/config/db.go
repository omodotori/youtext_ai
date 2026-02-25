package config

import (
	"database/sql"
	"fmt"
	"history/internal/models"
	"log/slog"
	"time"

	_ "github.com/lib/pq"
)

func ConnDb(config *models.Config) (*sql.DB, error) {
	postgresConnStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable",
		config.DBUser, config.DBUser, config.DBPassword, config.DBName)

	db, err := sql.Open("postgres", postgresConnStr)
	if err != nil {
		slog.Error("Не удалось инициализировать драйвер БД")
		return nil, fmt.Errorf("ошибка sql.Open: %w", err)
	}

	for i := 1; i <= 10; i++ {
		err = db.Ping()
		if err == nil {
			slog.Info("Успешное подключение к PostgreSQL!")
			return db, nil
		}

		slog.Warn(fmt.Sprintf("База еще не готова (попытка %d/10), ждем 2 секунды...", i))
		time.Sleep(2 * time.Second)
	}

	db.Close()
	slog.Error("PostgreSQL так и не ответил")
	return nil, fmt.Errorf("не удалось подключиться к PostgreSQL после 10 попыток: %w", err)
}
