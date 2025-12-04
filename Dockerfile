# Base image with Flutter SDK and Dart preinstalled
FROM ghcr.io/cirruslabs/flutter:3.35.3


# Set working directory
WORKDIR /app

# Copy pubspec first to cache dependencies
COPY pubspec.* ./

# Get Flutter dependencies
RUN flutter pub get

# Copy rest of the source code
COPY . .

# Create .env file placeholder (mounted at runtime)
RUN touch .env

# Enable web support just in case
RUN flutter config --enable-web

# Run Flutter tests to verify setup (optional)
RUN flutter test

# Expose web dev port
EXPOSE 8080

# Default command for development (serves on web)
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]
