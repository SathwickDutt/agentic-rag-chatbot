# Stage 1: Builder - Install dependencies
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies (only needed for compilation)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages to a virtual environment
COPY requirements.txt ./
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt


# Stage 2: Runtime - Minimal final image
FROM python:3.11-slim

WORKDIR /app

# Copy virtual environment from builder (much smaller than system Python)
COPY --from=builder /opt/venv /opt/venv

# Set environment to use the venv
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Copy application code
COPY src/ src/
COPY docs_dir/ docs_dir/
COPY start.sh ./start.sh

# Make start.sh executable
RUN chmod +x start.sh

# Expose backend and frontend ports
EXPOSE 8000 8501

# Set environment variables (can be overridden at runtime)
ENV GROQ_API_KEY="your_groq_api_key" \
    DOCUMENTS_DIR="/app/docs_dir" \
    VECTOR_STORE_DIR="/app/doc_vector_store" \
    COLLECTION_NAME="document_collection" \
    MODEL_NAME="llama-3.3-70b-versatile" \
    MODEL_TEMPERATURE=0.0 \
    CHAT_ENDPOINT_URL="http://localhost:8000/chat/answer"

# Run all services using start.sh
CMD ["/app/start.sh"]
