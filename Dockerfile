# # Use the official Python base image
# FROM python:3.10-slim

# # Install system dependencies, including OpenCV dependencies
# RUN apt-get update && apt-get install -y \
#     gcc \
#     portaudio19-dev \
#     ghostscript \
#     poppler-utils \
#     tesseract-ocr \
#     libglib2.0-0 \
#     libsm6 \
#     libxext6 \
#     libxrender-dev \
#     libopencv-dev \
#     && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# # Set the working directory in the container
# WORKDIR /app

# # Copy only the requirements.txt initially to leverage Docker cache
# COPY requirements.txt .

# # Install Python dependencies, including OpenCV
# RUN pip install --no-cache-dir -r requirements.txt \
#     && pip install opencv-python-headless

# # Now copy the rest of your application files into the container
# COPY . .

# # Verify gunicorn installation
# RUN gunicorn --version

# # Make port 8000 available to the world outside this container
# EXPOSE 8000

# # Command to run the application
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main:app", "--timeout", "120", "--workers", "3"]


# Use the official Python base image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy only the requirements.txt initially to leverage Docker cache
COPY requirements.txt .

# Install system dependencies, including OpenCV dependencies, 
# and then install Python packages in one RUN command to reduce layers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    portaudio19-dev \
    ghostscript \
    poppler-utils \
    tesseract-ocr \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libopencv-dev && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install opencv-python-headless && \
    gunicorn --version

# Now copy the rest of your application files into the container
COPY . .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Command to run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main:app", "--timeout", "120", "--workers", "3"]

