# 🚀 AutoFS Installation and Management Script

An interactive script for managing AutoFS (Automatic File System) mounts on Linux systems. This script simplifies the process of installing, configuring, and managing AutoFS for NFS mounts.

<div align="center">

![AutoFS Status](https://img.shields.io/badge/AutoFS-Manager-blue)
![Bash Script](https://img.shields.io/badge/Bash-Script-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

</div>

## 🎯 Features

- 🔧 **Easy Installation**: One-command AutoFS setup
- 🔄 **Auto-mounting**: Automatically mount NFS shares when accessed
- 📊 **Status Monitoring**: Check AutoFS service and mount status
- 🛠️ **Troubleshooting**: Built-in tips and common solutions
- 🗑️ **Clean Uninstall**: Safe removal with configuration backup

## 📋 Prerequisites

- Linux-based operating system
- Sudo privileges
- Network connectivity to NFS server
- Basic understanding of NFS shares

## 🚀 Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/RashiMrBRD/rashfs.git
   cd scripts4
   ```

2. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```

3. Run the installation:
   ```bash
   ./setup.sh install
   ```

## 💻 Usage

The script supports various commands for different operations:

```bash
# Install RashFS (default action)
./setup.sh
# or
./setup.sh install

# View helpful tips and troubleshooting guide
./setup.sh tips

# Check RashFS status
./setup.sh status

# Uninstall RashFS
./setup.sh uninstall

# Show help
./setup.sh -h
```

## 🔧 Configuration

During installation, you'll be prompted to:

1. Enter custom directory names (or use defaults):
   ```bash
   Enter custom directory names separated by commas (or press Enter to use defaults):
   ```

2. Configure NFS mounts:
   - The script will open `/etc/auto.nfs` for editing
   - Add your NFS mount points in the format:
     ```
     mountpoint -options server:/share
     ```

## 📝 Example Configuration

Here's an example of an `/etc/auto.nfs` configuration:

```bash
# Format: <mount-point> [options] <server>:</path>

# Mount home directories
homes -rw,soft,intr nfs-server:/export/homes

# Mount project directories
projects -rw,soft,intr nfs-server:/export/projects

# Mount backup directory
backup  -ro,soft     backup-server:/backup
```

## 🔍 Monitoring and Troubleshooting

### Check Status
Monitor your RashFS setup:
```bash
./setup.sh status
```

### View Active Mounts
```bash
mount | grep autofs
```

### Common Issues and Solutions

1. **Mount not working?**
   ```bash
   # Check RashFS service
   systemctl status autofs
   
   # View logs
   tail -f /var/log/syslog | grep autofs
   ```

2. **Permission issues?**
   ```bash
   # Check NFS exports on server
   showmount -e <server-ip>
   
   # Verify client access
   sudo exportfs -v
   ```

## 🛠️ Advanced Usage

### Custom Mount Options

Add custom mount options in `/etc/auto.nfs`:
```bash
share -rw,soft,intr,rsize=8192,wsize=8192 nfs-server:/share
```

### Timeout Configuration

Modify timeout settings in `/etc/auto.master`:
```bash
/mnt /etc/auto.nfs --timeout=60
```

## 🔄 Backup and Restore

### Backup
The uninstall command automatically creates backups:
```bash
./setup.sh uninstall
# Backup stored in /etc/autofs_backup_<timestamp>
```

### Restore
Restore from backup:
```bash
# Replace <timestamp> with actual backup timestamp
sudo cp /etc/autofs_backup_<timestamp>/auto.master /etc/auto.master
sudo cp /etc/autofs_backup_<timestamp>/auto.nfs /etc/auto.nfs
```

## 📊 Status Codes

| Status | Description |
|--------|-------------|
| ✅ Running | RashFS service is active and running |
| ❌ Stopped | RashFS service is stopped |
| ⚠️ Error | Configuration or mount error |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- AutoFS community
- NFS documentation
- Linux system administrators

## 📞 Support

For support:
1. Check the built-in tips: `./setup.sh tips`
2. Review the troubleshooting section above
3. Open an issue in the repository

---
<div align="center">
Made with ❤️ for Linux System Administrators
</div>
