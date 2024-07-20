#!/bin/bash

cd src || exit
source lib.sh

echo ""
info_msg "Updating the Application..."

update_repo
.\\setup.sh
cd ..

echo ""
success_msg "Update Complete..."
sleep 3


