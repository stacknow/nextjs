# Stage 1: Build the Next.js application
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Install necessary packages
RUN apk add --no-cache libc6-compat

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine

# Set the working directory for the Nginx container
WORKDIR /usr/share/nginx/html

# Copy custom Nginx configuration
RUN echo 'worker_processes 1; \
events { worker_connections 1024; } \
http { \
    include       mime.types; \
    default_type  application/octet-stream; \
    access_log /dev/stdout; \
    error_log /dev/stderr warn; \
    sendfile        on; \
    server { \
        listen       80; \
        server_name  localhost; \
        location / { \
            root   /usr/share/nginx/html; \
            index  index.html; \
            try_files $uri /index.html; \
        } \
        location /_next/ { \
            root /usr/share/nginx/html; \
        } \
    } \
}' > /etc/nginx/nginx.conf

# Copy the Next.js built application from the previous stage
COPY --from=build /app/.next /usr/share/nginx/html/_next
COPY --from=build /app/public /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
