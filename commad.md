
# docker  run nginx with volume mapping
```shell 
  docker run -d \
  --name nginx-all \
  -p 80:80 -p 443:443 \
  --add-host=host.docker.internal:host-gateway \
  --network infra \
  -v $(pwd)/nginx/html:/usr/share/nginx/html \
  -v $(pwd)/nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  -v $(pwd)/nginx/dgb.local.pem:/etc/nginx/certs/dgb.local.pem:ro \
  -v $(pwd)/nginx/dgb.local-key.pem:/etc/nginx/certs/dgb.local-key.pem:ro \
  nginx:alpine
```

# keycloak building an optimized keycloak (like a production enviroment)
```shell
$(KC_DIR)/bin/kc.sh build --http-relative-path=/auth --db=dev-file
```

# keycloak export command:
```shell
$(KC_DIR)/bin/kc.sh export --dir=./exports --realm=dgb --users realm_file --optimized
```

# execution privilege scripts (chmod +x)

# docker create a network (infra)

# trusting a certificate in JDK

# keycloak email configuration

# keycloak dgb-theme

# mail server create a user command:
```shell
docker exec -it mailserver setup email add admin@mail.dgb.local qwe123
docker exec -it mailserver setup email list
```


