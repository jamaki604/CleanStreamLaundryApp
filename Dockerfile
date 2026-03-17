# Base image with Flutter SDK and Dart
FROM ghcr.io/cirruslabs/flutter:3.35.3

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (includes npm)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Supabase CLI
RUN npm install -g supabase

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh

# Add Deno to PATH
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy dependency files first (for caching)
COPY pubspec.* ./

# Install Flutter dependencies
RUN flutter pub get

# Copy rest of project
COPY . .

# Enable web support
RUN flutter config --enable-web

# Optional: run tests
RUN flutter test

# Expose dev server port
EXPOSE 8080

# Create .env placeholder (mounted at runtime)
RUN touch .env

# Default command
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]