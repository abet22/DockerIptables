# Usage Guide

This guide explains how to use the scripts in the `DockerIptables` repository to manage iptables firewall rules in Docker environments. Each script serves a specific purpose, from setting up rules to resetting the firewall.

## Overview of Scripts
- **`firewallDockerSupported.sh`**: Configures iptables rules to secure Docker containers, using the `DOCKER-USER` and `FILTERS` chains to prevent Docker from bypassing firewall settings.
- **`restartFirewall.sh`**: Cleans specific rules from the `FILTERS` chain and reapplies the configuration from `firewallDockerSupported.sh`.
- **`clearRules.sh`**: Removes specific rules from the `FILTERS` chain and clears logging chains (`LOGDROPG`, `LOGACCEPTG`, `NOLOGDROPG`) without affecting Docker.
- **`clearAll.sh`**: Resets all iptables rules and disables IP forwarding, providing a clean slate.

## Using the Scripts
Run all scripts with `sudo` from the `scripts/` directory:
```bash
cd DockerIptables/scripts
sudo bash <script_name>.sh
```

### 1. Setting Up the Firewall
Use `firewallDockerSupported.sh` to configure iptables for Docker:
```bash
sudo bash firewallDockerSupported.sh
```
- **What it does**: Creates `DOCKER-USER` and `FILTERS` chains, sets default policies (`FORWARD DROP`, `INPUT ACCEPT`, `OUTPUT ACCEPT`), allows loopback and ICMP traffic, and provides a template for custom rules.
- **Customization**:
  - Add specific rules (e.g., for SSH or HTTPS) in the `SPECIFIC RULES` section of the script.
  - You can add sample rules for SSH (port 22) and HTTPS (port 443) directly in the `SPECIFIC RULES` section of the script.
  - Define variables like `MAIN_INTERFACE`, `SSH_ALLOWED_IP`, and `HTTPS_ALLOWED_IP` at the top of your script if needed, and source your own configuration file if you wish.
**Example**:
  ```bash
  # In firewallDockerSupported.sh
  # Optionally source your own config file
  # source ./my-firewall-config.conf
  $IPTABLES -A DOCKER-USER -i $MAIN_INTERFACE -j FILTERS
  $IPTABLES -A FILTERS -m conntrack --ctorigsrc $SSH_ALLOWED_IP --ctorigdstport 22 -j ACCEPT
  $IPTABLES -A FILTERS -m conntrack --ctorigsrc $HTTPS_ALLOWED_IP --ctorigdstport 443 -j ACCEPT
  ```

### 2. Restarting the Firewall
Use `restartFirewall.sh` to refresh the firewall configuration:
```bash
sudo bash restartFirewall.sh
```
- **What it does**: Removes non-essential rules from the `FILTERS` chain (excluding `ESTABLISHED` rules) and reapplies rules by running `firewallDockerSupported.sh`.
- **Use case**: Run this when you update custom rules and want to apply them without resetting the entire firewall.

### 3. Cleaning Specific Rules
Use `clearRules.sh` to remove specific rules and logging chains:
```bash
sudo bash clearRules.sh
```
- **What it does**: Deletes rules from the `FILTERS` chain (excluding `ESTABLISHED` rules) and clears logging chains (`LOGDROPG`, `LOGACCEPTG`, `NOLOGDROPG`).
- **Use case**: Use this to remove custom rules without affecting Docker's core configuration.

### 4. Resetting All Firewall Rules
Use `clearAll.sh` to completely reset the firewall:
```bash
sudo bash clearAll.sh
```
- **What it does**: Clears all rules in the `nat` and `filter` tables, deletes user-defined chains, sets permissive policies (`INPUT ACCEPT`, `FORWARD ACCEPT`), and disables IP forwarding.
- **Warning**: This may disrupt Docker networking. Run `firewallDockerSupported.sh` afterward to restore your configuration.

## Verifying Rules
After running any script, check the active iptables rules:
```bash
sudo iptables -L -v -n
```
For detailed output, including table names:
```bash
sudo iptables-save
```

## Notes
**Network Interface**: Ensure the network interface (e.g., `ens32`) matches your system. Check with `ip a` and update `firewallDockerSupported.sh` as needed.
- **Logging Chains**: The `LOGDROPG`, `LOGACCEPTG`, and `NOLOGDROPG` chains are used for logging. These are not created by the provided scripts; ensure they exist or remove references in `clearRules.sh` if not needed.
- **Docker Compatibility**: The scripts use the `DOCKER-USER` chain to ensure Docker respects your firewall rules. Avoid modifying Docker's default chains directly.
- **Backups**: Before running `clearAll.sh`, save your current rules:
  ```bash
  sudo iptables-save > backup-rules-$(date +%F).conf
  ```
