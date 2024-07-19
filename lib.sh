#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CAYN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display error messages
error_msg() {
    echo -e "${RED}$1${NC}"
}

# Function to display success messages
success_msg() {
    echo -e "${GREEN}$1${NC}"
}

# Function to display info messages
info_msg() {
    echo -e "${CAYN}$1${NC}"
}

# Function to hash the password (example with sha256)
hash_password() {
    echo -n "$1" | sha256sum | awk '{print $1}'
}

# Function to generate an encryption key
generate_encryption_key() {
    openssl rand -hex 32
}
