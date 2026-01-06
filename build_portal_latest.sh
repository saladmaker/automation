#!/usr/bin/env bash
env -C dgb-portal ng build --configuration production
rsync -av --delete dgb-portal/dist/client/ ./nginx/html/
docker exec nginx-all nginx -s reload
echo "✅ Deployment to Nginx volume complete."