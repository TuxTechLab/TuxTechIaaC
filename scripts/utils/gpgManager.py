import os
import sys
from pathlib import Path
from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
from datetime import datetime

# Get the directory of the current file
current_dir = Path(__file__).parent.absolute()
# Get the project root (one level up from current_dir)
project_root = current_dir.parent

# Add the project root to the Python path
sys.path.append(str(project_root))

from core.gpg_manager import GPGKeyManager
# Set up paths
template_dir = os.path.join(project_root, 'core', 'gpg_manager', 'templates')
static_dir = os.path.join(project_root, 'core', 'gpg_manager', 'static')

# Initialize Flask app
app = Flask(__name__, template_folder=template_dir, static_folder=static_dir)
app.secret_key = os.urandom(24)

# Initialize GPG key manager
gpg_manager = GPGKeyManager()

# Initialize Git GPG setup
try:
    from core.gpg_manager.git_gpg_setup import GitGPGSetup
    git_gpg = GitGPGSetup(gpg_manager)
except ImportError as e:
    print(f"Warning: Could not import GitGPGSetup: {e}", file=sys.stderr)
    git_gpg = None

# Add timestamp filter
def timestamp_to_date(timestamp, format='%Y-%m-%d %H:%M:%S'):
    if not timestamp:
        return "Never"
    try:
        return datetime.fromtimestamp(timestamp).strftime(format)
    except (ValueError, TypeError):
        return "Unknown"

app.jinja_env.filters['timestamp_to_date'] = timestamp_to_date

# Add current timestamp to all templates
@app.context_processor
def inject_now():
    return {'now': int(datetime.now().timestamp())}

@app.route('/')
def index():
    return redirect(url_for('list_keys'))

@app.route('/keys')
def list_keys():
    public_keys = gpg_manager.list_keys(secret=False)
    secret_keys = gpg_manager.list_keys(secret=True)
    return render_template('keys.html', 
                         public_keys=public_keys, 
                         secret_keys=secret_keys)

@app.route('/keys/generate', methods=['GET', 'POST'])
def generate_key():
    if request.method == 'POST':
        try:
            name = request.form.get('name')
            email = request.form.get('email')
            passphrase = request.form.get('passphrase')
            
            if not all([name, email, passphrase]):
                flash('Name, email, and passphrase are required', 'error')
                return redirect(url_for('generate_key'))
                
            result = gpg_manager.generate_key(
                name=name,
                email=email,
                passphrase=passphrase,
                key_type=request.form.get('key_type', 'RSA'),
                key_length=int(request.form.get('key_length', 4096)),
                expire_date=request.form.get('expire_date', '1y')
            )
            flash('Key generated successfully!', 'success')
            return redirect(url_for('list_keys'))
            
        except Exception as e:
            flash(f'Error generating key: {str(e)}', 'error')
            return redirect(url_for('generate_key'))
    
    return render_template('generate_key.html')

@app.route('/keys/delete/<fingerprint>', methods=['POST'])
def delete_key(fingerprint):
    try:
        secret = request.form.get('secret', 'false').lower() == 'true'
        passphrase = request.form.get('passphrase')
        
        # If no passphrase was provided but one is needed, show the passphrase form
        if secret and not passphrase:
            return render_template('confirm_delete.html', 
                               fingerprint=fingerprint,
                               key_type='Secret' if secret else 'Public',
                               secret=secret,
                               error='Passphrase is required to delete secret keys')
        
        result = gpg_manager.delete_key(fingerprint, secret=secret, passphrase=passphrase)
        
        if result.get('status') == 'success':
            flash('Key deleted successfully!', 'success')
            return redirect(url_for('list_keys'))
        else:
            # If passphrase is required or incorrect, show the form again
            if result.get('requires_passphrase'):
                return render_template('confirm_delete.html',
                                   fingerprint=fingerprint,
                                   key_type='Secret' if secret else 'Public',
                                   secret=secret,
                                   error=result.get('message', 'Passphrase is required'))
            else:
                flash(f'Failed to delete key: {result.get("message", "Unknown error")}', 'error')
                return redirect(url_for('list_keys'))
                
    except Exception as e:
        flash(f'Error deleting key: {str(e)}', 'error')
        return redirect(url_for('list_keys'))

@app.route('/keys/delete/confirm/<fingerprint>', methods=['GET'])
def confirm_delete_key(fingerprint):
    secret = request.args.get('secret', 'false').lower() == 'true'
    return render_template('confirm_delete.html', 
                         fingerprint=fingerprint,
                         key_type='Secret' if secret else 'Public',
                         secret=secret)

@app.route('/keys/export/<fingerprint>', methods=['GET', 'POST'])
def export_key(fingerprint):
    try:
        secret = request.args.get('secret', 'false').lower() == 'true'
        
        # If it's a secret key export, check if we need to ask for a passphrase
        if secret and request.method == 'GET':
            return render_template('export_key.html', 
                                fingerprint=fingerprint,
                                key_type='Secret' if secret else 'Public')
        
        # Get passphrase if this is a POST request for a secret key
        passphrase = None
        if secret and request.method == 'POST':
            passphrase = request.form.get('passphrase')
            if not passphrase:
                return render_template('export_key.html',
                                    fingerprint=fingerprint,
                                    key_type='Secret',
                                    error='Passphrase is required to export secret keys')
        
        # Export the key
        key_data = gpg_manager.export_key(fingerprint, secret=secret, passphrase=passphrase)
        
        # Check if the export returned an error message
        if key_data.startswith('Error:'):
            if 'Incorrect passphrase' in key_data or 'bad passphrase' in key_data.lower():
                return render_template('export_key.html',
                                    fingerprint=fingerprint,
                                    key_type='Secret',
                                    error='Incorrect passphrase')
            else:
                flash(key_data, 'error')
                return redirect(url_for('list_keys'))
        
        # If we get here, the export was successful
        key_type = 'private' if secret else 'public'
        return key_data, 200, {
            'Content-Type': 'application/pgp-keys',
            'Content-Disposition': f'attachment; filename="gpg_{key_type}_key_{fingerprint[-8:]}.asc"'
        }
        
    except Exception as e:
        flash(f'Error exporting key: {str(e)}', 'error')
        return redirect(url_for('list_keys'))

@app.route('/git/setup', methods=['GET', 'POST'])
def git_setup():
    if git_gpg is None:
        flash('Git GPG setup is not available. Please check server logs for details.', 'error')
        return redirect(url_for('list_keys'))
        
    if request.method == 'POST':
        key_fingerprint = request.form.get('key_fingerprint')
        if not key_fingerprint:
            flash('Please select a key', 'error')
            return redirect(url_for('git_setup'))
            
        try:
            result = git_gpg.configure_git(key_fingerprint)
            if result.get('status') == 'success':
                flash('Git GPG Configuration Generated Successfully!', 'success')
                # Get local setup instructions
                setup_instructions = git_gpg.get_local_setup_instructions(
                    result.get('public_key', ''),
                    key_fingerprint
                )
                return render_template('git_setup.html', 
                                    success=True,
                                    public_key=result.get('public_key', ''),
                                    key_fingerprint=key_fingerprint,
                                    git_config=result.get('git_config', {}),
                                    setup_instructions=setup_instructions)
            else:
                flash(f'Error: {result.get("message", "Unknown error")}', 'error')
        except Exception as e:
            flash(f'Error configuring Git: {str(e)}', 'error')
    
    # For GET request or if there was an error
    keys = [
        {
            'fingerprint': key['fingerprint'],
            'key_id': key['key_id'],  # Changed from key['keyid'] to key['key_id']
            'uids': key['uids'],
            'created': key.get('date'),
            'expires': key.get('expires')
        }
        for key in gpg_manager.list_keys(secret=True)  # Only show secret keys that can sign
    ]
    return render_template('git_setup.html', keys=keys)

if __name__ == '__main__':
    # Create required directories if they don't exist
    os.makedirs(template_dir, exist_ok=True)
    os.makedirs(static_dir, exist_ok=True)
    app.run(host='0.0.0.0', port=5000, debug=True)
