# Build the application from source in a build container
FROM golang:latest AS build-stage

WORKDIR /app

# Copy go.mod and go.sum first for caching dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application
COPY . .

# Run tests and build the binary in one step
RUN go test ./... && \
    CGO_ENABLED=0 GOOS=linux go build -o helm-docs ./cmd/helm-docs

# Use a minimal base image for the release
FROM alpine:latest AS release

# Create user and group to run the app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the binary from the build stage
COPY --from=build-stage /app/helm-docs /usr/bin/

# Set the user to run the app
USER appuser

WORKDIR /helm-docs

ENTRYPOINT ["helm-docs"]