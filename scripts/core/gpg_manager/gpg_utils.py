import gnupg
import os
from typing import Dict, List, Optional

class GPGKeyManager:
    def __init__(self, gnupghome: str = None):
        """
        Initialize GPG key manager
        
        Args:
            gnupghome: Path to the GnuPG home directory. If None, uses system default.
        """
        self.gnupghome = gnupghome or os.path.join(os.path.expanduser('~'), '.gnupg')
        self.gpg = gnupg.GPG(gnupghome=self.gnupghome)
        
    def generate_key(self, name: str, email: str, passphrase: str, key_type: str = 'RSA', 
                    key_length: int = 4096, expire_date: str = '1y') -> Dict:
        """
        Generate a new GPG key pair
        
        Args:
            name: Name of the key owner
            email: Email of the key owner
            passphrase: Passphrase for the key
            key_type: Type of key to generate (RSA, DSA, etc.)
            key_length: Length of the key in bits
            expire_date: Key expiration date (e.g., '1y' for 1 year, '0' for no expiration)
            
        Returns:
            Dictionary containing key generation result
        """
        input_data = self.gpg.gen_key_input(
            key_type=key_type,
            key_length=key_length,
            name_real=name,
            name_email=email,
            passphrase=passphrase,
            expire_date=expire_date
        )
        
        key = self.gpg.gen_key(input_data)
        if key.fingerprint:
            # The key_id is the last 16 characters of the fingerprint
            key_id = key.fingerprint[-16:].upper()
            return {
                'fingerprint': key.fingerprint,
                'key_id': key_id,
                'status': 'Key generated successfully'
            }
        return {
            'status': 'Key generation failed',
            'error': str(key.stderr) if hasattr(key, 'stderr') else 'Unknown error'
        }
    
    def list_keys(self, secret: bool = False) -> List[Dict]:
        """
        List all available GPG keys
        
        Args:
            secret: If True, list secret keys. Otherwise, list public keys.
            
        Returns:
            List of key information dictionaries with proper type conversion
        """
        keys = self.gpg.list_keys(secret=secret)
        result = []
        for key in keys:
            # Convert date and expires to integers, defaulting to 0 if empty or invalid
            try:
                date = int(key['date']) if key['date'] else 0
            except (ValueError, TypeError):
                date = 0
                
            try:
                expires = int(key['expires']) if key['expires'] else 0
            except (ValueError, TypeError):
                expires = 0
                
            result.append({
                'key_id': key['keyid'],
                'fingerprint': key['fingerprint'],
                'uids': key['uids'],
                'date': date,
                'expires': expires
            })
        return result
    
    def delete_key(self, fingerprint: str, secret: bool = False, passphrase: str = None) -> Dict:
        """
        Delete a GPG key
        
        Args:
            fingerprint: Fingerprint of the key to delete
            secret: If True, delete secret key. Otherwise, delete public key.
            passphrase: Passphrase for the key (required for deletion)
            
        Returns:
            Dictionary with operation status and message
        """
        try:
            # First delete the secret key if it exists
            if secret:
                if not passphrase:
                    return {'status': 'failed', 'message': 'Passphrase is required to delete secret keys', 'requires_passphrase': True}
                    
                secret_result = self.gpg.delete_keys(fingerprint, secret=True, passphrase=passphrase)
                if not secret_result:
                    return {'status': 'failed', 'message': 'Failed to delete secret key. Incorrect passphrase?', 'requires_passphrase': True}
            
            # Always try to delete the public key
            public_result = self.gpg.delete_keys(fingerprint, secret=False)
            if not public_result and not secret:  # Only fail if we weren't trying to delete a secret key
                return {'status': 'failed', 'message': 'Failed to delete public key'}
                
            return {'status': 'success', 'message': 'Key deleted successfully'}
            
        except Exception as e:
            return {'status': 'error', 'message': str(e), 'requires_passphrase': True}
    
    def export_key(self, fingerprint: str, secret: bool = False, 
                  passphrase: str = None) -> str:
        """
        Export a GPG key
        
        Args:
            fingerprint: Fingerprint of the key to export
            secret: If True, export secret key
            passphrase: Passphrase for the key (required for secret key export)
            
        Returns:
            ASCII armored key data or error message if export fails
        """
        try:
            # For secret key export, we need to use a different approach
            if secret:
                if not passphrase:
                    return "Error: Passphrase is required to export secret keys"
                
                # Use --pinentry-mode loopback to allow passphrase input
                import subprocess
                cmd = [
                    'gpg',
                    '--batch',
                    '--pinentry-mode', 'loopback',
                    '--passphrase', passphrase,
                    '--armor',
                    '--export-secret-keys',
                    fingerprint
                ]
                
                result = subprocess.run(
                    cmd,
                    cwd=self.gnupghome,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode != 0:
                    error_msg = result.stderr or 'Unknown error exporting secret key'
                    if 'bad passphrase' in error_msg.lower():
                        return "Error: Incorrect passphrase"
                    return f"Error exporting key: {error_msg}"
                    
                return result.stdout
                
            # For public key export, use the standard method
            return str(self.gpg.export_keys(fingerprint, secret=False))
            
        except Exception as e:
            return f"Error exporting key: {str(e)}"
    
    def import_key(self, key_data: str) -> Dict:
        """
        Import a GPG key
        
        Args:
            key_data: ASCII armored key data
            
        Returns:
            Dictionary with import result
        """
        import_result = self.gpg.import_keys(key_data)
        return {
            'imported': import_result.count,
            'fingerprints': import_result.fingerprints,
            'results': import_result.results
        }
