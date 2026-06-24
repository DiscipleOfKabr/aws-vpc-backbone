#!/bin/bash


if  [[ $EUID -ne 0 ]] then
	echo "This script must be run as root (use sudo)"
	exit 1
fi

echo "Updating system . . . "

dnf update -y


echo "Installing dev toolset . . . "

dnf install -y \
    awscli2 \
    git-all \
    golang  \
    nodejs  \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\
    cursor


echo "Installing Cursor IDE..."

TEMP_DIR=$(mktemp -d)

curl -L "$CURSOR_URL" -o "$TEMP_DIR/cursor.rpm"
dnf install -y "$TEMP_DIR/cursor.rpm"

rm -rf "$TEMP_DIR"

echo "Cursor installed successfully!"

if ! command -v terraform &> /dev/null; then
	echo "Installing terraform . . . "
	dnf install -y dnf-plugins-core
	dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
	dnf install -y terraform 
fi
 echo "Starting Docker service  . . ."
 systemctl enable --now docker 

echo "setup complete! Please restart your terminal"

