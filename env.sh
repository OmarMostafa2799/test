#!/bin/bash

set -e

echo "======================================"
echo " Installing DevOps Environment"
echo "======================================"

# ============================================================
# Check root
# ============================================================

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    echo "Example: sudo ./env.sh"
    exit 1
fi

# ============================================================
# Get the actual user who called sudo
# ============================================================

REAL_USER="${SUDO_USER:-$(whoami)}"
USER_HOME=$(eval echo "~$REAL_USER")

echo ""
echo "Installing for user : $REAL_USER"
echo "Home directory      : $USER_HOME"
echo "Hostname            : $(hostname)"

# ============================================================
# [1/9] Update system
# ============================================================

echo ""
echo "[1/9] Updating system packages..."

dnf update -y

# ============================================================
# [2/9] Required packages
# ============================================================

echo ""
echo "[2/9] Installing required packages..."

dnf install -y \
    dnf-plugins-core \
    wget \
    curl \
    unzip \
    git \
    python3 \
    python3-pip \
    bash-completion \
    openssh-clients \
    ca-certificates

# ============================================================
# [3/9] Bash Auto Completion
# ============================================================

echo ""
echo "[3/9] Configuring Bash Auto Completion..."

BASH_COMPLETION="/usr/share/bash-completion/bash_completion"

if [ -f "$BASH_COMPLETION" ]; then

    # Enable system-wide bash completion
    if ! grep -q "$BASH_COMPLETION" /etc/bashrc; then
        cat >> /etc/bashrc <<'EOF'

# Enable Bash Completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
EOF
    fi

    echo "Bash completion enabled."

else
    echo "WARNING: bash-completion file not found."
fi

# ============================================================
# [4/9] Terraform
# ============================================================

echo ""
echo "[4/9] Installing Terraform..."

HASHICORP_REPO="https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo"

dnf config-manager --add-repo "$HASHICORP_REPO"

dnf install -y terraform

echo "Terraform installed."

# ============================================================
# [5/9] Ansible
# ============================================================

echo ""
echo "[5/9] Installing Ansible..."

dnf install -y ansible-core

echo "Ansible installed."

# ============================================================
# [6/9] AWS CLI
# ============================================================

echo ""
echo "[6/9] Installing AWS CLI v2..."

AWS_ZIP="/tmp/awscliv2.zip"
AWS_INSTALL_DIR="/tmp/aws"

# Remove previous temporary files
rm -rf "$AWS_INSTALL_DIR"
rm -f "$AWS_ZIP"

# Download AWS CLI
curl -fsSL \
    "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "$AWS_ZIP"

# Extract
unzip -q "$AWS_ZIP" -d /tmp

# Install / update
/tmp/aws/install --update

# Cleanup
rm -rf "$AWS_INSTALL_DIR"
rm -f "$AWS_ZIP"

# Ensure /usr/local/bin is in PATH
export PATH="/usr/local/bin:$PATH"

# Add permanently to user's bashrc
if ! grep -q 'export PATH="/usr/local/bin:$PATH"' "$USER_HOME/.bashrc" 2>/dev/null; then

    echo "" >> "$USER_HOME/.bashrc"
    echo '# Add /usr/local/bin to PATH' >> "$USER_HOME/.bashrc"
    echo 'export PATH="/usr/local/bin:$PATH"' >> "$USER_HOME/.bashrc"

fi

echo "AWS CLI installed."

# ============================================================
# [7/9] Create SSH Key
# ============================================================

echo ""
echo "[7/9] Creating SSH key..."

SSH_DIR="$USER_HOME/.ssh"

PRIVATE_KEY="$SSH_DIR/id_rsa"
PUBLIC_KEY="$SSH_DIR/id_rsa.pub"

# Create .ssh directory
mkdir -p "$SSH_DIR"

#chmod 700 "$SSH_DIR"

# Create RSA 4096 key if it does not already exist
if [ -f "$PRIVATE_KEY" ]; then

    echo ""
    echo "SSH key already exists:"
    echo "$PRIVATE_KEY"

else

    echo ""
    echo "Generating RSA 4096-bit SSH key..."

    sudo -u "$REAL_USER" ssh-keygen \
        -t rsa \
        -b 4096 \
        -f "$PRIVATE_KEY" \
        -N "" \
        -C "$REAL_USER@$(hostname)"

    echo "SSH key created."

fi

# Fix ownership
chown -R "$REAL_USER:$REAL_USER" "$SSH_DIR"

# Fix permissions
chmod 700 "$SSH_DIR"
chmod 600 "$PRIVATE_KEY"
chmod 644 "$PUBLIC_KEY"

# ============================================================
# [8/9] Configure user environment
# ============================================================

echo ""
echo "[8/9] Configuring user environment..."

USER_BASHRC="$USER_HOME/.bashrc"

# Add /usr/local/bin
if ! grep -q 'export PATH="/usr/local/bin:$PATH"' "$USER_BASHRC" 2>/dev/null; then

    echo "" >> "$USER_BASHRC"
    echo '# DevOps Environment PATH' >> "$USER_BASHRC"
    echo 'export PATH="/usr/local/bin:$PATH"' >> "$USER_BASHRC"

fi

# Enable bash completion for the user
if ! grep -q '/usr/share/bash-completion/bash_completion' "$USER_BASHRC" 2>/dev/null; then

    cat >> "$USER_BASHRC" <<'EOF'

# Enable Bash Completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
EOF

fi

# Terraform autocomplete
echo ""
echo "Configuring Terraform autocomplete..."

if command -v terraform >/dev/null 2>&1; then

    sudo -u "$REAL_USER" bash -c \
        'terraform -install-autocomplete' \
        || echo "WARNING: Terraform autocomplete configuration skipped."

fi

# Fix .bashrc ownership
chown "$REAL_USER:$REAL_USER" "$USER_BASHRC"

# ============================================================
# [9/9] Verification
# ============================================================

echo ""
echo "[9/9] Verifying installations..."

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
/usr/local/bin/aws --version

echo ""
echo "========== Python =========="
python3 --version

echo ""
echo "========== Pip =========="
python3 -m pip --version

echo ""
echo "========== SSH =========="
ssh -V

echo ""
echo "========== Bash Completion =========="

if [ -f "$BASH_COMPLETION" ]; then
    echo "Bash completion: INSTALLED"
else
    echo "Bash completion: NOT FOUND"
fi

# ============================================================
# SSH Key Information
# ============================================================

echo ""
echo "======================================"
echo " SSH Key Information"
echo "======================================"

echo ""
echo "Private Key:"
echo "$PRIVATE_KEY"

echo ""
echo "Public Key:"
echo "$PUBLIC_KEY"

echo ""
echo "Public Key Content:"
echo "--------------------------------------"

cat "$PUBLIC_KEY"

echo "--------------------------------------"

# ============================================================
# Final
# ============================================================

echo ""
echo "======================================"
echo " DevOps Environment Ready"
echo "======================================"

echo ""
echo "Installed:"
echo "  [OK] Git"
echo "  [OK] Terraform"
echo "  [OK] Ansible"
echo "  [OK] AWS CLI"
echo "  [OK] Python"
echo "  [OK] Pip"
echo "  [OK] Bash Completion"
echo "  [OK] OpenSSH"
echo "  [OK] RSA 4096 SSH Key"

echo ""
echo "SSH private key:"
echo "$PRIVATE_KEY"

echo ""
echo "SSH public key:"
echo "$PUBLIC_KEY"

echo ""
echo "IMPORTANT:"
echo "Log out and log back in, or run:"
echo ""
echo "    source ~/.bashrc"
echo ""
echo "to activate all environment changes."

echo ""
echo "======================================"
