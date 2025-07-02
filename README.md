# DockerIptables

A straightforward solution to manage iptables firewall rules in Docker environments. It tackles the issue where containers bypass firewall settings because Docker directly tweaks iptables. This project offers a clean, configurable setup to ensure secure and consistent network control for your Docker containers.

## Features
- Configures iptables with the `DOCKER-USER` chain for seamless Docker compatibility.
- Supports custom rules for services like SSH, HTTPS, or other network services.
- Provides scripts to set up, restart, clean specific rules, and reset all firewall configurations.
- Includes an example script with configurable network interface and rules.
- Uses Unix-style (LF) line endings for compatibility with Linux/Docker environments.

## Quick Start
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/DockerIptables.git
   cd DockerIptables
   ```
2. **Set Up Permissions**:
   ```bash
   chmod +x scripts/*.sh
   ```
3. **Configure Rules**:
   - Edit `examples/example-rules.conf` to set your network interface and allowed IPs (see [Usage Guide](docs/usage.md)).
   - Alternatively, use `examples/firewallDockerSupportedExample.sh` as a template.
4. **Run the Main Script**:
   ```bash
   sudo bash scripts/firewallDockerSupported.sh
   ```
5. **Manage the Firewall**:
   - Restart rules: `sudo bash scripts/restartFirewall.sh`
   - Clean specific rules: `sudo bash scripts/clearRules.sh`
   - Reset all rules: `sudo bash scripts/clearAll.sh`

## Documentation
- [Installation Guide](docs/installation.md): How to set up dependencies and prepare your environment.
- [Usage Guide](docs/usage.md): Detailed instructions for using each script.
- [Example Configurations](examples/example-rules.conf): Template for custom rules.

## Notes
- Ensure your network interface matches the one specified in the scripts (default: `ens32`). Check with `ip a`.
- Run scripts with `sudo` to avoid permission errors.
- The repository uses LF line endings (enforced by `.gitattributes`) for Linux/Docker compatibility.
- Save iptables rules before resetting: `sudo iptables-save > backup-rules-$(date +%F).conf`.

## License
Licensed under the MIT License. See [LICENSE](LICENSE) for details.
