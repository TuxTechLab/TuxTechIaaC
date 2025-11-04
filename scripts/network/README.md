# Network Scripts

This directory contains network-related scripts for managing and troubleshooting network configurations in the TuxTechIaaC environment.

## 📋 Table of Contents

- [🌐 Overview](#🌐-overview)
- [🛠️ Available Scripts](#🛠️-available-scripts)
- [🚀 Usage](#🚀-usage)
- [📦 Dependencies](#📦-dependencies)
- [🤝 Contributing](#🤝-contributing)
- [📄 License](#📄-license)

## 🌐 Overview

The network scripts provide automation for common network tasks including router configuration, network diagnostics, and connectivity testing. These scripts are designed to work in both development and production environments.

## 🛠️ Available Scripts

### Router Configuration

- `router/openwrt-firmware-manager.sh` - Manages OpenWRT firmware operations including backup, restore, and update of router firmware

### Network Diagnostics
- `network_scan.sh` - Scans the local network for devices
- `port_scanner.sh` - Checks for open ports on specified hosts
- `speed_test.sh` - Tests network speed and latency
- `vpn_status.sh` - Checks VPN connection status

### Connectivity Tools
- `check_connectivity.sh` - Verifies internet and local network connectivity
- `dns_check.sh` - Tests DNS resolution and response times
- `proxy_tester.sh` - Tests proxy server connectivity and speed

## 🚀 Usage

### Basic Usage

```bash
# Make the script executable
chmod +x scripts/network/<script_name>.sh

# Run the desired script
./scripts/network/<script_name>.sh [options]
```

### Example: Network Scan

```bash
# Run network scan
./scripts/network/network_scan.sh --range 192.168.1.0/24
```

### Example: Router Configuration

```bash
# Backup router config
./scripts/network/router/backup_config.sh --router 192.168.1.1 --user admin
```

## 📦 Dependencies

- `nmap` - Network scanning and discovery
- `iproute2` - Network configuration tools
- `curl` or `wget` - For downloading files and API interactions
- `jq` - For JSON processing
- `ping` and `traceroute` - Basic network diagnostics

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](https://github.com/TuxTechLab/TuxTechIaaC/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the GNU GPL v3 License - see the [LICENSE](https://github.com/TuxTechLab/TuxTechIaaC/LICENSE) file for details.

## 📞 Support

For support, please open an issue in the [issue tracker](https://github.com/TuxTechLab/TuxTechIaaC/issues) or contact the maintainers.
