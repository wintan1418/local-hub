# Docker Setup for LocalServiceHub

This project includes a professional Docker setup that makes deployment and development easier.

## Quick Start

### Development with Docker Compose

1. **Start all services:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   - Web app: http://localhost:3000
   - Database: localhost:5432
   - Redis: localhost:6379

3. **Run Rails commands:**
   ```bash
   # Run migrations
   docker-compose exec web rails db:migrate
   
   # Open Rails console
   docker-compose exec web rails console
   
   # Run tests
   docker-compose exec web rails test
   
   # Build Tailwind CSS
   docker-compose exec web rails tailwindcss:build
   ```

### Production Deployment

#### Building for Production

```bash
# Build production image
docker build -t localservicehub-production .

# Run production container
docker run -p 3000:3000 \
  -e DATABASE_URL=your_database_url \
  -e RAILS_MASTER_KEY=your_master_key \
  localservicehub-production
```

#### Render Deployment

This project is configured to deploy to Render using Docker:

1. Push to your repository
2. Render will automatically build using the Dockerfile
3. Environment variables are configured in `render.yaml`

## Docker Architecture

### Multi-Stage Build

The Dockerfile uses a multi-stage build approach:

- **Base Stage**: Common runtime dependencies
- **Build Stage**: Build tools, gems, assets compilation
- **Final Stage**: Minimal runtime image with only what's needed

### Asset Pipeline

The Docker setup properly handles:

- **Tailwind CSS**: Built during Docker build process
- **Propshaft**: Assets served directly from `app/assets/builds`
- **Import Maps**: JavaScript modules handled by Rails

### Security Features

- Non-root user execution
- Minimal final image
- No build tools in production image
- Proper file permissions

## File Structure

```
├── Dockerfile              # Multi-stage production build
├── docker-compose.yml      # Development environment
├── docker-compose.override.yml  # Development overrides
├── .dockerignore           # Files to exclude from build
├── bin/docker-entrypoint   # Container startup script
└── README.docker.md        # This file
```

## Environment Variables

### Required for Production

- `DATABASE_URL`: PostgreSQL connection string
- `RAILS_MASTER_KEY`: For encrypted credentials
- `SECRET_KEY_BASE`: Session security (auto-generated on Render)

### Optional

- `REDIS_URL`: For Sidekiq background jobs
- `TWILIO_ACCOUNT_SID`: SMS functionality
- `TWILIO_AUTH_TOKEN`: SMS functionality
- `STRIPE_PUBLISHABLE_KEY`: Payment processing
- `STRIPE_SECRET_KEY`: Payment processing

## Troubleshooting

### Assets Not Loading

If CSS/assets aren't loading:

1. Check if Tailwind CSS was built:
   ```bash
   docker-compose exec web ls -la app/assets/builds/
   ```

2. Rebuild Tailwind CSS:
   ```bash
   docker-compose exec web rails tailwindcss:build
   ```

### Database Issues

1. Reset database:
   ```bash
   docker-compose down
   docker volume rm localservicehub_postgres_data
   docker-compose up --build
   ```

2. Run migrations:
   ```bash
   docker-compose exec web rails db:create db:migrate db:seed
   ```

### Performance Tips

1. **Use Docker Build Cache**: Keep Gemfile/package.json changes minimal
2. **Volume Mounts**: Bundle and node_modules are cached in volumes
3. **Multi-stage**: Production images are ~50% smaller than single-stage

## Development Workflow

1. **Start services**: `docker-compose up`
2. **Make changes**: Edit files normally (volume mounted)
3. **Restart if needed**: `docker-compose restart web`
4. **Add gems**: Rebuild with `docker-compose up --build web`
5. **Database changes**: `docker-compose exec web rails db:migrate`

This Docker setup provides:
- ✅ Consistent development environment
- ✅ Production-ready deployment
- ✅ Proper asset compilation
- ✅ Security best practices
- ✅ Fast rebuild times
- ✅ Easy horizontal scaling