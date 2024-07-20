#!/bin/bash

source ./lib.sh

# menu_header
ascii_art
check_env
display_menu


# Main loop
while true; do
    echo""
    read -rp "ENTER YOUR CHOICE: " choice
    echo ""
    case "$choice" in
        1) add_password ;;
        2) remove_password ;;
        3) find_password ;;
        4) view_passwords ;;
        5) change_master_password ;;
        6) delete_all_passwords ;;
        7) update_password;;
        8) show_help ;;
        9) exit 0 ;;
        *)  error_msg "Invalid choice!"
            sleep 0.5
            echo -e "\nHere is your Guide...\n" 
            sleep 1
            display_menu ;;
    esac
    sleep 1
    echo ""
    slow_msg "Press Enter to continue..." 0.05
    read -r

done
