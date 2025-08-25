#!/bin/bash

# n8n Deployment Script
# This script automates the deployment of n8n using Ansible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if ansible is installed
check_ansible() {
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    print_status "Ansible is installed"
}

# Check if ansible.env exists
check_env_file() {
    if [ ! -f "ansible.env" ]; then
        print_error "ansible.env file not found. Please create it first."
        exit 1
    fi
    print_status "Environment file found"
}

# Load environment variables
load_env() {
    print_status "Loading environment variables..."
    set -a
    source ansible.env
    set +a
}

# Test connection to target server
test_connection() {
    print_status "Testing connection to target server..."
    if ansible n8n_servers -m ping; then
        print_status "Connection successful"
    else
        print_error "Connection failed. Please check your SSH configuration."
        exit 1
    fi
}

# Deploy n8n
deploy_n8n() {
    print_status "Starting n8n deployment..."
    
    # Run the playbook
    if ansible-playbook playbook.yml; then
        print_status "Deployment completed successfully!"
        print_status "n8n is now available at: http://$N8N_HOST_IP:$N8N_PORT"
        print_warning "Default credentials: admin / (check .env file for password)"
    else
        print_error "Deployment failed. Please check the logs above."
        exit 1
    fi
}

# Main execution
main() {
    print_status "Starting n8n deployment process..."
    
    check_ansible
    check_env_file
    load_env
    test_connection
    deploy_n8n
    
    print_status "Deployment process completed!"
}

# Run main function
main "$@"
