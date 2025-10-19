# Docker Setup for Vulnerable Rails App

This project is now Dockerized for easy setup and testing of SAST tools.

## Quick Start with Docker Compose

1. **Build and run the application:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   Open your browser to [http://localhost:3000](http://localhost:3000)

## Alternative: Using Dockerfile Directly

1. **Build the Docker image:**
   ```bash
   docker build -t vuln-rails-app .
   ```

2. **Run the container:**
   ```bash
   docker run -p 3000:3000 -v $(pwd):/app vuln-rails-app
   ```

## Running Commands Inside the Container

### Using Docker Compose

```bash
# Run migrations
docker-compose exec web bundle exec rails db:migrate

# Open Rails console
docker-compose exec web bundle exec rails console

# Run tests
docker-compose exec web bundle exec rails test

# Run security scanners
docker-compose exec web ./run_scanners.sh

# Access bash shell
docker-compose exec web bash
```

### Using Docker Directly

```bash
# Get the container ID
docker ps

# Execute commands
docker exec -it <container_id> bundle exec rails console
docker exec -it <container_id> bash
```

## Database Management

The SQLite database is stored in the `db/` directory and will persist between container restarts when using volumes.

To reset the database:
```bash
docker-compose exec web bundle exec rails db:reset
```

## Stopping the Application

```bash
# With Docker Compose
docker-compose down

# Remove volumes as well
docker-compose down -v
```

## Troubleshooting

### Port already in use
If port 3000 is already in use, edit `docker-compose.yml` and change the ports mapping:
```yaml
ports:
  - "3001:3000"  # Use port 3001 instead
```

### Permission issues
If you encounter permission issues with SQLite, run:
```bash
docker-compose exec web chmod -R 777 db tmp log
```

### Rebuild from scratch
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

## Project Structure

This is a deliberately vulnerable Rails application for testing Static Application Security Testing (SAST) tools. See the main README.md for vulnerability details.

## Development

The application code is mounted as a volume, so any changes you make to the code will be reflected immediately (after Rails reloads).
