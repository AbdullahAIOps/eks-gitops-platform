# ---- build stage ----
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
# Static, stripped binary.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /demo-app .

# ---- runtime stage ----
# Distroless, non-root, no shell — minimal attack surface.
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /
COPY --from=build /demo-app /demo-app
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/demo-app"]
