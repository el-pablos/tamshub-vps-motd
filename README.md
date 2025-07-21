# TamsHub VPS System Information Display

A professional, hardcore system information display for Ubuntu 22.04.5 LTS VPS servers. This custom MOTD (Message of the Day) script showcases your server's specifications and performance metrics in an impressive, professional format.

**Author:** Tamas (a.k.a. Pablos)
**Organization:** TamsHub

## 🚀 Features

### Hardware Specifications Display
- **CPU Information**: Model, architecture, cores/threads, frequency, governor
- **Memory Details**: Total RAM, usage with progress bars, available memory, cached memory
- **Storage Information**: Storage type detection (NVMe/SSD/HDD), capacity, usage with progress bars
- **Network Interface**: Primary interface, IP address, connection speed

### Performance Metrics
- **Real-time System Stats**: CPU usage, load averages, active processes
- **System Uptime**: Detailed uptime information
- **Disk I/O Statistics**: Read/write performance (requires sysstat)
- **Network Statistics**: Total RX/TX data transfer

### Advanced System Information
- **Operating System**: Version and distribution details
- **Kernel Information**: Version and build details
- **Virtualization Detection**: Automatic detection of virtualization technology
- **Security Features**: Enabled security features and configurations

### Visual Features
- **Professional ASCII Art**: TamsHub VPS branding header
- **Color-coded Information**: Different colors for different types of data
- **Progress Bars**: Visual representation of memory and storage usage
- **Bordered Sections**: Clean, organized layout with Unicode borders
- **Responsive Design**: Adapts to different terminal widths

## 📋 Requirements

- Ubuntu 22.04.5 LTS (or compatible)
- Root/sudo access for installation
- SSH access to the server

### Optional Dependencies (auto-installed)
- `sysstat` - For disk I/O statistics
- `net-tools` - For enhanced network information
- `lsb-release` - For OS version detection
- `curl` - For network testing capabilities

## 🔧 Installation

### Quick Installation

1. **Download the files to your server:**
```bash
# Create installation directory
mkdir -p ~/cybervps-motd
cd ~/cybervps-motd

# Download the files (replace with your actual download method)
wget https://your-server.com/vps-sysinfo.sh
wget https://your-server.com/install-motd.sh
```

2. **Make the installer executable:**
```bash
chmod +x install-motd.sh
```

3. **Run the installer:**
```bash
sudo ./install-motd.sh
```

### Manual Installation

If you prefer to install manually:

1. **Install dependencies:**
```bash
sudo apt update
sudo apt install -y sysstat net-tools lsb-release curl
```

2. **Copy the main script:**
```bash
sudo cp vps-sysinfo.sh /usr/local/bin/vps-sysinfo
sudo chmod +x /usr/local/bin/vps-sysinfo
```

3. **Create MOTD script:**
```bash
sudo tee /etc/update-motd.d/01-tamshub-vps << 'EOF'
#!/bin/bash
/usr/local/bin/vps-sysinfo
EOF

sudo chmod +x /etc/update-motd.d/01-tamshub-vps
```

4. **Disable unwanted default MOTD components:**
```bash
sudo chmod -x /etc/update-motd.d/10-help-text
sudo chmod -x /etc/update-motd.d/50-motd-news
sudo chmod -x /etc/update-motd.d/80-esm
sudo chmod -x /etc/update-motd.d/95-hwe-eol
```

5. **Update MOTD:**
```bash
sudo update-motd
```

## 🎯 Usage

### Viewing the MOTD

The system information display will automatically appear when you SSH into your server. To manually view it:

```bash
# View current MOTD
sudo update-motd && cat /run/motd.dynamic

# Or run the script directly
sudo /usr/local/bin/vps-sysinfo
```

### Testing the Installation

```bash
# Test script execution
sudo /usr/local/bin/vps-sysinfo

# Update and view MOTD
sudo update-motd
cat /run/motd.dynamic
```

## 🛠️ Customization

### Modifying Colors

Edit `/usr/local/bin/vps-sysinfo` and modify the color definitions at the top:

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
```

### Customizing Content

You can modify the script to:
- Add custom server information
- Change the ASCII art header
- Modify section layouts
- Add additional system metrics

### Branding Customization

To change the "TAMSHUB VPS" branding, edit the ASCII art section in the `display_system_info()` function.

## 🗑️ Uninstallation

The installer creates an automatic uninstall script:

```bash
sudo /usr/local/bin/uninstall-tamshub-vps-motd
```

### Manual Uninstallation

```bash
# Remove custom MOTD script
sudo rm -f /etc/update-motd.d/01-tamshub-vps
sudo rm -f /usr/local/bin/vps-sysinfo

# Re-enable default MOTD components
sudo chmod +x /etc/update-motd.d/10-help-text
sudo chmod +x /etc/update-motd.d/50-motd-news

# Update MOTD
sudo update-motd
```

## 📊 Sample Output

```
   ████████╗ █████╗ ███╗   ███╗███████╗██╗  ██╗██╗   ██╗██████╗     ██╗   ██╗██████╗ ███████╗
   ╚══██╔══╝██╔══██╗████╗ ████║██╔════╝██║  ██║██║   ██║██╔══██╗    ██║   ██║██╔══██╗██╔════╝
      ██║   ███████║██╔████╔██║███████╗███████║██║   ██║██████╔╝    ██║   ██║██████╔╝███████╗
      ██║   ██╔══██║██║╚██╔╝██║╚════██║██╔══██║██║   ██║██╔══██╗    ╚██╗ ██╔╝██╔═══╝ ╚════██║
      ██║   ██║  ██║██║ ╚═╝ ██║███████║██║  ██║╚██████╔╝██████╔╝     ╚████╔╝ ██║     ███████║
      ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝       ╚═══╝  ╚═╝     ╚══════╝

                    ELITE VIRTUAL PRIVATE SERVER
                        High-Performance Computing Platform
                           Author: Tamas (a.k.a. Pablos)
                              Organization: TamsHub

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
┌──────────────────────────────────────────────────────────────────────────────┐
│                           HARDWARE SPECIFICATIONS                           │
└──────────────────────────────────────────────────────────────────────────────┘

● CPU Model:               Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz
● CPU Architecture:        x86_64
● CPU Cores/Threads:       4 cores / 8 threads
● CPU Frequency:           2.30 GHz
● CPU Governor:            performance

● Total RAM:               16.00 GB
● Memory Usage:            4.2 GB [████████░░░░░░░░░░░░]  26%
● Available Memory:        11.8 GB
● Cached Memory:           2.1 GB

● Storage Type:            NVMe SSD
● Total Storage:           100G
● Used Storage:            25G [█████░░░░░░░░░░░░░░░]  25%
● Available Storage:       71G

● Network Interface:       eth0
● IP Address:              Hidden for security
● Interface Speed:         10 Gbps
```

## 🔧 Troubleshooting

### Common Issues

1. **Script not executing**: Check permissions with `ls -la /usr/local/bin/vps-sysinfo`
2. **Missing dependencies**: Run `sudo apt install sysstat net-tools lsb-release`
3. **MOTD not updating**: Run `sudo update-motd` manually
4. **Colors not displaying**: Ensure your terminal supports ANSI colors

### Debug Mode

Run the script with debug output:
```bash
bash -x /usr/local/bin/vps-sysinfo
```

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve this system information display.

---

**Enjoy your hardcore VPS system information display!** 🚀
