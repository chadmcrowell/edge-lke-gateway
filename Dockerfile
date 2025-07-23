# Stage 1: build
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod ./
COPY main.go ./
RUN go build -o api

# Stage 2: run
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /app/api .
EXPOSE 8080
CMD ["./api"]
