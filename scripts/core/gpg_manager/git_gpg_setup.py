#!/usr/bin/env python3
"""
Git GPG Setup Utility

This script helps configure Git to use GPG for commit signing and sets up
GitHub integration with your GPG key.
"""
import os
import sys
import subprocess
import json
from pathlib import Path
from typing import Optional, Dict, List

class GitGPGSetup:
    def __init__(self, gpg_manager):
        """Initialize with a GPGKeyManager instance."""
        self.gpg = gpg_manager.gpg
        self.gnupghome = gpg_manager.gnupghome
        
    def list_keys_for_git(self) -> List[Dict]:
        """List keys in a format suitable for Git configuration."""
        keys = []
        for key in self.gpg.list_keys(True):  # List secret keys
            key_info = {
                'fingerprint': key['fingerprint'],
                'key_id': key['keyid'],
                'uids': key['uids'],
                'created': key.get('date'),
                'expires': key.get('expires'),
            }
            keys.append(key_info)
        return keys
    
    def configure_git(self, key_fingerprint: str, global_config: bool = True) -> Dict:
        """
        Configure Git to use the specified GPG key.
        
        Args:
            key_fingerprint: The fingerprint of the GPG key to use
            global_config: Whether to use global Git config (default: True)
            
        Returns:
            Dict containing status, message, and configuration details
        """
        try:
            # Check if git is available
            try:
                subprocess.run(['git', '--version'], check=True, 
                             capture_output=True, text=True)
            except (subprocess.SubprocessError, FileNotFoundError):
                return {
                    'status': 'error',
                    'message': 'Git is not installed or not in PATH',
                    'requires_git': True
                }
                
            # Set GPG program and signing key
            result = subprocess.run(
                ['git', 'config', '--global' if global_config else '--local', 
                 'user.signingkey', key_fingerprint],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                return {
                    'status': 'error',
                    'message': f'Failed to set Git signing key: {result.stderr}'
                }
            
            # Enable commit signing
            result = subprocess.run(
                ['git', 'config', '--global' if global_config else '--local', 
                 'commit.gpgsign', 'true'],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                return {
                    'status': 'error',
                    'message': f'Failed to enable Git commit signing: {result.stderr}'
                }
            
            # Set GPG program path (important in some environments)
            result = subprocess.run(
                ['git', 'config', '--global' if global_config else '--local', 
                 'gpg.program', 'gpg2'],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                return {
                    'status': 'error',
                    'message': f'Failed to set Git GPG program: {result.stderr}'
                }
            
            # Export public key for GitHub
            try:
                public_key = self.gpg.export_keys(key_fingerprint)
                if not public_key:
                    raise ValueError('Failed to export public key')
            except Exception as e:
                return {
                    'status': 'error',
                    'message': f'Failed to export public key: {str(e)}'
                }
            
            return {
                'status': 'success',
                'message': 'Git GPG configuration updated successfully',
                'public_key': public_key,
                'key_fingerprint': key_fingerprint,
                'git_config': {
                    'user.signingkey': key_fingerprint,
                    'commit.gpgsign': 'true',
                    'gpg.program': 'gpg2'
                }
            }
            
        except subprocess.CalledProcessError as e:
            return {
                'status': 'error',
                'message': f'Failed to configure Git: {str(e)}'
            }
    
    def get_github_instructions(self, public_key: str) -> str:
        """Generate GitHub GPG key setup instructions."""
        return f"""
        To add this GPG key to GitHub:
        
        1. Go to GitHub Settings: https://github.com/settings/keys
        2. Click "New GPG key"
        3. Paste the following public key:
        
        {public_key}
        
        4. Click "Add GPG key"
        5. Verify your GitHub password if prompted
        
        Your commits will now be verified with this GPG key!
        """
        
    def get_local_setup_instructions(self, public_key: str, key_fingerprint: str) -> Dict[str, str]:
        """
        Generate instructions for setting up GPG key locally.
        
        Returns:
            Dict containing different sections of setup instructions
        """
        key_id = key_fingerprint[-16:].lower()
        
        return {
            'export_instructions': f"""
# Export GPG key pair from this container:
docker exec gpg-manager gpg --armor --export {key_fingerprint} > ~/public-gpg-key.asc

# Interactive mode (will prompt for passphrase):
gpg --pinentry-mode loopback --armor --export-secret-keys {key_fingerprint} > private-gpg-key.asc
    
# For automation (not recommended for security):
gpg --batch --pinentry-mode loopback --passphrase "YOUR_PASSPHRASE" --armor --export-secret-keys {key_fingerprint} > private-gpg-key.asc
            """,
            'import_instructions': f"""
# Kill the gpg-agent first:
pkill gpg-agent

# On your local machine, import the GPG keys:

## Public Key
gpg --import ~/public-gpg-key.asc

## Private Key

### Normal
gpg --import ~/private-gpg-key.asc

### Batch with Password
gpg --batch --passphrase "<pass-phase>" --import ~/private-gpg-key.asc

# Verify the keys were imported:
gpg --list-secret-keys --keyid-format LONG {key_id}
""",
            'git_config': f"""
# Configure Git to use your GPG key:
git config --global user.signingkey {key_fingerprint}
git config --global commit.gpgsign true
            
# Optional: Set GPG program (if not using the default)
git config --global gpg.program $(which gpg2 || which gpg)
            
# Verify your Git configuration:
git config --global -l | grep gpg
            """,
            'test_commit': """
# Test GPG signing with a test commit:
mkdir -p ~/test-gpg-commit && cd ~/test-gpg-commit
git init
echo "Test GPG signed commit" > test.txt
git add test.txt
git commit -S -m "Test GPG signed commit"

# Verify the commit signature:
git log --show-signature -1
            """
        }

if __name__ == "__main__":
    # Example usage
    from .gpg_utils import GPGKeyManager
    gpg_manager = GPGKeyManager()
    git_gpg = GitGPGSetup(gpg_manager)
    
    # List available keys
    print("Available GPG keys:")
    for i, key in enumerate(git_gpg.list_keys_for_git(), 1):
        print(f"{i}. {key['key_id']} - {', '.join(key['uids'])}")
    
    if not git_gpg.list_keys_for_git():
        print("No GPG keys found. Please generate one first.")
        sys.exit(1)
    
    # Configure Git with the selected key
    key_fingerprint = git_gpg.list_keys_for_git()[0]['fingerprint']
    result = git_gpg.configure_git(key_fingerprint)
    
    if result['status'] == 'success':
        print("\nGit GPG configuration successful!")
        print(git_gpg.get_github_instructions(result['public_key']))
    else:
        print(f"Error: {result['message']}", file=sys.stderr)
        sys.exit(1)
