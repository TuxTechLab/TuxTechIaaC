# GPG Key Manager

A web-based GPG key management utility that provides an intuitive interface for managing PGP keys, including generation, import/export, and deletion of both public and secret keys.

## Features

- 🔑 Generate new PGP key pairs with customizable parameters
- 📥 Import existing PGP keys
- 📤 Export public and secret keys
- 🗑️ Securely delete keys (passphrase required for secret keys)
- 🔍 View all available public and secret keys
- 🛡️ Secure key storage with proper GnuPG integration
- 🐳 Docker container for easy deployment

## Prerequisites

- Docker and Docker Compose
- Modern web browser

## Quick Start

1. Run the following command:

   ```bash
   cd TuxTechIaaC;
   docker-compose -f scripts/gpg_manager/gpg-key-manager.docker-compose.yml up -d
   ```
2. Access the web interface at `http://localhost:5000` / `http://<ip-addr>:5000`

## Usage

### Generating a New Key
1. Click on "Generate New Key"
2. Fill in the required details (Name, Email, Passphrase)
3. Optionally customize key type, length, and expiration
4. Click "Generate"

### Exporting Keys
1. Locate the key in the key list
2. Click the "Export" button next to the key
3. The key will be downloaded as an ASCII-armored (.asc) file

### Deleting Keys
- **Public Keys**: Gets auto-deleted once the associated Secret Key is deleted.
- **Secret Keys**: 
  1. Click "Delete"
  2. Enter the key's passphrase when prompted
  3. Confirm deletion

## Container Access and GPG Key Management

### Accessing the Docker Container

You can access the running container using the following command:

```bash
docker exec -it gpg-manager /bin/bash
```

### Managing GPG Keys via Command Line

Once inside the container, you can use standard GnuPG commands to manage keys:

1. **List all public keys**:
   ```bash
   gpg --list-keys
   ```

2. **List all secret keys**:
   ```bash
   gpg --list-secret-keys
   ```

3. **Export a public key**:
   ```bash
   gpg --armor --export KEY_ID > public_key.asc
   ```

4. **Export a secret key**:
   ```bash
   # For GnuPG 2.1+ (with passphrase prompt):
   gpg --armor --export-secret-keys KEY_ID > private-gpg-key.asc
   
   # For automated scripts (not recommended for security):
   # gpg --batch --pinentry-mode loopback --passphrase "your_passphrase" --armor --export-secret-keys KEY_ID > private-gpg-key.asc
   ```
   
   **Note:** The first command will prompt for your passphrase. For automated environments, you can use the second command with `--batch` and `--passphrase`, but be aware this is less secure as it exposes your passphrase in the command history.

5. **Import a key**:
   ```bash
   gpg --import key_file.asc
   ```

6. **Delete a public key**:
   ```bash
   gpg --delete-key KEY_ID
   ```

7. **Delete a secret key**:
   ```bash
   gpg --delete-secret-key KEY_ID
   ```

### Running GPG Commands Directly

You can also run GPG commands directly from the host without entering the container:

```bash
# List keys
docker exec gpg-manager gpg --list-keys

# Export a key
docker exec gpg-manager gpg --armor --export KEY_ID > public_key.asc

# Import a key
docker cp your_key.asc gpg-manager:/tmp/your_key.asc
docker exec gpg-manager gpg --import /tmp/your_key.asc
```

### Viewing Container Logs

To monitor the application logs:

```bash
docker logs -f gpg-manager
```

## Security Notes

- All keys are stored in a Docker volume (`gpg_data`)
- Secret key operations require the key's passphrase
- The web interface runs in production mode with secure defaults
- For production use, consider adding HTTPS and authentication

## License

This project is part of the TuxTechIaaC suite and is licensed under the MIT License.
