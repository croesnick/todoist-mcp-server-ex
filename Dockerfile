# Build stage
FROM elixir:1.18-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base git

WORKDIR /app

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod

# Compile dependencies
RUN mix deps.compile

# Copy all source files
COPY lib lib

# Compile project and create release
RUN MIX_ENV=prod mix release

# Runtime stage
FROM alpine:3.21

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses libstdc++

WORKDIR /app

# Copy release from builder
COPY --from=builder /app/_build/prod/rel/todoist_mcp_server ./

# Set environment variables
ENV MIX_ENV=prod

# Expose port (update to match your application's port)
EXPOSE 4000

# Run the release
CMD ["bin/todoist_mcp_server", "start"]
