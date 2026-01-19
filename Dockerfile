# Stage 1: build
FROM golang:1.22-alpine AS builder
WORKDIR /app
ENV CGO_ENABLED=0
COPY go.mod ./
COPY main.go ./
RUN go build -trimpath -ldflags "-s -w" -o api

# Stage 2: run
FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates \
    && addgroup -S app \
    && adduser -S app -G app
COPY --from=builder /app/api .
USER app
EXPOSE 8080
CMD ["./api"]
