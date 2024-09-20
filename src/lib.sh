#!/bin/bash

# Define colors
NC='\033[0m'
RED='\033[0;31m'
CAYN='\033[0;36m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'

# Load Application Configurations
REPO_URL=$(jq -r ".repo_url" ../config.json)
BRANCH=$(jq -r ".branch" ../config.json)


# Function to display various messages
error_msg() {
    echo -e "${RED}$1${NC}"
}

success_msg() {
    echo -e "${GREEN}$1${NC}"
}

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


# Function to display the main menu
display_menu() {
    info_msg "\n\tMain Menu"
    info_msg "============================"
    info_msg "1. Add a new password"
    info_msg "2. Remove a password"
    info_msg "3. Find a password"
    info_msg "4. View all passwords"
    info_msg "5. Change Master password"
    info_msg "6. Delete all Passwords"
    info_msg "7. Update an existing password"
    info_msg "8. Help"
    info_msg "9. Exit"
    # info_msg "\nPlease choose an option: (1-9)"
}


# Function to check if the .env file exists and if it is properly set up
check_env() {
    if [ ! -f .env ]; then
        echo -e "${RED}Error: .env file not found. \nPlease run setup.sh first.${NC}"
        sleep 3
        exit 1
    fi
}


# Function to add a new password
add_password() {
    read -rp "Enter the name: " name
    read -rp "Enter the password: " password
    encrypted_password=$(encrypt_password "$password")
    jq --arg name "$name" --arg pass "$encrypted_password" '.[$name] = $pass' passwords.json > temp.json && mv temp.json passwords.json
    if [ $? -eq 0 ]; then
        success_msg "\nPassword added successfully!\n"
    else
        error_msg "Error adding password."
    fi
}


# Function to update an existing password
update_password() {
    read -rp "Enter the name of the password to update: " name
    if jq -e "has(\"$name\")" passwords.json > /dev/null; then
        read -rp "Enter the new password: " new_password
        encrypted_password=$(encrypt_password "$new_password")
        jq --arg name "$name" --arg pass "$encrypted_password" '.[$name] = $pass' passwords.json > temp.json && mv temp.json passwords.json
        success_msg "Password updated successfully!"
    else
        error_msg "Password not found!"
    fi
}


# Function to remove a password
remove_password() {
    read -rp "Enter the name of the password to remove: " name
    if jq -e "has(\"$name\")" passwords.json > /dev/null; then
        jq "del(.$name)" passwords.json > temp.json && mv temp.json passwords.json
        success_msg "\nPassword removed successfully!\n"
    else
        error_msg "\nPassword not found!\n"
    fi
}


# Function to find a password
find_password() {
    read -rp "Enter the name of the password to find: " name
    password=$(jq -r --arg name "$name" '.[$name]' passwords.json)
    echo ""
    
    if [ "$password" == "null" ]; then
        error_msg "Password not found!"
    else
        decrypted_password=$(decrypt_password "$password")
        if [ -z "$decrypted_password" ]; then
            error_msg "Error decrypting password."
        else
            info_msg "Password for ($name) :- $decrypted_password"
        fi
    fi
}



# Function to view all passwords
view_passwords() {
    info_msg "\nAll passwords:\n"
    jq -r 'to_entries[] | "\(.key): \(.value)"' passwords.json | while read -r entry; do
        name=$(echo "$entry" | awk -F: '{print $1}')
        encrypted_password=$(echo "$entry" | awk -F: '{print $2}')
        decrypted_password=$(decrypt_password "$encrypted_password")
        echo "$name: $decrypted_password"
    done
}


# Function to change the master password
change_master_password() {
    stored_hashed_password=$(grep "^PASSWORD=" .env | cut -d '=' -f2)
    echo ""
    read -rsp "Enter the current master password: " old_password
    echo ""

    if [ "$(hash_password "$old_password")" != "$stored_hashed_password" ]; then
        error_msg "Incorrect password!"
        sleep 2
        return
    fi

    while true; do
        read -rsp "Enter the new master password: " new_password
        echo ""
        read -rsp "Confirm the new master password: " confirm_password
        echo ""

        if [ "$new_password" != "$confirm_password" ]; then
            error_msg "\nPasswords do not match. Please try again.\n"
            sleep 3
            continue
        fi

        if ! check_password_strength "$new_password"; then
            error_msg "\nPassword must have the following:\n- At least 8 characters long\n- At least one uppercase letter\n- At least one lowercase letter\n- At least one digit\n- At least one special character\n\nPlease try again.\n"
            sleep 3
            continue
        fi

        break
    done

    hashed_password=$(hash_password "$new_password")
    key=$(grep "^KEY=" .env | cut -d '=' -f2)
    echo "PASSWORD=$hashed_password" > .env
    echo "KEY=$key" >> .env
    success_msg "\nMaster password changed successfully!\n"
    sleep 2
}



# Function to delete all passwords
delete_all_passwords() {
    rm -f passwords.json
    echo "{}" > passwords.json
    success_msg "All passwords deleted successfully!"
}


# Function to show help
show_help() {
    info_msg "\n================================================================"
    info_msg "\t\t\tHELP"
    info_msg "================================================================"
    echo ""
    info_msg "1. Add a new password - Adds a new password to the list."
    info_msg "2. Remove a password - Removes a password from the list."
    info_msg "3. Find a password - Finds a password by name."
    info_msg "4. View all passwords - Displays all stored passwords."
    info_msg "5. Change Master password - Changes the master password."
    info_msg "6. Delete all Passwords - Deletes all passwords from the file."
    info_msg "7. Update an existing password - Updates an existing password."
    info_msg "8. Help - Shows this help message."
    info_msg "9. Exit - Exits the program."
    echo ""
}


# Update repository
update_repo() {
    echo -e "Updating repository from $REPO_URL branch $BRANCH..."
    
    # Clone or pull the latest changes
    if [ -d ".git" ]; then
        git fetch origin
        git checkout -b "$BRANCH"
        git pull origin "$BRANCH"
    else
        git clone -b "$BRANCH" "$REPO_URL" .
    fi

    echo ""
    success_msg "Repository updated successfully...\n"
}


# Load encryption key from .env file
load_key() {
    if [ -f ".env" ]; then
        KEY=$(grep '^KEY=' .env | cut -d '=' -f2-)
        if [ -z "$KEY" ]; then
            echo -e "${RED}Error: Encryption key not found in .env file.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: .env file not found.${NC}"
        exit 1
    fi
}


# Encrypt a password
encrypt_password() {
    local plaintext="$1"
    local encrypted_password

    load_key
    encrypted_password=$(echo "$plaintext" | openssl enc -aes-256-cbc -pbkdf2 -salt -base64 -pass pass:"$KEY")
    
    if [ $? -eq 0 ]; then
        echo "$encrypted_password"
    else
        error_msg "Error encrypting password."
        exit 1
    fi
}

# Decrypt a password
decrypt_password() {
    local encrypted_password="$1"
    load_key
    decrypted_password=$(echo "$encrypted_password" | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:"$KEY")

    if [ $? -eq 0 ]; then
        echo "$decrypted_password"
    else
        error_msg "Error decrypting password."
    fi
}


# Function to print a message slowly in magenta color
slow_msg() {
    message="$1"
    delay="${2:-0.1}" 
    echo -en "${MAGENTA}"
    for ((i=0; i<${#message}; i++)); do
        echo -n "${message:$i:1}"
        sleep "$delay"
    done
    echo -e "${NC}"
}


# Function to check password strength
check_password_strength() {
    local pwd="$1"
    local min_length=8
    local max_length=20
    local strength=0

    # Check length
    if [ ${#pwd} -ge $min_length ] && [ ${#pwd} -le $max_length ]; then
        ((strength++))
    fi

    # Check for uppercase letters
    if [[ "$pwd" =~ [A-Z] ]]; then
        ((strength++))
    fi

    # Check for lowercase letters
    if [[ "$pwd" =~ [a-z] ]]; then
        ((strength++))
    fi

    # Check for digits
    if [[ "$pwd" =~ [0-9] ]]; then
        ((strength++))
    fi

    # Check for special characters
    if [[ "$pwd" =~ [^a-zA-Z0-9] ]]; then
        ((strength++))
    fi

    # Return true if the password meets all criteria
    if [ $strength -ge 4 ]; then
        return 0  
    else
        return 1
    fi
}


# Function to display ASCII art for "Password Manager"
ascii_art() {
    local art=$(cat << "EOF"
             __  __                                     
            |  \/  |                                    
            | \  / |  __ _  _ __    __ _   ___  _ __    
            | |\/| | / _` || '_ \  / _` | / _ \| '__|   
            | |  | || (_| || | | || (_| ||  __/| |      
            |_|  |_| \__,_||_| |_| \__, | \___||_|      
                                    __/ |              
                                   |___/               

EOF
    )
    echo -e "${MAGENTA}${art}${NC}"
}


verify_user() {
    local stored_hashed_password=$(grep "^PASSWORD=" .env | cut -d '=' -f2)
    
    if [ -z "$stored_hashed_password" ]; then
        error_msg "Error: Master password not found in .env file."
        exit 1
    fi

    echo ""
    read -rsp "Enter the master password: " password
    echo ""

    if [ "$(hash_password "$password")" != "$stored_hashed_password" ]; then
        error_msg "Incorrect password!"
        sleep 2
        exit 1
    else
        success_msg "Access granted!"
        sleep 1
    fi

}