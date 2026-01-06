#!/usr/bin/env bash

KC_DIR="./keycloak"
KC_BIN="$KC_DIR/bin/kc.sh"
PORT=8080
DATA_DIR="$KC_DIR/data"

# Unified build options to prevent Keycloak from re-building during import
KC_OPTS="--http-relative-path=/auth --db=dev-file"

get_kc_pid() {
    lsof -t -i :$PORT
}

stop_kc() {
    PID=$(get_kc_pid)
    if [ -n "$PID" ]; then
        echo "Stopping Keycloak on port $PORT (PID: $PID)..."
        kill -INT "$PID"
        for i in {1..3}; do
            if ! lsof -i :$PORT > /dev/null; then
                echo "Keycloak stopped."
                return 0
            fi
            echo "Waiting for port $PORT to clear ($i/3)..."
            sleep 1
        done
        kill -9 "$PID"
    else
        echo "No process found on port $PORT."
    fi
}



build_kc() {
    echo "--- Building Keycloak (Themes & Optimization) ---"
    npm --prefix dgb-theme run build-keycloak-theme
    cp dgb-theme/dist_keycloak/keycloak-theme-for-kc-all-other-versions.jar "$KC_DIR/providers/"
    "$KC_BIN" build --http-relative-path=/auth --db=dev-file
}

create_admin() {
    echo "--- Bootstrapping Admin User ---"
    # Using environment variables for the bootstrap command to avoid CLI flag errors
    export PASS_VAR="admin"
    "$KC_BIN" bootstrap-admin user --username admin --password:env PASS_VAR --optimized
}

import_kc_realm() {
    echo "Importing Keycloak realm..."
    # Include KC_OPTS here so it doesn't trigger a "Configuration Changed" warning
    "$KC_BIN" import --dir ./keycloak/exports --optimized
}

start_kc() {
    echo "--- Starting Keycloak (Optimized) ---"
    
    # Simple nohup without custom log routing
    nohup "$KC_BIN" start --optimized &
    echo "Keycloak starting on port $PORT."
}

remove_kc_data() {
    echo "Cleaning Keycloak data..."
    rm -rf "$DATA_DIR"

    rm -f "$KC_DIR/providers/"*
}

# --- Scenarios ---
case "$1" in
    "restart")
        stop_kc
        start_kc
        ;;
    "rebuild-themes")
        stop_kc
        build_kc
        start_kc
        ;;
    "fresh-start")
        stop_kc
        remove_kc_data
        build_kc
        import_kc_realm
        create_admin
        start_kc
        ;;
    "stop")
        stop_kc
        ;;
    *)
        echo "Usage: $0 {restart|rebuild-themes|fresh-start|stop}"
        ;;
esac