#!/usr/bin/env python3
import os
import sys
import yaml
import hashlib
import requests
from pathlib import Path
from typing import Dict, List, Optional, Set
from urllib.parse import urlparse

from rich.console import Console
from rich.panel import Panel
from rich.progress import (
    BarColumn,
    DownloadColumn,
    Progress,
    TextColumn,
    TimeRemainingColumn,
    TransferSpeedColumn,
)
from rich.table import Table
from rich.prompt import Prompt

class ISOManager:
    def __init__(self, config_path: str = None):
        self.console = Console()
        self.repo_root = Path(__file__).resolve().parent.parent.parent.parent
        self.config_path = config_path or self.repo_root / 'scripts' / 'core' / 'iso_manager' / 'config' / 'config.yml'
        self.config = self._load_config()
        self.iso_base_dir = self.repo_root / 'iso'

    def _load_config(self) -> Dict:
        """Load and validate the YAML configuration."""
        try:
            with open(self.config_path, 'r') as f:
                config = yaml.safe_load(f)
            return config or {}
        except Exception as e:
            self.console.print(f"[bold red]Error loading config:[/] {e}")
            return {}

    def _get_checksum(self, file_path: Path, algorithm: str = 'sha256') -> str:
        """Calculate checksum of a file."""
        hash_func = getattr(hashlib, algorithm.lower(), None)
        if not hash_func:
            raise ValueError(f"Unsupported hash algorithm: {algorithm}")

        h = hash_func()
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                h.update(chunk)
        return h.hexdigest()

    def _download_file(self, url: str, dest: Path) -> bool:
        """Download a file with rich progress bar."""
        try:
            dest.parent.mkdir(parents=True, exist_ok=True)
            response = requests.get(url, stream=True)
            response.raise_for_status()
            
            total_size = int(response.headers.get('content-length', 0))
            chunk_size = 8192

            with Progress(
                TextColumn("[bold blue]{task.description}"),
                BarColumn(bar_width=None),
                "[progress.percentage]{task.percentage:>3.0f}%",
                "•",
                DownloadColumn(),
                "•",
                TransferSpeedColumn(),
                "•",
                TimeRemainingColumn(),
                console=self.console,
                transient=True,
            ) as progress:
                task = progress.add_task(f"Downloading {dest.name}...", total=total_size)
                
                with open(dest, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=chunk_size):
                        f.write(chunk)
                        progress.update(task, advance=len(chunk))
            
            return True
        except Exception as e:
            self.console.print(f"[bold red]Download failed:[/] {e}")
            return False

    def verify_iso(self, iso_path: Path, expected_hash: str, algorithm: str = 'sha256') -> bool:
        """Verify ISO checksum with rich output."""
        if not iso_path.exists():
            return False
        
        try:
            with self.console.status(f"[cyan]Verifying {iso_path.name}..."):
                actual_hash = self._get_checksum(iso_path, algorithm)
            
            if actual_hash.lower() == expected_hash.lower():
                self.console.print(f"[green]✓ Checksum verified for {iso_path.name}")
                return True
            else:
                self.console.print(f"[yellow]⚠ Checksum mismatch for {iso_path.name}")
                self.console.print(f"  Expected: {expected_hash.lower()}")
                self.console.print(f"  Actual:   {actual_hash.lower()}")
                return False
        except Exception as e:
            self.console.print(f"[red]✗ Checksum verification failed: {e}")
            return False

    def download_iso(self, iso_config: Dict) -> bool:
        """Download and verify an ISO file."""
        iso_name = iso_config.get('fileName')
        if not iso_name:
            self.console.print("[red]✗ ISO configuration missing fileName")
            return False

        download_url = iso_config.get('downloadLink')
        if not download_url:
            self.console.print(f"[red]✗ No download URL provided for {iso_name}")
            return False

        relative_path = iso_config.get('downloadLocation', '').lstrip('/')
        dest_dir = self.iso_base_dir / relative_path
        dest_path = dest_dir / iso_name

        if dest_path.exists():
            if 'checkSum' in iso_config:
                if self.verify_iso(dest_path, iso_config['checkSum'], 
                                 iso_config.get('checkSumAlgo', 'sha256').lower()):
                    self.console.print(f"[green]✓ {iso_name} already exists and checksum verified")
                    return True
                self.console.print(f"[yellow]⚠ Existing file checksum mismatch, re-downloading {iso_name}")

        if not self._download_file(download_url, dest_path):
            return False

        if 'checkSum' in iso_config:
            if not self.verify_iso(dest_path, iso_config['checkSum'], 
                                 iso_config.get('checkSumAlgo', 'sha256').lower()):
                self.console.print(f"[red]✗ Checksum verification failed for {iso_name}")
                return False

        self.console.print(f"[green]✓ Successfully downloaded and verified {iso_name}")
        return True

    def list_tags(self) -> List[Dict]:
        """List all available tags with their ISOs."""
        return self.config.get('tags', [])

    def get_isos_by_tag(self, tag_name: str) -> List[Dict]:
        """Get all ISOs for a specific tag."""
        return [iso for iso in self.config.get('isos', []) 
                if tag_name in iso.get('tags', [])]

    def get_all_tags(self) -> Set[str]:
        """Get all unique tags from ISOs."""
        tags = set()
        for iso in self.config.get('isos', []):
            tags.update(iso.get('tags', []))
        return tags

    def show_tag_menu(self) -> str:
        """Show tag selection menu and return selected tag or 'all'."""
        tags = self.list_tags()
        if not tags:
            return "all"

        self.console.print("\n[bold]📂 Available Categories:[/]")
        for i, tag in enumerate(tags, 1):
            self.console.print(
                f"[cyan]{i}.[/] {tag.get('icon', '📁')} [bold]{tag['name']}[/]\n"
                f"   [dim]{tag.get('description', 'No description')}[/]"
            )
        self.console.print("[cyan]a.[/] Show All ISOs")
        self.console.print("[cyan]q.[/] Quit")

        while True:
            choice = Prompt.ask("\nSelect a category", choices=[str(i) for i in range(1, len(tags)+1)] + ['a', 'q'])
            if choice == 'q':
                return None
            elif choice == 'a':
                return "all"
            elif choice.isdigit() and 1 <= int(choice) <= len(tags):
                return tags[int(choice)-1]['name']

    def list_isos(self, tag_name: str = None) -> None:
        """List ISOs, optionally filtered by tag."""
        if tag_name and tag_name != "all":
            isos = self.get_isos_by_tag(tag_name)
            if not isos:
                self.console.print(f"[yellow]No ISOs found for tag: {tag_name}")
                return
        else:
            isos = self.config.get('isos', [])
            if not isos:
                self.console.print("[yellow]No ISOs configured in the config file.")
                return

        table = Table(
            title=f"📁 {'All ISOs' if tag_name == 'all' else 'Tag: ' + tag_name}",
            show_header=True,
            header_style="bold magenta",
            box=None
        )
        table.add_column("#", style="cyan", width=3)
        table.add_column("Name", style="green")
        table.add_column("Version", style="yellow")
        table.add_column("Platform", style="blue")
        table.add_column("Tags", style="cyan")
        table.add_column("Status", style="magenta", justify="right")

        for i, iso in enumerate(isos, 1):
            iso_path = self.iso_base_dir / iso.get('downloadLocation', '').lstrip('/') / iso.get('fileName', '')
            status = "[green]✓" if iso_path.exists() else "[yellow]✗"
            tags = ", ".join(iso.get('tags', ['-']))
            
            table.add_row(
                str(i),
                iso.get('name', 'N/A'),
                iso.get('version', 'N/A'),
                iso.get('platform', 'N/A'),
                tags,
                status
            )

        self.console.print()
        self.console.print(Panel.fit(table))

    def run(self) -> None:
        """Run the ISO manager with tag-based interface."""
        if not self.config.get('isos'):
            self.console.print("[red]✗ No ISOs configured in the config file.")
            return

        self.console.print(Panel.fit("[bold yellow]📦 TuxTechIaaC : ISO Download Manager[/]", border_style="blue"))
        
        while True:
            selected_tag = self.show_tag_menu()
            if selected_tag is None:
                break

            self.list_isos(selected_tag)

            try:
                if selected_tag == "all":
                    isos = self.config.get('isos', [])
                else:
                    isos = self.get_isos_by_tag(selected_tag)

                if not isos:
                    continue

                choice = Prompt.ask(
                    "\n[bold]Select ISO to download (number), 'b' to go back, or 'q' to quit: [/]",
                    default="b"
                ).strip().lower()

                if choice == 'q':
                    break
                elif choice == 'b':
                    continue
                elif choice.isdigit() and 1 <= int(choice) <= len(isos):
                    self.download_iso(isos[int(choice)-1])
                else:
                    self.console.print("[red]✗ Invalid selection")
                    
            except KeyboardInterrupt:
                self.console.print("\n👋 Operation cancelled by user")
                break
            except Exception as e:
                self.console.print(f"[red]✗ An error occurred: {e}")
                break

def main():
    try:
        manager = ISOManager()
        manager.run()
    except Exception as e:
        console = Console()
        console.print(f"[bold red]Fatal error:[/] {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()