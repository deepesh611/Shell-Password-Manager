#!/bin/bash

source ./lib.sh


info_msg "\nStarting setup...\n"
sleep 1

# Check if .env file already exists
if [ -f .env ]; then
    info_msg "The setup has previously done. Only the password can be changed."
    echo "Do you want to change the master password? (y/n)"
    read -r response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    
    if [ "$response" != "y" ]; then
        echo ""
        success_msg "Exiting setup..."
        sleep 2
        exit 0
    fi

    change_master_password

else
    while true; do
        # Prompt user for master password
        read -rsp "Create a master password: " master_password
        echo ""
        read -rsp "Confirm your master password: " confirm_password
        echo ""

        if [ "$master_password" != "$confirm_password" ]; then
            error_msg "\nPasswords do not match. Please try again.\n"
            sleep 3
            continue
        fi

        if ! check_password_strength "$master_password"; then
            error_msg "\nPassword must have the following:\n- At least 8 characters long\n- At least one uppercase letter\n- At least one lowercase letter\n- At least one digit\n- At least one special character\n\nPlease try again.\n"
            sleep 3
            continue
        fi

        break
    done

    # Hash the master password and generate encryption key
    hashed_password=$(hash_password "$master_password")
    encryption_key=$(generate_encryption_key)

    # Save credentials
    echo "PASSWORD=$hashed_password" > .env
    echo "KEY=$encryption_key" >> .env
    echo "{}" > passwords.json

    success_msg "\nSetup Complete...\n"
    sleep 2
fi
