# Stage 1: Build the Next.js application
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the source code
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine

# Set the working directory
WORKDIR /usr/share/nginx/html

# Copy the built static files from the build stage
COPY --from=build /app/out .

# Expose port 80
EXPOSE 80

# Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]
