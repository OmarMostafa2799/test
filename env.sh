#!/bin/bash

set -e

echo "======================================"
echo " Installing DevOps Environment"
echo "======================================"

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Get the actual user who called sudo
REAL_USER="${SUDO_USER:-$(whoami)}"
USER_HOME=$(eval echo "~$REAL_USER")

echo "Installing for user: $REAL_USER"
echo "Home directory: $USER_HOME"

echo ""
echo "[1/8] Updating system packages..."
dnf update -y

echo ""
echo "[2/8] Installing required packages..."
dnf install -y \
    dnf-plugins-core \
    wget \
    curl \
    unzip \
    git \
    python3 \
    python3-pip \
    openssh-clients

echo ""
echo "[3/8] Installing Terraform..."

dnf config-manager --add-repo \
    https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

dnf install -y terraform

echo ""
echo "[4/8] Installing Ansible..."

dnf install -y ansible-core

echo ""
echo "[5/8] Installing AWS CLI..."

AWS_ZIP="/tmp/awscliv2.zip"

curl -fsSL \
    "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "$AWS_ZIP"

rm -rf /tmp/aws

unzip -q "$AWS_ZIP" -d /tmp

/tmp/aws/install --update

rm -rf "$AWS_ZIP" /tmp/aws

echo ""
echo "[6/8] Creating SSH key..."

SSH_DIR="$USER_HOME/.ssh"
PRIVATE_KEY="$SSH_DIR/key"
PUBLIC_KEY="$SSH_DIR/key.pub"

mkdir -p "$SSH_DIR"

chmod 700 "$SSH_DIR"

if [ -f "$PRIVATE_KEY" ]; then
    echo "SSH key already exists:"
    echo "$PRIVATE_KEY"
else
    echo "Generating RSA 4096-bit SSH key..."

    sudo -u "$REAL_USER" ssh-keygen \
        -t rsa \
        -b 4096 \
        -f "$PRIVATE_KEY" \
        -N "" \
        -C "$REAL_USER@$(hostname)"

    echo "SSH key created."
fi

# Fix ownership and permissions
chown -R "$REAL_USER:$REAL_USER" "$SSH_DIR"

chmod 700 "$SSH_DIR"
chmod 600 "$PRIVATE_KEY"
chmod 644 "$PUBLIC_KEY"

echo ""
echo "[7/8] Verifying installations..."

echo ""
echo "========== Git =========="
git --version

echo ""
echo "========== Terraform =========="
terraform version

echo ""
echo "========== Ansible =========="
sudo -u "$REAL_USER" ansible --version

echo ""
echo "========== AWS CLI =========="
aws --version

echo ""
echo "========== Python =========="
python3 --version

echo ""
echo "========== SSH =========="
ssh -V

echo ""
echo "[8/8] SSH Key Information"

echo ""
echo "Private Key:"
echo "$PRIVATE_KEY"

echo ""
echo "Public Key:"
echo "$PUBLIC_KEY"

echo ""
echo "Public Key Content:"
cat "$PUBLIC_KEY"

echo ""
echo "======================================"
echo " DevOps Environment Ready"
echo "======================================"
