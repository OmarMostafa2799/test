#!/bin/bash

set -e

echo "======================================"
echo " Installing Terraform and Ansible"
echo "======================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

echo "[1/6] Updating system packages..."
dnf update -y

echo "[2/6] Installing required packages..."
dnf install -y dnf-plugins-core wget unzip git python3 python3-pip

echo "[3/6] Installing Terraform..."

# Add HashiCorp repository
dnf config-manager --add-repo \
https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

dnf install -y terraform

echo "[4/6] Installing Ansible..."

# Install Ansible
dnf install -y ansible-core

echo "[5/6] Verifying installations..."

echo ""
echo "Terraform version:"
terraform version

echo ""
echo "Ansible version:"
ansible --version

echo ""
echo "Python version:"
python3 --version

echo ""
echo "Git version:"
git --version

echo ""
echo "======================================"
echo " Installation completed successfully"
echo "======================================"
