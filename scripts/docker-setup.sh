#!/bin/bash

# Docker setup script for microfrontend monorepo
# This script helps manage the Docker environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to check if ports are available
check_ports() {
    local ports=("3000" "3001")
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_warning "Port $port is already in use. You may need to stop conflicting services."
        else
            print_success "Port $port is available"
        fi
    done
}

# Function to build images
build_images() {
    print_status "Building Docker images..."
    docker-compose build
    print_success "Docker images built successfully"
}

# Function to start services
start_services() {
    print_status "Starting services..."
    docker-compose up -d
    print_success "Services started successfully"
}

# Function to stop services
stop_services() {
    print_status "Stopping services..."
    docker-compose down
    print_success "Services stopped successfully"
}

# Function to show logs
show_logs() {
    print_status "Showing logs (Ctrl+C to exit)..."
    docker-compose logs -f
}

# Function to check health
check_health() {
    print_status "Checking service health..."
    
    # Wait a bit for services to start
    sleep 5
    
    local services=("http://localhost:3000/health" "http://localhost:3001/health")
    
    for service in "${services[@]}"; do
        if curl -s "$service" > /dev/null; then
            print_success "$service is healthy"
        else
            print_error "$service is not responding"
        fi
    done
}

# Function to clean up
cleanup() {
    print_status "Cleaning up Docker resources..."
    docker-compose down -v --remove-orphans
    docker system prune -f
    print_success "Cleanup completed"
}

# Function to show status
show_status() {
    print_status "Current Docker status:"
    docker-compose ps
}

# Function to show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build     - Build Docker images"
    echo "  start     - Start services"
    echo "  stop      - Stop services"
    echo "  restart   - Restart services"
    echo "  logs      - Show logs"
    echo "  health    - Check service health"
    echo "  status    - Show service status"
    echo "  cleanup   - Clean up Docker resources"
    echo "  setup     - Full setup (build + start + health check)"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup     # Complete setup"
    echo "  $0 logs      # View logs"
    echo "  $0 cleanup   # Clean everything"
}

# Main script logic
main() {
    case "${1:-help}" in
        "build")
            check_docker
            build_images
            ;;
        "start")
            check_docker
            check_ports
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            stop_services
            start_services
            ;;
        "logs")
            show_logs
            ;;
        "health")
            check_health
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup
            ;;
        "setup")
            check_docker
            check_ports
            build_images
            start_services
            check_health
            print_success "Setup completed! Access your apps at:"
            echo "  Host App: http://localhost:3000"
            echo "  Remote App: http://localhost:3001"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@" 