# 🛡️ Password Manager

## Overview

The Password Manager is a secure tool designed to manage and protect your passwords. It includes features like encryption, decryption, and password strength checking.

## Prerequisites ⚙️

Before you start, make sure you have the following installed on your system:

- **Git**: To clone the repository.
- **Bash**: The scripts are written in Bash, so you need a compatible shell.
- **OpenSSL**: For encryption and decryption functionalities.
- **jq**: For JSON processing.
- **A Unix-like environment**: This application is primarily designed for Unix-like systems (Linux, macOS). Windows users may need a Bash-compatible environment like `Git Bash`.


## Getting Started 🚀

To get started with the Password Manager, follow these steps:

### 1. Clone the Repository
Clone the repository to your local machine:
```bash
git clone https://github.com/deepesh611/Shell-Password-Manager.git
cd Shell-Password-Manager
```
### 2. Update or Setup the Application
Run the update.sh script to update or set up the application:
```bash
./update.sh
```

### Run the Application
To launch the Password Manager, execute:
```bash
./Password-Manager.sh
```

## Scripts 📝
- **lib.sh:** Contains utility functions for password management, including encryption and decryption.
- **main.sh:** Manages user interactions and the main logic of the application.
- **setup.sh:** Initializes the application with a master password and encryption key.
- **update.sh:** Updates the application or sets it up if it's the first run.
- **Password-Manager.sh:** Launches the Password Manager application.

## Notes 📝
- Ensure you have execution permissions for the scripts. Use `chmod +x <script-name>` to modify permissions.
- The `.env` file will be created or updated during setup and contains sensitive information. Keep it secure.

## License 📜
This project is licensed under the [GNU GENERAL PUBLIC LICENSE](LICENSE).

