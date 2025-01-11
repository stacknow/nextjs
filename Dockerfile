# Stage 1: Build the Next.js application
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the source code
COPY . .

# Build the Next.js application and export static files
RUN npm run build && npx next export

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine

# Set the working directory
WORKDIR /usr/share/nginx/html

# Copy the exported static files from the build stage
COPY --from=build /app/out .

# Custom Nginx configuration
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
        location /static/ { \
            root /usr/share/nginx/html; \
        } \
    } \
}' > /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
