FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# Copy dependency files and install production dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project --no-dev

# Copy application code and install project
COPY app ./app
RUN uv sync --locked --no-dev

# Final lightweight runtime image
FROM python:3.13-slim-bookworm

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/app /app/app

EXPOSE 5000

# Explicitly run using the virtual environment's Python binary
CMD ["/app/.venv/bin/python", "-m", "app.app"]
