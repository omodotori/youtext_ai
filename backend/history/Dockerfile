# 1. Этап сборки
FROM golang:latest AS builder

WORKDIR /build

# Скачиваем зависимости
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходники и собираем бинарь с именем history
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o history ./cmd/main.go

# 2. Этап запуска
FROM alpine:latest

WORKDIR /app

# Забираем готовый бинарь history из первой стадии
COPY --from=builder /build/history .

# Жестко выдаем права на запуск
RUN chmod +x /app/history

EXPOSE 3001

# Запускаем
ENTRYPOINT ["/app/history"]