# Используем Maven с JDK 17 для сборки
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Сначала копируем pom.xml, чтобы кешировались зависимости
COPY pom.xml ./
RUN mvn dependency:go-offline -B

# Копируем исходники
COPY src ./src

# Собираем проект (без тестов)
RUN mvn clean package -DskipTests

# Финальный образ — JRE 17
FROM eclipse-temurin:17-jre

WORKDIR /app

# Копируем собранный jar-файл
COPY --from=builder /app/target/*.jar app.jar

# Порт, на котором запускается приложение
EXPOSE 3003

# Команда запуска
ENTRYPOINT ["java", "-jar", "app.jar"]
