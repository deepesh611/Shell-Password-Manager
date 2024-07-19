#!/bin/bash

source ./lib.sh


info_msg "\nStarting setup...\n"
sleep 1

# Check if .env file already exists
if [ -f .env ]; then
    info_msg "The setup is already complete. Only the password can be changed."
    echo "Do you want to change the master password? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        success_msg "Exiting setup..."
        sleep 2
        exit 0
    fi

    # Read the stored hashed password
    stored_hashed_password=$(grep "^PASSWORD=" .env | cut -d '=' -f2)

    # Prompt user for current password and verify it
    read -rsp "Enter current master password: " current_password
    echo ""
    hashed_current_password=$(hash_password "$current_password")

    if [ "$hashed_current_password" != "$stored_hashed_password" ]; then
        error_msg "Current password is incorrect. Exiting..."
        sleep 3
        exit 1
    fi

    # Prompt user for new password
    read -rsp "Enter new master password: " new_password
    echo ""
    read -rsp "Confirm new master password: " confirm_password
    echo ""

    if [ "$new_password" != "$confirm_password" ]; then
        error_msg "\nPasswords do not match. Exiting..."
        sleep 3
        exit 1
    fi

    # Hash the new master password
    new_hashed_password=$(hash_password "$new_password")

    # Update password in .env file
    sed -i "s/^PASSWORD=.*/PASSWORD=$new_hashed_password/" .env
    success_msg "Password updated successfully."

else
    # Prompt user for master password
    read -rsp "Create a master password: " master_password
    echo ""
    read -rsp "Confirm your master password: " confirm_password
    echo ""

    if [ "$master_password" != "$confirm_password" ]; then
        error_msg "Passwords do not match. Exiting..."
        sleep 3
        exit 1
    fi

    # Hash the master password and generate encryption key
    hashed_password=$(hash_password "$master_password")
    encryption_key=$(generate_encryption_key)

    # Save credentials
    echo "PASSWORD=$hashed_password" > .env
    echo "KEY=$encryption_key" >> .env

    success_msg "\nSetup Complete...\n"
    sleep 3
fi
