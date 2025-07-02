# Installation Guide

This guide explains how to set up your environment to use the `DockerIptables` scripts for managing iptables firewall rules in Docker environments.

## Prerequisites
- **Operating System**: A Linux distribution (e.g., Ubuntu, CentOS, Debian) is recommended, as Docker and iptables are primarily Linux-based.
- **Docker**: Ensure Docker is installed and running.
  - Install on Ubuntu: `sudo apt-get update && sudo apt-get install docker.io`
  - Install on CentOS: `sudo yum install docker`
  - Verify: `docker --version`
- **iptables**: Required for firewall configuration.
  - Install on Ubuntu: `sudo apt-get install iptables`
  - Install on CentOS: `sudo yum install iptables`
  - Verify: `iptables -V`
- **Root Privileges**: All scripts must be run as root (use `sudo` or log in as root).
- **Network Interface**: Identify your main network interface (e.g., `eth0`, `ens33`).
  - Check with: `ip a` or `ifconfig`

## Installation Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/DockerIptables.git
   cd DockerIptables
   ```

2. **Make Scripts Executable**:
   Navigate to the `scripts/` directory and set executable permissions:
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Verify Network Interface**:
   - The scripts use a network interface (e.g., `ens32` in `firewallDockerSupported.sh`). Check your interface:
     ```bash
     ip a
     ```

4. **Test the Environment**:
   - Ensure Docker is running: `sudo systemctl start docker`
   - Verify iptables is functional: `sudo iptables -L`
   - If using a custom interface, test connectivity: `ping 8.8.8.8`

## Notes
- Run all scripts with `sudo` to avoid permission errors.
- Ensure your Docker containers are configured to respect iptables rules (e.g., avoid `--iptables=false` in Docker daemon settings).
- If you encounter issues, check the [Usage Guide](usage.md) for troubleshooting tips.
