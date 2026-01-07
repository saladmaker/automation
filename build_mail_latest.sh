
#!/bin/bash

# Configuration
PROJECT_DIR="./mailserver"
SERVICES="mailserver roundcube"

# Function to show usage if the user provides a wrong command
usage() {
    echo "Usage: $0 {start|build|fresh-start}"
    echo "  start       : Normal up (preserves data)"
    echo "  build       : Stop, rebuild images, and start"
    echo "  fresh-start : Delete volumes, rebuild, and start"
    exit 1
}

# Use a case statement on the first argument ($1)
case "$1" in
    start)
        echo ">>> Starting containers..."
        (cd "$PROJECT_DIR" && docker compose up -d)
        ;;
    
    build)
        echo ">>> Syncing Root CA and Rebuilding..."
        # Copy the CA into the build context first
        cp /home/khaled/.local/share/mkcert/rootCA.pem "$PROJECT_DIR/rootCA.pem"
        
        (cd "$PROJECT_DIR" && \
            docker compose stop && \
            docker compose build --no-cache $SERVICES && \
            docker compose up -d)
        ;;
    
    fresh-start)
        echo ">>> !!! FRESH START: Removing volumes and rebuilding !!!"
        (cd "$PROJECT_DIR" && \
            docker compose down -v && \
            docker compose build --no-cache $SERVICES && \
            docker compose up -d)
        ;;
    
    *)
        usage
        ;;
esac

echo ">>> Done."