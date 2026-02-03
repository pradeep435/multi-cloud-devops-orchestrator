FROM python:3.11-slim

WORKDIR /app

# Install build/runtime dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app sources
COPY apy_fixed.py /app/apy_fixed.py
RUN echo "--- /app contents ---" && ls -la /app && echo "--- apy_fixed.py content start ---" && cat /app/apy_fixed.py || true && echo "--- apy_fixed.py content end ---"

COPY . .

ENV PYTHONUNBUFFERED=1
EXPOSE 5000

# Simple healthcheck using Python's stdlib (no external tools required)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,sys; r=urllib.request.urlopen('http://localhost:5000/health'); sys.exit(0 if r.getcode()==200 else 1)"

# Use gunicorn for production-like server
CMD ["gunicorn", "-b", "0.0.0.0:5000", "apy_fixed:app", "--workers", "2", "--threads", "4"]
