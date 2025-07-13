#!/bin/bash
set -e

echo "🔧 Setting up EC2 instance for Portfolio deployment..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18.x
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Nginx
echo "Installing Nginx..."
sudo apt install nginx -y

# Install additional tools
sudo apt install git htop curl wget unzip -y

# Start and enable services
sudo systemctl start nginx
sudo systemctl enable nginx

# Create application directory structure
echo "Creating application directories..."
sudo mkdir -p /var/www/portfolio/{releases,shared,backups}
sudo chown -R $USER:$USER /var/www/portfolio

# Copy deployment script
cp deploy.sh /var/www/portfolio/
chmod +x /var/www/portfolio/deploy.sh

# Configure firewall (if ufw is installed)
if command -v ufw > /dev/null; then
    echo "Configuring firewall..."
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    echo "y" | sudo ufw enable
fi

# Create a simple health check endpoint
sudo tee /var/www/html/health.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head><title>Server Health</title></head>
<body>
    <h1>Server is running</h1>
    <p>Last updated: $(date)</p>
</body>
</html>
EOF

echo "EC2 instance setup completed!"
echo "Next steps:"
echo "1. Add your SSH public key to ~/.ssh/authorized_keys"
echo "2. Configure GitHub repository secrets:"
echo "   - EC2_HOST, EC2_USERNAME, EC2_SSH_KEY"
echo "3. Push code to trigger deployment!"
