FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# Install only dependencies into /app/.venv (skips building src/tubo)
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project --no-dev

# Final lightweight runtime image
FROM python:3.13-slim-bookworm

WORKDIR /app

# Copy the pre-built virtual environment and your Flask app folder
COPY --from=builder /app/.venv /app/.venv
COPY app ./app

EXPOSE 5000

CMD ["/app/.venv/bin/python", "-m", "app.app"]

