<!-- markdownlint-disable MD032 MD033 MD041 -->
<div align="center">
  <a href="https://github.com/TuxTechLab/TuxTechIaaC">
    <img src="https://avatars.githubusercontent.com/tuxthebot" width="200" alt="TuxTechLab Logo">
    <h1>TuxTechIaaC</h1>
  </a>

  <p align="center">
    <strong>Infrastructure as Code for Modern Cloud-Native Deployments/ HomeLab</strong>
    <br />
    <br>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-GNU%20GPL%20v3-blue.svg" alt="License"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/pulse"><img src="https://img.shields.io/github/commit-activity/m/TuxTechLab/TuxTechIaaC" alt="Commits-per-month"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/commits/main"><img src="https://img.shields.io/github/last-commit/TuxTechLab/TuxTechIaaC" alt="Last Commit"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/graphs/contributors"><img src="https://img.shields.io/github/contributors/TuxTechLab/TuxTechIaaC" alt="Contributors"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/stargazers"><img src="https://img.shields.io/github/stars/TuxTechLab/TuxTechIaaC" alt="Stars"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/network/members"><img src="https://img.shields.io/github/forks/TuxTechLab/TuxTechIaaC" alt="Forks"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/issues"><img src="https://img.shields.io/github/issues/TuxTechLab/TuxTechIaaC" alt="Issues"></a>
    <a href="https://discord.gg/ugHWEWDf"><img src="https://img.shields.io/discord/your-discord-server-id?label=Discord" alt="Discord"></a>
    <br>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/pulls"><img src="https://img.shields.io/github/issues-pr/TuxTechLab/TuxTechIaaC" alt="Open PRs"></a>
    <br>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22"><img src="https://img.shields.io/github/issues/TuxTechLab/TuxTechIaaC/good%20first%20issue" alt="Good First Issues"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22"><img src="https://img.shields.io/badge/Help%20Wanted-Contribute-blue" alt="Help Wanted"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/releases"><img src="https://img.shields.io/github/v/release/TuxTechLab/TuxTechIaaC?include_prereleases" alt="Latest Release"></a>
    <a href="https://github.com/TuxTechLab/TuxTechIaaC/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/TuxTechLab/TuxTechIaaC/ci.yml?label=CI%2FCD" alt="CI/CD Status"></a>
    <!-- <a href="https://github.com/TuxTechLab/TuxTechIaaC/security/policy"><img src="https://img.shields.io/security-headers?url=https%3A%2F%2Ftuxtechlab.com" alt="Security Headers"></a> -->
  </p>
</div>

---

## 📋 Table of Contents

- [🌟 Introduction](#🌟-introduction)
- [🔑 Key Features](#🔑-key-features)
- [🚀 Quick Start](#🚀-quick-start)
- [📁 Project Structure](#📁-project-structure)
- [🔧 Utilities](#🔧-utilities)
- [🤝 Contributing](#🤝-contributing)
- [📄 License](#📄-license)

## 🌟 Introduction

TuxTechIaaC is a comprehensive Infrastructure as Code (IaC) solution built on CNCF technologies, designed to streamline and automate the deployment of production-grade IT infrastructure/ hobby homelab. Our mission is to provide reliable, scalable, and maintainable infrastructure code for modern cloud-native applications.

### 🚀 Key Features

- **Cloud-Agnostic** - Deploy on any cloud provider or on-premises
- **GitOps Ready** - Designed for seamless integration with ArgoCD/Flux ( WIP )
- **Security First** - Built-in security best practices and compliance
- **Modular Design** - Mix and match components as needed
- **Automation Focused** - CI/CD pipelines for infrastructure deployment

## 🛠️ Quick Start

```bash
# Clone the repository
git clone https://github.com/TuxTechLab/TuxTechIaaC.git

# Access the project
cd TuxTechIaaC
```

## 📂 Project Structure

```plaintext
TuxTechIaaC/
│
├── IaaC/                           # Infrastructure as Code configurations
│   └── Templates/                  # Reusable infrastructure templates
│       ├── container/              # Container orchestration templates (Kubernetes, etc.)
│       ├── docker/                 # Docker Compose configurations
│       │   ├── gitea/              # Gitea - Self-hosted Git service
│       │   ├── homepage/           # Custom homepage/dashboard
│       │   │   └── config/         # Homepage configuration files
│       │   ├── jenkins/            # Jenkins CI/CD server
│       │   ├── n8n/                # n8n workflow automation
│       │   ├── portainer/          # Container management UI
│       │   └── sonarqube/          # Code quality and security analysis
│       └── virtual_machine/        # VM templates and configurations
│           ├── custom-configs/     # Custom VM configurations and scripts
│           └── ubuntu-22.04/       # Ubuntu 22.04 LTS template
│
├── iso/                            # ISO and image files
│   ├── containerization/           # Container-related images
│   │   └── k8s/                    # Kubernetes-related images
│   │       └── talos/              # Talos Linux - Kubernetes OS
│   │           └── 1.11.3/         # Version-specific files
│   ├── linux/                      # Linux distribution images
│   │   └── openwrt/                # OpenWRT router firmware
│   │       └── backup/             # Router configuration backups
│   └── networking/                 # Network-related images
│       └── router/                 # Router firmware and tools
│           └── openwrt/            # OpenWRT router configurations
│               └── 24.10.0/        # Version-specific configurations
│
└── scripts/                        # Automation and utility scripts
    ├── core/                       # Core system scripts
    │   ├── gpg_manager/            # GPG key management
    │   │   ├── static/             # Static files for GPG management
    │   │   └── templates/          # Configuration templates
    │   └── iso_manager/            # ISO image management
    │       └── config/             # Configuration files for ISO manager
    ├── network/                    # Network-related scripts
    │   └── router/                 # Router configuration scripts
    └── utils/                      # General utility scripts

# Total: 37 directories
```

## 🔧 Utilities

| Utility | Description | Documentation |
|---------|-------------|---------------|
| **GPG Manager** | Manages GPG keys for secure communication and code signing. Helps in setting up and managing GPG keys for Git commits and other security needs. | [README](scripts/core/gpg_manager/README.md) |
| **ISO Manager** | Handles downloading, verifying, and managing ISO images for various operating systems and tools. Automates the process of keeping your ISO library up-to-date. | [README](scripts/core/iso_manager/README.md) |
| **Network Tools** | Collection of network configuration and diagnostic scripts. Includes tools for router configuration and network troubleshooting. | [README](scripts/network/README.md) |
| **Utility Scripts** | General-purpose utility scripts for common tasks. Includes helper functions and automation scripts used throughout the project. | [README](scripts/utils/README.md) |

## 📚 Documentation

Explore our comprehensive documentation to get started:

- [Getting Started Guide](docs/getting-started.md)
- [Architecture Overview](docs/architecture.md)
- [Deployment Guide](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guide](CONTRIBUTING.md), if you are interested in contributing to this project.

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to all contributors who help make this project better
- Inspired by the CNCF ecosystem and open-source community
- Built with ❤️ by the TuxTechLab team

## 📬 Get in Touch

Have questions or want to contribute? Reach out to us:

- [GitHub Issues](https://github.com/TuxTechLab/TuxTechIaaC/issues)
- [Discord Community](https://discord.gg/ugHWEWDf)

## Security

1. As this repo helps to deploy CNCF application on multi-cloud. Hence there is a very urgent requirement of security and secret management.
2. For Security We Want to use GPG signed commits in this repo. Currently still the setup GPG key is facing issues. Will put a documentation on how to setup GPG signed Git Commit for Windows, Mac, Linux environments.
3. **Also environment variables/ secrects for running application will be shared using demo secrects**. And request anyone who plans to use this solution, to generate/ use their own unique strong password/ secrets. DO NOT USE DEMO ENV SECRETS in Production.

---

<div align="center">
  Made with ❤️ by <a href="https://www.tuxtechlab.com">TuxTechLab</a>
</div>