# OpenWrt Firmware Repository for TP-Link Archer A6/C6 v3

> **Note**: TP-Link Archer A6 v3 and C6 v3 use the same hardware and firmware.

## 📚 Official Documentation

- [OpenWrt Hardware Database: TP-Link Archer A6 v3](https://openwrt.org/toh/hwdata/tp-link/tp-link_archer_a6_v3)
- [OpenWrt Installation Guide](https://openwrt.org/docs/guide-user/installation/openwrt_x86)
- [TP-Link Firmware Recovery](https://openwrt.org/toh/tp-link/tp-link_archer_c6_v3#firmware_recovery)
- [OpenWrt Forum: TP-Link Archer Series](https://forum.openwrt.org/t/tp-link-archer-a6-v3-c6-v3/)

## 📥 Available Firmware Versions

| Version | Type | File | Size | SHA256 Checksum | MD5 Checksum |
|---------|------|------|------|-----------------|--------------|
| 24.10.4 | Factory | [openwrt-24.10.4-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin](./openwrt-24.10.4-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin) | 7.3 MB | `c1c05ed425c4e22296f9ba24da1c271ff596d61812e005952da43b6a8eab7667` | `12f715c5ac2f4ef6bf630c78d8b20af6` |
| 24.10.3 | Factory | [openwrt-24.10.3-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin](./openwrt-24.10.3-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin) | 7.3 MB | `1e884b35b22cbcd61581384ff988cf5c8bd5df1c7a05ef6d4a203c3cb0668634` | `dc8776e76f06c6fd9ff664329e41c70f` |
| 24.10.0 | Factory | [openwrt-24.10.0-ramips-mt7621-tplink_archer-a6-v3-squashfs-factory.bin](./openwrt-24.10.0-ramips-mt7621-tplink_archer-a6-v3-squashfs-factory.bin) | 7.3 MB | `d10c9a49b0bf662b4c5d3d1b4633040afd3eb2db8120023c3d81e22729a51cf6` | `2ef9e41661b7160771d2e0da7e49b605` |
| 24.10.0 | Sysupgrade | [openwrt-24.10.0-ramips-mt7621-tplink_archer-a6-v3-squashfs-sysupgrade.bin](./openwrt-24.10.0-ramips-mt7621-tplink_archer-a6-v3-squashfs-sysupgrade.bin) | 7.3 MB | `4accb651027c6b18ea97bb30f2a34684de3a94f02ae21101b201046079dbf9b9` | `15ce394749dc9ed26811cd38c4dbc26a` |
| 23.05.4 | Factory | [openwrt-23.05.4-ramips-mt7621-tplink_archer-a6-v3-squashfs-factory.bin](./openwrt-23.05.4-ramips-mt7621-tplink_archer-a6-v3-squashfs-factory.bin) | 6.6 MB | `dc5d4667140726a973628a361e7b4b62da89e37910cd95c4715af1d8ce4e8486` | `a6c13afb8553c246a16b7798270f952c` |
| 23.8.0 | Factory | [openwrt-23.8.0-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin](./openwrt-23.8.0-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin) | 146 B | `55f7d9e99b8e2d4e0e193b2f0275501e6d9c1ebd29cadbea6a0da48a8587e3e0` | `8eec510e57f5f732fd2cce73df7b73ef` |
| 23.7.0 | Factory | [openwrt-23.7.0-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin](./openwrt-23.7.0-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin) | 146 B | `55f7d9e99b8e2d4e0e193b2f0275501e6d9c1ebd29cadbea6a0da48a8587e3e0` | `8eec510e57f5f732fd2cce73df7b73ef` |
| 23.6.0 | Factory | [openwrt-23.6.0-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin](./openwrt-23.6.0-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin) | 146 B | `55f7d9e99b8e2d4e0e193b2f0275501e6d9c1ebd29cadbea6a0da48a8587e3e0` | `8eec510e57f5f732fd2cce73df7b73ef` |

## 🔍 Verifying Downloads

### On Linux/macOS:
```bash
# For SHA256 checksum
echo "<expected-sha256>  <firmware-file>.bin" | sha256sum --check

# For MD5 checksum
echo "<expected-md5>  <firmware-file>.bin" | md5sum --check

# Example for 24.10.4 factory image:
echo "c1c05ed425c4e22296f9ba24da1c271ff596d61812e005952da43b6a8eab7667  openwrt-24.10.4-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin" | sha256sum --check
```

### On Windows (PowerShell):
```powershell
# For SHA256 checksum
(Get-FileHash -Algorithm SHA256 <firmware-file>.bin).Hash -eq "<expected-sha256>"

# For MD5 checksum
(Get-FileHash -Algorithm MD5 <firmware-file>.bin).Hash -eq "<expected-md5>"

# Example for 24.10.4 factory image:
(Get-FileHash -Algorithm SHA256 "openwrt-24.10.4-ramips-mt7621-tplink_archer-c6-v3-squashfs-factory.bin").Hash -eq "c1c05ed425c4e22296f9ba24da1c271ff596d61812e005952da43b6a8eab7667"
```

## ⚙️ Installation Instructions

### Initial Installation (from Stock Firmware):
1. Download the appropriate factory image for your device
2. Log in to your router's web interface (typically at `http://192.168.0.1`)
3. Navigate to System Tools > Firmware Upgrade
4. Upload the factory image and confirm the upgrade
5. Wait for the router to reboot (may take several minutes)

### Upgrading (from OpenWrt):
1. Download the sysupgrade image
2. Log in to LuCI (OpenWrt's web interface)
3. Navigate to System > Backup / Flash Firmware
4. Upload the sysupgrade image and confirm the upgrade
5. Do not interrupt the process until the router reboots

## 📦 Additional Packages

Additional packages can be installed using opkg:
```bash
opkg update
opkg install <package-name>
```

## ⚠️ Important Notes
- **Factory Reset**: After flashing, it's recommended to perform a factory reset
- **Backup**: Always backup your configuration before upgrading
- **Compatibility**: Ensure you're using the correct firmware version for your hardware revision
- **Support**: For issues, visit the [OpenWrt Forum](https://forum.openwrt.org/)
