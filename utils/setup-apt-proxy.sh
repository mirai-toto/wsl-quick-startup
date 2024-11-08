#!/bin/bash

function activateProxyInAnsible() {
    sed -i "s/^[[:space:]]*use_proxy: false/  use_proxy: true/g" /root/wsl-quick-startup/playbooks/group_vars/all
}

function main() {
    local _http_proxy_host="$1"
    local _https_proxy_host="$2"
    local _no_proxy_host="$3"

    sudo touch /etc/apt/apt.conf

    if [ -n "$_http_proxy_host" ]; then
        echo "Acquire::http::Proxy \"$_http_proxy_host\";" > /etc/apt/apt.conf
        sed -i "s|^[[:space:]]*http_proxy:.*$|  http_proxy: ${_http_proxy_host}|g" /root/wsl-quick-startup/playbooks/group_vars/all
        activateProxyInAnsible
    fi

    if [ -n "$_https_proxy_host" ]; then
        echo "Acquire::https::Proxy \"$_https_proxy_host\";" >> /etc/apt/apt.conf
        sed -i "s|^[[:space:]]*https_proxy:.*$|  https_proxy: ${_https_proxy_host}|g" /root/wsl-quick-startup/playbooks/group_vars/all
        activateProxyInAnsible
    fi

    if [ -n "$_no_proxy_host" ]; then
        sed -i "s|^[[:space:]]*no_proxy:.*$|  no_proxy: ${_no_proxy_host}|g" /root/wsl-quick-startup/playbooks/group_vars/all
    fi
}

main "$@"
