# 1. Builder stage using official uv image
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# Install dependencies first (cached unless pyproject.toml or uv.lock changes)
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project --no-dev

# Copy application code and install the project
COPY . .
RUN uv sync --locked --no-dev

# 2. Final lightweight runtime image
FROM python:3.13-slim-bookworm

WORKDIR /app

# Copy the pre-built virtual environment and app code from builder
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/app /app/app

# Put the virtual environment on PATH
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 5000

CMD ["python", "-m", "app.app"]
