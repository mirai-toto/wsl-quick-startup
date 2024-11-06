#!/bin/bash

function main() {
    local _http_proxy_host="$1"
    local _https_proxy_host="$2"

    sudo touch /etc/apt/apt.conf

    if [ -n "$_http_proxy_host" ]; then
        echo "Acquire::http::Proxy \"$_http_proxy_host\";" | sudo tee /etc/apt/apt.conf
    fi

    if [ -n "$_https_proxy_host" ]; then
        echo "Acquire::https::Proxy \"$_https_proxy_host\";" | sudo tee -a /etc/apt/apt.conf
    fi
}

main "$@"
