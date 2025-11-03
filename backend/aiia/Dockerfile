# ----------- Stage 1: Build Go app -----------
FROM golang:1.23-alpine AS builder

ENV GOTOOLCHAIN=go1.24.8+auto

# Устанавливаем git для go mod
RUN apk add --no-cache git

WORKDIR /app

# Копируем зависимости и скачиваем
COPY go.mod go.sum ./
RUN go mod download

# Копируем весь код и билдим
COPY . .
RUN go build -o server ./cmd/server

# ----------- Stage 2: Final image -----------
FROM python:3.12-alpine

# Устанавливаем зависимости: bash для скриптов, ca-certificates для HTTPS, ffmpeg для yt-dlp
RUN apk add --no-cache bash ca-certificates ffmpeg

# Ставим yt-dlp (игнорируем ограничение системы)
RUN pip3 install --break-system-packages yt-dlp

WORKDIR /root/

# Копируем Go binary из builder
COPY --from=builder /app/server .

EXPOSE 3000

# Команда запуска
CMD ["./server"]
