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
echo "[1/7] Updating system packages..."
dnf update -y

echo ""
echo "[2/7] Installing required packages..."
dnf install -y \
    dnf-plugins-core \
    wget \
    unzip \
    git \
    python3 \
    python3-pip \
    openssh-clients

echo ""
echo "[3/7] Installing Terraform..."

dnf config-manager --add-repo \
    https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

dnf install -y terraform

echo ""
echo "[4/7] Installing Ansible..."

dnf install -y ansible-core

echo ""
echo "[5/7] Installing AWS CLI..."

# Install AWS CLI v2
AWS_ZIP="/tmp/awscliv2.zip"

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "$AWS_ZIP"

rm -rf /tmp/aws

unzip -q "$AWS_ZIP" -d /tmp

/tmp/aws/install --update

rm -rf "$AWS_ZIP" /tmp/aws

echo ""
echo "[6/7] Creating SSH key..."

SSH_DIR="$USER_HOME/.ssh"
PRIVATE_KEY="$SSH_DIR/key"
PUBLIC_KEY="$SSH_DIR/key.pub"

# Create .ssh directory
mkdir -p "$SSH_DIR"

chmod 700 "$SSH_DIR"

# Create key only if it doesn't already exist
if [ -f "$PRIVATE_KEY" ]; then
    echo "SSH private key already exists:"
    echo "$PRIVATE_KEY"
else
    echo "Generating RSA 4096-bit SSH key..."

    sudo -u "$REAL_USER" ssh-keygen \
        -t rsa \
        -b 4096 \
        -f "$PRIVATE_KEY" \
        -N "" \
        -C "$REAL_USER@$(hostname)"

    echo "SSH key created:"
    echo "Private key: $PRIVATE_KEY"
    echo "Public key : $PUBLIC_KEY"
fi

# Fix permissions
chown -R "$REAL_USER:$REAL_USER" "$SSH_DIR"

chmod 700 "$SSH_DIR"
chmod 600 "$PRIVATE_KEY"
chmod 644 "$PUBLIC_KEY"

echo ""
echo "[7/7] Verifying installation..."

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
echo "========== SSH Key =========="
ls -l "$PRIVATE_KEY"
ls -l "$PUBLIC_KEY"

echo ""
echo "======================================"
echo " DevOps Environment Ready"
echo "======================================"

echo ""
echo "SSH Private Key:"
echo "$PRIVATE_KEY"

echo ""
echo "SSH Public Key:"
echo "$PUBLIC_KEY"

echo ""
echo "Public Key:"
cat "$PUBLIC_KEY"

echo ""
echo "======================================"
