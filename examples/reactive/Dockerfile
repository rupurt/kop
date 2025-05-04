FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
WORKDIR /app
COPY pyproject.toml ./examples/reactive/pyproject.toml
COPY examples/reactive/src ./examples/reactive
RUN uv pip install --system -r ./examples/reactive/pyproject.toml

CMD ["uv", "run", "/app/examples/reactive/consumer.py"]
