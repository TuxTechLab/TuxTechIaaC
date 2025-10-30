# ISO Manager

A powerful, tag-based ISO download and management tool with checksum verification and rich terminal interface.

## Features

1. 🏷️ Tag-based organization of ISOs
2. ✅ Automatic checksum verification
3. 📊 Rich terminal interface with progress bars
4. 🔍 Filter ISOs by category
5. 🔄 Resume interrupted downloads
6. 🔒 Verify file integrity with multiple hash algorithms

## Utility Structure

```bash
scripts/
├── core/
│ └── iso_manager/
│ ├── init.py
│ ├── iso_manager.py   # Main ISO manager script 
│ ├── requirements.txt # Python dependencies 
│ └── config/
│ └── config.yml       # ISO Configuration file 
└── utils/
└── isoManager.sh      # Shell wrapper script
```

## Prerequisites

- Python 3.8+
- pip (Python package manager)
- Required Python packages (installed automatically):
  - `pyyaml`
  - `requests`
  - `rich`

## Installation

1. Make the wrapper script executable:
   ```bash
   chmod +x scripts/isoManager.sh
   ```
2. Install dependencies:
   ```bash
   ./scripts/isoManager.sh install
   ```
3. Run the ISO manager:
   ```bash
   ./scripts/isoManager.sh
   ```
## Usage

### Basic Usage ( **Interactive Mode** )

```bash
cd TuxTechIaaC;
./scripts/utils/isoManager.sh
```

### Command Line Options

- `./scripts/isoManager.sh` - Start the interactive ISO manager
- `./scripts/isoManager.sh install` - Install/update Python dependencies

### Using the Interactive Menu

1. Select a category from the main menu
2. Choose an ISO to download
3. The manager will handle the download and verification

## Configuration

The configuration file is located at `scripts/core/iso_manager/config/config.yml`.

> Example Configuration

```
tags:
  - name: "Linux Distributions"
    description: "Popular Linux distributions"
    icon: "🐧"

isos:
  - name: "Example ISO 1.0.0"
    version: "1.0.0"
    platform: "amd64/x86"
    fileName: "example.iso"
    checkSum: "asdadasdasdASDSA"
    checkSumAlgo: "sha256/md5"
    downloadLink: "https://example.com/example.iso"
    downloadLocation: "example/example/22.04"
    tags: ["Linux Distributions"]
```

## Adding New ISOs

1. Edit the config.yml file
2. Add a new entry under the isos section
3. Specify the appropriate tags
4. Save the file and restart the manager

## Troubleshooting

1. Missing Dependencies:
```bash
./scripts/isoManager.sh install
```
2. Permission Denied:
```bash
chmod +x scripts/isoManager.sh
```
3. Invalid Checksum:

- Verify the checksum in the config file
- Redownload the file with --force (if implemented)