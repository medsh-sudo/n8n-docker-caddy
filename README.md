# n8n Server Deployment with Ansible

This Ansible playbook automates the deployment of n8n server using Docker on Ubuntu virtual machines.

## Prerequisites

- Ansible 2.9+ installed on your control machine
- Target Ubuntu server (20.04 LTS or later recommended)
- SSH access to the target server with sudo privileges
- SSH key-based authentication configured

## Project Structure

```
n8n-docker-caddy/
├── playbook.yml              # Main Ansible playbook
├── inventory.yml             # Host inventory configuration
├── ansible.cfg              # Ansible configuration
├── ansible.env              # Environment variables
├── group_vars/
│   └── all.yml              # Global variables
├── templates/
│   ├── env.j2               # Environment variables template
│   ├── docker-compose.yml.j2 # Docker Compose template
│   └── n8n.service.j2       # Systemd service template
└── README.md                # This file
```

## Configuration

### 1. Environment Variables

Edit `ansible.env` file to configure your deployment:

```bash
# Ansible Configuration
ANSIBLE_USER=ubuntu
SSH_KEY_PATH=~/.ssh/id_rsa

# Target Server Configuration
N8N_HOST_IP=192.168.1.100

# n8n Configuration
N8N_PORT=5678
N8N_VERSION=latest
```

### 2. Inventory Configuration

The `inventory.yml` file defines your target hosts. Update the IP address and credentials as needed.

### 3. Global Variables

Edit `group_vars/all.yml` to customize n8n configuration:

- Database settings
- Redis configuration
- Security settings
- Logging preferences

## Usage

### 1. Load Environment Variables

```bash
source ansible.env
```

### 2. Test Connection

```bash
ansible n8n_servers -m ping
```

### 3. Run the Playbook

Deploy n8n server:

```bash
ansible-playbook playbook.yml
```

### 4. Run with Tags

Install only specific components:

```bash
# Install packages only
ansible-playbook playbook.yml --tags packages

# Install Docker only
ansible-playbook playbook.yml --tags docker

# Deploy n8n only
ansible-playbook playbook.yml --tags n8n
```

### 5. Check Status

```bash
# Check n8n service status
ansible n8n_servers -m shell -a "systemctl status n8n"

# Check Docker containers
ansible n8n_servers -m shell -a "docker ps"
```

## What Gets Installed

1. **System Packages**: Required packages for Docker installation
2. **Docker**: Latest Docker CE with Docker Compose
3. **n8n**: n8n server with PostgreSQL and Redis
4. **Systemd Service**: Automatic startup and management

## Services

The playbook creates the following services:

- **n8n**: Main n8n application (port 5678)
- **PostgreSQL**: Database for n8n
- **Redis**: Cache and session storage

## Access

After successful deployment, access n8n at:

```
http://YOUR_SERVER_IP:5678
```

Default credentials:
- Username: `admin`
- Password: Generated automatically (check logs or .env file)

## Security

- Basic authentication is enabled by default
- Passwords are generated automatically
- All sensitive data is stored in environment variables
- Database and Redis are password-protected

## Troubleshooting

### Check Logs

```bash
# n8n logs
ansible n8n_servers -m shell -a "docker logs n8n"

# PostgreSQL logs
ansible n8n_servers -m shell -a "docker logs n8n-postgres"

# Redis logs
ansible n8n_servers -m shell -a "docker logs n8n-redis"
```

### Restart Services

```bash
# Restart n8n service
ansible n8n_servers -m systemd -a "name=n8n state=restarted"

# Restart Docker containers
ansible n8n_servers -m shell -a "cd /opt/n8n && docker-compose restart"
```

### Clean Installation

To start fresh:

```bash
# Stop and remove containers
ansible n8n_servers -m shell -a "cd /opt/n8n && docker-compose down -v"

# Remove data directories
ansible n8n_servers -m file -a "path=/opt/n8n state=absent"

# Re-run playbook
ansible-playbook playbook.yml
```

## Backup and Restore

### Backup

```bash
# Backup n8n data
ansible n8n_servers -m shell -a "cd /opt/n8n && docker-compose exec postgres pg_dump -U n8n n8n > backup.sql"

# Backup volumes
ansible n8n_servers -m shell -a "docker run --rm -v n8n_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data ."
```

### Restore

```bash
# Restore database
ansible n8n_servers -m shell -a "cd /opt/n8n && docker-compose exec -T postgres psql -U n8n n8n < backup.sql"
```

## Monitoring

The playbook includes basic monitoring:

- Service status checks
- Health endpoint verification
- Automatic restart on failure

## Support

For issues and questions:

1. Check the n8n documentation: https://docs.n8n.io/
2. Review Ansible logs: `ansible-playbook playbook.yml -v`
3. Check system logs: `journalctl -u n8n`

## License

This project is open source and available under the MIT License.
