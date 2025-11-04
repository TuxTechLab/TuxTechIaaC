# Proxmox Ubuntu 22.04 Template with Cloud-Init

Step-by-step instructions to create a Ubuntu 22.04 template with Cloud-Init support in Proxmox, which later can be used to deploy multiple VMs using Terraform/OpenTofu.

## Prerequisites

- [Proxmox VE 8.4.14 or newer](https://pve.proxmox.com/wiki/Downloads#Update_a_running_Proxmox_Virtual_Environment_8.x_to_latest_8.4).
- [Ubuntu 22.04 LTS cloud image](https://cloud-images.ubuntu.com/jammy/current)
- Sufficient storage space (minimum 10GB recommended) in proxmox node.
- Network connectivity, Internet Access to download the cloud image.

## Video Tutorial

> [![Learn Linux TV | Proxmox VE - How to build an Ubuntu 22.04 Template (Updated Method)](https://img.youtube.com/vi/MJgIm03Jxdo/maxresdefault.jpg)](https://www.youtube.com/watch?v=MJgIm03Jxdo)**Learn Linux TV** | _Proxmox VE - How to build an Ubuntu 22.04 Template (Updated Method)_ 

> [![Techo Tim | Perfect Proxmox Template with Cloud Image and Cloud Init](https://img.youtube.com/vi/shiIi38cJe4/maxresdefault.jpg)](https://www.youtube.com/watch?v=shiIi38cJe4)**Techo Tim** | _Perfect Proxmox Template with Cloud Image and Cloud Init_ 

> [![Tech - The Lazy Automator | Cloud-Init on Proxmox: The VM Automation You’ve Been Missing - #30](https://img.youtube.com/vi/1Ec0Vg5be4s/maxresdefault.jpg)](https://www.youtube.com/watch?v=1Ec0Vg5be4s)**Tech - The Lazy Automator** | _Cloud-Init on Proxmox: The VM Automation You’ve Been Missing - #30_ 

> [![Jim's Garage | Use Proxmox Cloud-Init to Deploy Your Virtual Machines! Kubernetes At Home - Part 2](https://img.youtube.com/vi/Kv6-_--y5CM/maxresdefault.jpg)](https://www.youtube.com/watch?v=Kv6-_--y5CM)**Jim's Garage** | _Use Proxmox Cloud-Init to Deploy Your Virtual Machines! Kubernetes At Home - Part 2_ 

### Steps

> #### Step 1: Create a LVM-Thin Storage on Proxmox Web-UI

1. Navigate to the data-center and create a LVM-Thin storage using Proxmox Web-UI, example: `virtual-storage`
2. Create a new VM and configure it as per the instructions in the **"Step 2: Create a New VM"** section

> #### Step 2: Create a New VM

1. In the Proxmox web interface, click "Create VM"
2. General tab:
   - VM ID: Any available number. (Higher Number will Place the VM at the end of the list.) Example: `100`
   - Name: `ubuntu-2204-template`
   - Resource Pool: (Leave default or select as needed)
   - Check "Start at boot" if needed

3. OS tab:
   - Select `Do not use any media`
   - Guest OS: `Linux`
   - Version: `6.x - 2.6 Kernel`

4. System tab:
   - Default settings are usually fine
   - Ensure `QEMU Agent` is checked

5. Disks tab:
   - Delete the default disk - `scsi0`
   
   a. **Primary Disk (Local Storage - OS Disk)**:
   - Click "Add" and select "Hard Disk"
   - Storage: local-lvm (or your local storage name)
   - Disk size: 15G
   - Format: qcow2 (better for local storage)
   - Cache: Default (No cache)
   - Discard: Check to enable TRIM support

   b. **Secondary Disk (Shared Storage - Data Disk)**:
   - Click "Add" and select "Hard Disk"
   - Storage: `virtual-storage` (LVM)
   - Disk size: `30G`
   - Format: `LVM-Thin` (recommended for LVM)
   - Cache: `Write back` (faster, but ensure you have UPS)
   - Discard: Check to enable TRIM support
   - SSD Enumeration: `Yes` (if using SSD)

6. CPU tab:
   - Cores: 1 (as we can increase if needed)
   - Type: `host`
   - BIOS: `SeaBIOS`
   - If you need CPU, Memory, Storage hot pluggable please enable **NUMA**.

7. Memory tab:
   - Memory: `1024` (1GB, as we can increase if needed)
   - Ballooning: Check if using memory ballooning

8. Network tab:
   - Bridge: `vmbr0` (or your preferred bridge if any other exists)
   - MAC Address: (leave blank to generate)
   - IP Address Mode: `DHCP`
   - Model: `VirtIO` (paravirtualized)
   - Firewall: (enable if needed)

> #### Step 3: Configure Cloud-Init

1. In the VM options, go to "Cloud-Init"
2. Configure the following:
   - User: `root` (or your preferred username)
   - Password: Set a secure password
   - DNS Domain: (your domain, if applicable)
   - DNS Servers: (your DNS servers, e.g., 8.8.8.8,8.8.4.4)
   - SSH Public Key: (paste your public key for key-based auth)
   - IP Config: `dhcp` (or configure static IP if needed)

> #### Step 4: Download Ubuntu Cloud Image

1. Connect to your Proxmox host via SSH
2. Download the Ubuntu 22.04 cloud image:
   ```bash
   wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O /var/lib/vz/template/iso/ubuntu-22.04.qcow2
   ```
3. Run the below commands to fix the VM configurations:
    ```bash
    qm set <vm-id> --serial0 socket -vga serial0
    mv ubuntu-22.04-minimal-cloudimg-amd64.img ubuntu-22.04.qcow2
    qemu-img resize ubuntu-22.04.qcow2 32G
    qm importdisk <vm-id> ubuntu-22.04.qcow2 virtual-storage
    ```
   Post that add the disk in the VM options Hardware tab.

4. Add the cloudinit drive in the VM options Hardware tab.

5. In Options of the VM, change the boot order to : cdrom, disk, network. Make sure the local disk is added.

> #### Step 5: Convert to Template

1. Start the VM and wait for it to fully boot
2. Log in using the credentials you set in Cloud-Init
3. Update the system:
   ```bash
   apt update && apt upgrade -y
   ```
4. Install QEMU Guest Agent (if not already installed):
   ```bash
   apt install -y qemu-guest-agent
   systemctl enable --now qemu-guest-agent
   ```
5. Clean up the system:
   ```bash
   apt clean
   rm -f /etc/ssh/ssh_host_*
   rm -f /etc/machine-id
   touch /etc/machine-id
   rm -f /var/lib/dbus/machine-id
   ln -s /etc/machine-id /var/lib/dbus/machine-id
   ```
6. Shut down the VM:
   ```bash
   shutdown now
   ```
7. In the Proxmox web interface, right-click the VM and select "Convert to Template"

### Notes

- Always use strong, unique passwords
- Consider using SSH key-based authentication instead of passwords.
- The template can be customized further based on your specific requirements
- Remember to update the template periodically with security updates

### Troubleshooting

- If the VM doesn't get an IP, check the Cloud-Init network configuration
- Ensure the QEMU Guest Agent is running if using features that depend on it
- Check the VM's console output for any Cloud-Init errors during boot
- Kindly check the [Proxmox Cloud-Init Documentation](https://pve.proxmox.com/wiki/Cloud-Init) for more information
- For more information check the videos mentioned at **[Video Tutorials](#video-tutorial)**