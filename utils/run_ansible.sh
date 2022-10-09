#!/bin/bash

# run_ansible.sh
# Usage: ./run_ansible.sh 

TARGET_DIR="/root/wsl-quick-startup"
CONFIG_FILE="$TARGET_DIR/config.cfg"
JSON_CONFIG="$TARGET_DIR/config.json"
CONVERTER_SCRIPT="$TARGET_DIR/utils/cfg_to_json.sh"
PLAYBOOK_DIR="$TARGET_DIR/playbooks"

# Function to check and load configuration
convert_config_to_json() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file $CONFIG_FILE not found."
        exit 1
    fi

    # Convert the configuration file to JSON
    if ! bash "$CONVERTER_SCRIPT" "$CONFIG_FILE" "$JSON_CONFIG"; then
        echo "Failed to convert configuration to JSON."
        exit 1
    fi
    echo "Configuration successfully converted to JSON."
}

# Function to update JSON config with proxy parameters
update_json_with_proxies() {
    http_proxy_wsl=$(jq -r '.http_proxy_wsl // empty' "$JSON_CONFIG")
    https_proxy_wsl=$(jq -r '.https_proxy_wsl // empty' "$JSON_CONFIG")
    no_proxy_wsl=$(jq -r '.no_proxy_wsl // empty' "$JSON_CONFIG")

    if [[ -z "$http_proxy_wsl" && -z "$https_proxy_wsl" ]]; then
        echo "No proxy settings found, skipping JSON update."
        return
    fi

    # Add proxy parameters to JSON config
    jq \
    --arg use_proxy "true" \
    --arg http_proxy "$http_proxy_wsl" \
    --arg https_proxy "$https_proxy_wsl" \
    --arg no_proxy "$no_proxy_wsl" \
    '.proxy_parameters = { use_proxy: $use_proxy, http_proxy: $http_proxy, https_proxy: $https_proxy, no_proxy: $no_proxy }' \
    "$JSON_CONFIG" > "$JSON_CONFIG.tmp" && mv "$JSON_CONFIG.tmp" "$JSON_CONFIG"
    echo "Updated JSON configuration with proxy parameters."
}

# Function to configure apt proxy
configure_apt_proxy() {
    # No jq yet
    http_proxy_wsl=$(grep -E '^http_proxy_wsl=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '"')
    https_proxy_wsl=$(grep -E '^https_proxy_wsl=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '"')

    if [[ -n "$http_proxy_wsl" || -n "$https_proxy_wsl" ]]; then
        echo "Configuring apt proxy..."
        echo "Acquire::http::Proxy \"$http_proxy_wsl\";" | sudo tee /etc/apt/apt.conf
        echo "Acquire::https::Proxy \"$https_proxy_wsl\";" | sudo tee -a /etc/apt/apt.conf
    else
        echo "No apt proxy configuration needed."
    fi
}

# Function to install required packages
install_ansible() {
    echo "Installing Ansible and jq..."
    sudo apt-get update -yqq > /dev/null 2>&1
    sudo apt-get install -yqq ansible jq > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to install Ansible and jq."
        exit 1
    fi
}

# Function to run the Ansible playbook
run_ansible_playbook() {
    echo "Running Ansible playbook..."
    ansible-playbook "$PLAYBOOK_DIR/setup-wsl.yml" -i "$PLAYBOOK_DIR/hosts.ini" \
        --extra-vars "$(cat "$JSON_CONFIG")"
    PLAYBOOK_EXIT_CODE=$?

    if [ $PLAYBOOK_EXIT_CODE -ne 0 ]; then
        echo "Ansible playbook execution failed."
        exit $PLAYBOOK_EXIT_CODE
    fi
    echo "Ansible playbook executed successfully."
}

# Function to check if a reboot is required
check_reboot_required() {
    if [ -f /var/run/reboot-required ]; then
        echo "Reboot required. Exiting with code 100 to signal the need for a reboot."
        exit 100
    fi
}

# Main script execution
main() {
    convert_config_to_json
    configure_apt_proxy
    install_ansible

    # Update JSON with proxy parameters if proxies are present
    update_json_with_proxies

    run_ansible_playbook
    check_reboot_required
}

main
