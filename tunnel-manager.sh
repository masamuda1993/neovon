#!/usr/bin/env bash

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                                                                    ║
# ║           TUNNEL MANAGER v5.0 - GITHUB BACKUP EDITION              ║
# ║                                                                    ║
# ║     Complete SSH WebSocket + Xray Solution                          ║
# ║     All binaries included for offline/GitHub backup                ║
# ║                                                                    ║
# ║     Features:                                                      ║
# ║     ✓ SSH over WebSocket                                           ║
# ║     ✓ Xray-Core (VLESS/VMess/Trojan/SS)                           ║
# ║     ✓ Auto SSL/Let's Encrypt                                       ║
# ║     ✓ Nginx Reverse Proxy                                          ║
# ║     ✓ User Management System                                        ║
# ║     ✓ OS Rebuild/Reinstall (19+ Distro)                            ║
# ║     ✓ Multi-Architecture Support                                   ║
# ║                                                                    ║
# ║     Author: Advanced Script Collection                             ║
# ║     Version: 5.0-GitHub-Edition                                    ║
# ║     License: MIT                                                   ║
# ║                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ============================================================
# CONFIGURATION - EDIT URL DI SINI UNTUK GANTI REPO SENDIRI
# ============================================================

SCRIPT_VERSION="5.0-GitHub"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===== DIRECTORIES =====
INSTALL_DIR="/usr/local/tunnel-manager"
CONFIG_DIR="/etc/tunnel-manager"
BIN_DIR="/usr/local/bin"
CACHE_DIR="/var/cache/tunnel-manager"
LOG_DIR="/var/log/tunnel-manager"
TEMP_DIR="/tmp/tm-$$"

# ===== PORT CONFIGURATION =====
SSH_WS_PORT=443
XRAY_VLESS_PORT=10000
XRAY_VMESS_PORT=10001
XRAY_TROJAN_PORT=10002
XRAY_SS_PORT=10003
SSH_PORT=22

# ===== DOMAIN (akan di-set saat setup) =====
DOMAIN=""
DOMAIN_EMAIL=""

# ╔═══════════════════════════════════════════════════════════════════╗
# ║         DOWNLOAD URLs - HARD CODED - GANTI DI SINI                ║
# ║                                                                    ║
# ║  Cara pakai repo sendiri:                                         ║
# ║  1. Upload file-file binary ke GitHub repo anda                    ║
# ║  2. Ganti URL di bawah dengan raw link GitHub anda                 ║
# ║  3. Contoh: https://raw.githubusercontent.com/USER/REPO/main/binaries/xray/Xray-linux-amd64.zip ║
# ╚═══════════════════════════════════════════════════════════════════╝

# ===== XRAY-CORE DOWNLOAD URLs =====
# Format: https://github.com/XTLS/Xray-core/releases/download/v{VERSION}/Xray-linux-{ARCH}.zip

# Versi Xray (ganti "latest" dengan versi spesifik seperti "1.8.9" jika mau lock)
XRAY_VERSION="latest"

# === AMD64 (x86_64) - VPS umum ===
# ⚠️ GANTI URL INI KE REPO ANDA:
XRAY_URL_AMD64="https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip"

# === ARM64 (Raspberry Pi, ARM VPS) ===
# ⚠️ GANTI URL INI KE REPO ANDA:
XRAY_URL_ARM64="https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-arm64-v8a.zip"

# === ARM32 (Old Raspberry Pi) ===
# ⚠️ GANTI URL INI KE REPO ANDA:
XRAY_URL_ARMV7="https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-arm-v7a.zip"

# Alternative: Pakai local file (kalau sudah download manual)
# XRAY_URL_AMD64="${SCRIPT_DIR}/binaries/xray/Xray-linux-amd64.zip"
# XRAY_URL_ARM64="${SCRIPT_DIR}/binaries/xray/Xray-linux-arm64.zip"
# XRAY_URL_ARMV7="${SCRIPT_DIR}/binaries/xray/Xray-linux-armv7.zip"

# ===== GEODATA FILES (Routing rules) =====
# ⚠️ GANTI URL INI KE REPO ANDA:
GEOIP_URL="https://github.com/v2fly/geo-api-data/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/v2fly/geo-api-data/releases/latest/download/geosite.dat"

# Alternative local:
# GEOIP_URL="${SCRIPT_DIR}/binaries/geodata/geoip.dat"
# GEOSITE_URL="${SCRIPT_DIR}/binaries/geodata/geosite.dat"

# ===== ACME.SH (untuk SSL certificate) =====
ACME_SH_URL="https://github.com/acmesh-official/acme.sh/archive/refs/heads/master.tar.gz"

# Alternative local:
# ACME_SH_URL="${SCRIPT_DIR}/binaries/tools/acme.sh.tar.gz"

# ===== PYTHON WEBSOCKETS (dependency untuk SSH WS) =====
# Biasanya lewat pip, tapi bisa juga download wheel
WEBSOCKETS_PYTHON_URL=""  # Kosongkan = pakai pip install

# ===== NGINX (biasanya dari package manager) =====
# Kalau mau custom build:
NGINX_CUSTOM_URL=""  # Kosongkan = pakai apt/yum

# ╔═══════════════════════════════════════════════════════════════════╗
# ║            OS REBUILD/REINSTALL SCRIPT URLs                       ║
# ║    Script ini didownload dari GitHub saat pertama kali run        ║
# ╚═══════════════════════════════════════════════════════════════════╝

# ===== Option 1: bin456789/reinstall (Recommended - Support 19+ distros) =====
# Fitur:
# - Debian 9,10,11,12,13
# - Ubuntu 18.04-26.04 LTS
# - CentOS/RHEL/Rocky/AlmaLinux 7,8,9,10
# - Kali, Fedora, Alpine, Anolis, OpenCloudOS
# - Windows Server (DD mode)
# - ARM support
REINSTALL_SCRIPT_URL_1="https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh"

# ===== Option 2: leitbogioro/Tools (InstallNET.sh - Classic & Stable) =====
# Fitur:
# - Debian 9-13
# - Ubuntu 18.04-24.04
# - CentOS 7-9
# - Kali, AlmaLinux, Rocky, Fedora
REINSTALL_SCRIPT_URL_2="https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh"

# Active reinstall script (pilih 1 atau 2)
ACTIVE_REINSTALL_SCRIPT="$REINSTALL_SCRIPT_URL_1"

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                      COLOR SCHEME                                ║
# ╚═══════════════════════════════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

GRAD1='\033[38;5;129m'
GRAD2='\033[38;5;99m'
GRAD3='\033[38;5;165m'
GRAD4='\033[38;5;204m'
GRAD5='\033[38;5;81m'
GRAD6='\033[38;5;82m'
GRAD7='\033[38;5;208m'

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                   GLOBAL VARIABLES                               ║
# ╚═══════════════════════════════════════════════════════════════════╝

OS_TYPE=""
OS_VERSION=""
PKG_MANAGER=""
ARCH=""
INSTALLED_COMPONENTS=()
DOWNLOAD_TIMEOUT=60
MAX_RETRIES=3

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                 INITIALIZATION                                  ║
# ╚═════════════════════════════════════════════════════════════════╝

init_system() {
    show_banner
    echo -e "  ${DIM}[INIT] Initializing Tunnel Manager v${SCRIPT_VERSION}${NC}"
    
    # Check root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] Run as root: sudo su${NC}"
        exit 1
    fi
    
    # Create directories
    mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$CONFIG_DIR/users" "$BIN_DIR" "$CACHE_DIR" "$LOG_DIR" "$TEMP_DIR"
    
    # Detect system
    detect_os
    detect_architecture
    
    # Save info
    save_install_info
    
    echo -e "  ${GREEN}[OK] System ready${NC}\n"
    sleep 1
}

detect_os() {
    if [[ -f /etc/debian_version ]]; then
        OS_TYPE="debian"
        PKG_MANAGER="apt-get"
        OS_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    elif [[ -f /etc/redhat-release ]]; then
        OS_TYPE="centos"
        PKG_MANAGER="yum"
        OS_VERSION=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | head -1)
    elif [[ -f /etc/arch-release ]]; then
        OS_TYPE="arch"
        PKG_MANAGER="pacman"
    else
        OS_TYPE="unknown"
        PKG_MANAGER="apt-get"
    fi
    
    echo -e "  ${DIM}[INFO] OS: ${OS_TYPE} ${OS_VERSION} | Package Manager: ${PKG_MANAGER}${NC}"
}

detect_architecture() {
    local machine=$(uname -m)
    
    case $machine in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64|armv8l)
            ARCH="arm64"
            ;;
        armv7l|armhf)
            ARCH="armv7"
            ;;
        i386|i686)
            ARCH="386"
            ;;
        *)
            ARCH="amd64"
            ;;
    esac
    
    echo -e "  ${DIM}[INFO] Architecture: ${machine} (${ARCH})${NC}"
}

save_install_info() {
    cat > "$CONFIG_DIR/install-info.conf" << EOF
# Tunnel Manager Install Info
VERSION=${SCRIPT_VERSION}
DATE=$(date '+%Y-%m-%d %H:%M:%S')
OS=${OS_TYPE} ${OS_VERSION}
ARCH=${ARCH}
EOF
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                     UI FUNCTIONS                                ║
# ╚═══════════════════════════════════════════════════════════════════╝

show_banner() {
    clear
    echo ""
    echo -e "  ${GRAD1}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${GRAD2}║${NC}  ${BOLD}${WHITE}TUNNEL MANAGER PRO${NC} ${DIM}|${NC} ${CYAN}v${SCRIPT_VERSION}${NC}               ${GRAD3}│${NC} ${WHITE}GitHub Backup Edition${NC}  ${GRAD2}║${NC}"
    echo -e "  ${GRAD4}╠───────────────────────────────────────────────────────────────────────╣${NC}"
    echo -e "  ${GRAD5}║${NC}  ${WHITE}SSH WS${NC} ${DIM}•${NC} ${WHITE}Xray${NC} ${DIM}•${NC} ${WHITE}VLESS${NC} ${DIM}•${NC} ${WHITE}VMess${NC} ${DIM}•${NC} ${WHITE}Trojan${NC} ${DIM}•${NC} ${WHITE}SS${NC} ${DIM}•${NC} ${WHITE}Rebuild OS${NC}  ${GRAD5}║${NC}"
    echo -e "  ${GRAD6}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_header() {
    echo -e "\n  ${BOLD}${CYAN}┌───── $1${NC}"
    echo -e "  │\n"
}

show_footer() {
    echo -e "\n  ${DIM}└─────────────────────────────────────────────────────────────────────────${NC}\n"
}

draw_line() {
    echo -e "${DIM}  ──────────────────────────────────────────────────────────────────────────${NC}"
}

progress_bar() {
    local msg=$1
    local current=$2
    local total=$3
    
    local pct=$((current * 100 / total))
    local filled=$((pct / 2))
    local empty=$((50 - filled))
    
    printf "\r  ${CYAN}▸${NC} %-40s [" "$msg"
    printf "${GREEN}%.0s█${NC}" $(seq 1 $filled 2>/dev/null || true)
    printf "${DIM}%.0s░${NC}" $(seq 1 $empty 2>/dev/null || true)
    printf "] %d%%" "$pct"
}

progress_complete() {
    printf "\r  ${GREEN}✓${NC} %-40s [${GREEN}██████████████████████████████████████] 100%%${NC}\n" "$1"
}

progress_fail() {
    printf "\r  ${RED}✗${NC} %-40s [${RED}░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] FAILED${NC}\n" "$1"
}

read_input() {
    local prompt=$1
    local varname=$2
    local default=${3:-}
    
    if [[ -n "$default" ]]; then
        echo -en "  ${CYAN}▸${NC} ${prompt} ${DIM}[${default}]${NC}: "
        read -r input
        input="${input:-$default}"
    else
        echo -en "  ${CYAN}▸${NC} ${prompt}: "
        read -r input
    fi
    
    eval "$varname='$input'"
}

read_password() {
    local prompt=$1
    local varname=$2
    echo -en "  ${CYAN}▸${NC} ${prompt}: "
    read -rs input
    echo ""
    eval "$varname='$input'"
}

confirm() {
    local prompt=$1
    echo -en "  ${YELLOW}▸${NC} ${prompt} (y/n): "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

select_menu() {
    local title=$1
    shift
    local options=("$@")
    
    echo -e "  ${WHITE}${title}${NC}"
    local i=1
    for opt in "${options[@]}"; do
        echo -e "    ${CYAN}$i)${NC} $opt"
        ((i++))
    done
    
    echo -en "  ${CYAN}▸${NC} Select [1-${#options[@]}]: "
    read -r choice
    
    if [[ "$choice" =~ ^[1-9]$ ]] && [[ $choice -le ${#options[@]} ]]; then
        return $choice
    else
        return 0
    fi
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                  DOWNLOAD MANAGER                               ║
# ╚═══════════════════════════════════════════════════════════════════╝

get_xray_real_version() {
    if [[ "$XRAY_VERSION" == "latest" ]]; then
        local ver=$(curl -sL --max-time 15 \
            "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | \
            grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')
        
        [[ -z "$ver" || "$ver" == "null" ]] && ver="1.8.24"
        echo "$ver"
    else
        echo "$XRAY_VERSION"
    fi
}

get_download_url_for_arch() {
    case $ARCH in
        amd64)  echo "$XRAY_URL_AMD64" ;;
        arm64)  echo "$XRAY_URL_ARM64" ;;
        armv7)  echo "$XRAY_URL_ARMV7" ;;
        *)      echo "$XRAY_URL_AMD64" ;;
    esac
}

download_file() {
    local url=$1
    local output=$2
    local desc=${3:-"Downloading"}
    
    local success=false
    local attempt=0
    
    while [[ $attempt -lt $MAX_RETRIES ]] && [[ $success == false ]]; do
        ((attempt++))
        
        echo -ne "  ${DIM}[Attempt ${attempt}/${MAX_RETRIES}]${NC} ${desc}..."
        
        # Check if local file
        if [[ -f "$url" ]]; then
            cp "$url" "$output" 2>/dev/null && success=true
        else
            # Download from URL
            local http_code
            http_code=$(curl -w "%{http_code}" -o "$output" -L \
                --max-time "$DOWNLOAD_TIMEOUT" \
                --retry 2 \
                --connect-timeout 15 \
                -sS "$url") || true
            
            [[ "$http_code" == "200" && -f "$output" && -s "$output" ]] && success=true
        fi
        
        if [[ $success == true ]]; then
            echo -e "\r  ${GREEN}✓${NC} ${desc}...      "
            return 0
        else
            echo -e "\r  ${YELLOW}⊘${NC} Retry ${attempt}/${MAX_RETRIES}...      "
            sleep 2
        fi
    done
    
    progress_fail "$desc"
    return 1
}

download_and_extract() {
    local url=$1
    local output_dir=$2
    local desc=${3:-"Download"}
    
    local temp_file="$TEMP_DIR/dl_$(date +%s).zip"
    mkdir -p "$output_dir" "$TEMP_DIR"
    
    if download_file "$url" "$temp_file" "$desc"; then
        if unzip -qo "$temp_file" -d "$output_dir" 2>/dev/null; then
            rm -f "$temp_file"
            progress_complete "$desc"
            return 0
        else
            echo -e "  ${RED}[ERROR] Extract failed: ${desc}${NC}"
            rm -f "$temp_file"
            return 1
        fi
    else
        rm -f "$temp_file"
        return 1
    fi
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                PACKAGE INSTALLER                              ║
# ╚═══════════════════════════════════════════════════════════════════╝

install_packages() {
    show_header "Installing System Packages"
    
    echo -e "  ${DIM}[INFO] Updating package lists...${NC}"
    $PKG_MANAGER update -y > /dev/null 2>&1 || true
    
    local packages=(
        curl wget unzip zip socat cron
        ca-certificates gnupg lsb-release
        software-properties-common
        python3 python3-pip jq nginx
    )
    
    local total=${#packages[@]}
    local current=0
    
    for pkg in "${packages[@]}"; do
        ((current++))
        progress_bar "Installing $pkg" $current $total
        
        if $PKG_MANAGER install -y "$pkg" > /dev/null 2>&1; then
            :
        else
            echo -e "\n  ${YELLOW}[WARN] Skipped: ${pkg}${NC}"
        fi
    done
    
    echo ""
    progress_complete "Packages installed"
    show_footer
    sleep 1
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                 XRAY-CORE INSTALLER                           ║
# ╚═══════════════════════════════════════════════════════════════════╝

install_xray_core() {
    show_header "Installing Xray-Core"
    
    # Get real version
    local version=$(get_xray_real_version)
    local url=$(get_download_url_for_arch)
    
    echo -e "  ${DIM}[INFO] Version: ${version}${NC}"
    echo -e "  ${DIM}[INFO] Architecture: ${ARCH}${NC}"
    echo -e "  ${DIM}[INFO] Source: ${url:0:70}...${NC}\n"
    
    # Create xray directory
    local xray_dir="/usr/local/xray"
    mkdir -p "$xray_dir" "$xray_dir/geodata"
    
    # Download and extract
    if download_and_extract "$url" "$xray_dir" "Xray-Core v${version} (${ARCH})"; then
        # Make executable
        chmod +x "$xray_dir/xray" 2>/dev/null || true
        
        # Create symlink
        ln -sf "$xray_dir/xray" "$BIN_DIR/xray"
        
        # Generate keys
        cd "$xray_dir" && ./xray x25519 > "$CONFIG_DIR/x25519.key" 2>&1 || true
        
        # Install geodata
        install_geodata "$xray_dir/geodata"
        
        # Create service
        create_xray_service
        
        INSTALLED_COMPONENTS+=("xray")
        
        echo -e "\n  ${GREEN}[SUCCESS] Xray-Core v${version} installed${NC}"
    else
        echo -e "\n  ${RED}[ERROR] Failed to install Xray-Core${NC}"
        echo -e "  ${YELLOW}[TIP] Check URL or download manually to: ${SCRIPT_DIR}/binaries/xray/${NC}"
        return 1
    fi
    
    show_footer
    sleep 1
}

install_geodata() {
    local geo_dir=$1
    echo -e "  ${DIM}[INFO] Installing GeoData...${NC}"
    
    download_file "$GEOIP_URL" "$geo_dir/geoip.dat" "GeoIP" || true
    download_file "$GEOSITE_URL" "$geo_dir/geosite.dat" "GeoSite" || true
}

create_xray_service() {
    cat > /etc/systemd/system/xray.service << 'EOF'
[Unit]
Description=Xray Service
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/xray/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable xray
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║              SSH WEBSOCKET INSTALLER                         ║
# ╚═══════════════════════════════════════════════════════════════════╝

install_ssh_websocket() {
    show_header "Configuring SSH over WebSocket"
    
    # Ensure SSH server
    if ! command -v sshd &> /dev/null; then
        echo -e "  ${DIM}[INFO] Installing OpenSSH...${NC}"
        $PKG_MANAGER install -y openssh-server > /dev/null 2>&1
    fi
    
    configure_ssh
    install_ws_proxy_python
    create_ssh_ws_service
    
    INSTALLED_COMPONENTS+=("ssh-websocket")
    
    echo -e "  ${GREEN}[SUCCESS] SSH WebSocket configured on port ${SSH_WS_PORT}${NC}"
    show_footer
    sleep 1
}

configure_ssh() {
    cat > /etc/ssh/sshd_config.d/websocket.conf << 'EOF'
Port 22
ListenAddress 0.0.0.0
Protocol 2
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AllowTcpForwarding yes
GatewayPorts yes
X11Forwarding no
TCPKeepAlive yes
ClientAliveInterval 60
ClientAliveCountMax 3
SyslogFacility AUTH
LogLevel INFO
EOF
    
    systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true
}

install_ws_proxy_python() {
    cat > "$BIN_DIR/ssh-ws-proxy.py" << 'PYEOF'
#!/usr/bin/env python3
"""SSH WebSocket Proxy - Tunnel Manager"""
import asyncio, websockets, subprocess, os, sys, signal, logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class SSHWSProxy:
    def __init__(self):
        self.host = os.environ.get('WS_HOST', '0.0.0.0')
        self.port = int(os.environ.get('WS_PORT', '443'))
        self.server = None

    async def handle(self, ws):
        ip = ws.remote_address[0]
        logger.info(f"Conn from {ip}")
        proc = None
        try:
            proc = await asyncio.create_subprocess_exec(
                '/usr/sbin/sshd', '-i',
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            async def ws2ssh():
                try:
                    async for msg in ws:
                        if proc.stdin and not proc.stdin.is_closing():
                            proc.stdin.write(msg); await proc.stdin.drain()
                except: pass
                finally:
                    if proc.stdin and not proc.stdin.is_closing(): proc.stdin.close()

            async def ssh2ws():
                try:
                    while True:
                        data = await proc.stdout.read(4096)
                        if not data: break
                        await ws.send(data)
                except: pass
            
            await asyncio.gather(ws2ssh(), ssh2ws(), return_exceptions=True)
        except Exception as e:
            logger.error(f"Error: {e}")
        finally:
            if proc and proc.returncode is None:
                proc.terminate()
                try: await asyncio.wait_for(proc.wait(), timeout=5)
                except: proc.kill()
            logger.info(f"Disconnected {ip}")

    async def start(self):
        logger.info(f"Starting on {self.host}:{self.port}")
        self.server = await websockets.serve(
            self.handle, self.host, self.port,
            ping_interval=20, ping_timeout=20,
            max_size=10485760, compression=None
        )
        await self.server.wait_closed()

def main():
    proxy = SSHWSProxy()
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, lambda: (proxy.server.close(), loop.stop()))
    
    try: loop.run_until_complete(proxy.start())
    except KeyboardInterrupt: pass
    finally: loop.close()

if __name__ == '__main__': main()
PYEOF
    
    chmod +x "$BIN_DIR/ssh-ws-proxy.py"
    pip3 install websockets -q 2>/dev/null || pip install websockets -q 2>/dev/null || true
}

create_ssh_ws_service() {
    cat > /etc/systemd/system/ssh-websocket.service << EOF
[Unit]
Description=SSH WebSocket Proxy
After=network.target ssh.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 ${BIN_DIR}/ssh-ws-proxy.py
Restart=always
RestartSec=5
Environment=WS_HOST=0.0.0.0
Environment=WS_PORT=${SSH_WS_PORT}

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable ssh-websocket
    systemctl start ssh-websocket
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                NGINX CONFIGURATION                            ║
# ╚═══════════════════════════════════════════════════════════════════╝

configure_nginx() {
    show_header "Configuring Nginx"
    
    local domain="${DOMAIN:-localhost}"
    
    mkdir -p /var/www/certbot
    
    cat > /etc/nginx/sites-available/tunnel-manager << NGINXEOF
server {
    listen 80;
    listen [::]:80;
    server_name ${domain} www.${domain};
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        allow all;
    }
    
    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${domain};
    
    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    access_log ${LOG_DIR}/nginx_access.log;
    error_log ${LOG_DIR}/nginx_error.log;
    
    location /ssh-ws {
        proxy_pass http://127.0.0.1:${SSH_WS_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_read_timeout 86400s;
    }
    
    location /vless-ws {
        proxy_pass http://127.0.0.1:${XRAY_VLESS_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400s;
    }
    
    location /vmess-ws {
        proxy_pass http://127.0.0.1:${XRAY_VMESS_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400s;
    }
    
    location /trojan-ws {
        proxy_pass http://127.0.0.1:${XRAY_TROJAN_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400s;
    }
    
    location / { return 404; }
    location ~ /\. { deny all; }
}
NGINXEOF
    
    ln -sf /etc/nginx/sites-available/tunnel-manager /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    if nginx -t 2>/dev/null; then
        systemctl reload nginx
        echo -e "  ${GREEN}[SUCCESS] Nginx configured${NC}"
    else
        echo -e "  ${RED}[ERROR] Nginx config test failed${NC}"
    fi
    
    show_footer
    sleep 1
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                  SSL/TLS SETUP                                ║
# ╚═══════════════════════════════════════════════════════════════════╝

setup_ssl() {
    show_header "SSL Certificate Setup"
    
    local domain="${DOMAIN:-}"
    [[ -z "$domain" ]] && read_input "Domain name" domain
    DOMAIN="$domain"
    
    read_input "Email for certificate" DOMAIN_EMAIL "admin@${domain}"
    
    echo "$domain" > "$CONFIG_DIR/domain"
    echo "$DOMAIN_EMAIL" > "$CONFIG_DIR/email"
    
    echo -e "  ${DIM}[INFO] Requesting cert for: ${domain}${NC}"
    
    systemctl stop nginx 2>/dev/null || true
    
    if command -v certbot &> /dev/null; then
        certbot certonly --standalone --non-interactive --agree-tos \
            --email "$DOMAIN_EMAIL" -d "$domain" --redirect
    else
        install_acme_sh
        ~/.acme.sh/acme.sh --issue -d "$domain" --standalone \
            --accountemail "$DOMAIN_EMAIL" --force 2>/dev/null || true
        ~/.acme.sh/acme.sh --install-cert -d "$domain" \
            --key-file "/etc/letsencrypt/live/${domain}/privkey.pem" \
            --fullchain-file "/etc/letsencrypt/live/${domain}/fullchain.pem" \
            --reloadcmd "systemctl reload nginx"
    fi
    
    if [[ -f "/etc/letsencrypt/live/${domain}/fullchain.pem" ]]; then
        echo -e "  ${GREEN}[SUCCESS] SSL certificate obtained${NC}"
        setup_cert_renewal
    else
        echo -e "  ${YELLOW}[WARN] Using self-signed cert${NC}"
        generate_self_signed "$domain"
    fi
    
    systemctl start nginx 2>/dev/null || true
    show_footer
    sleep 1
}

install_acme_sh() {
    [[ -d ~/.acme.sh ]] && return
    
    echo -e "  ${DIM}[INFO] Installing acme.sh...${NC}"
    local temp_acme="$TEMP_DIR/acme.sh.tar.gz"
    
    if [[ -f "$ACME_SH_URL" ]]; then
        cp "$ACME_SH_URL" "$temp_acme"
    else
        curl -sL "$ACME_SH_URL" -o "$temp_acme"
    fi
    
    tar xzf "$temp_acme" -C "$TEMP_DIR" 2>/dev/null || true
    ~/.acme.sh/acme.sh --install-email "$DOMAIN_EMAIL" 2>/dev/null || true
}

generate_self_signed() {
    local domain=$1
    local dir="/etc/letsencrypt/live/${domain}"
    mkdir -p "$dir"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${dir}/privkey.pem" -out "${dir}/fullchain.pem" \
        -subj "/CN=${domain}" 2>/dev/null || true
}

setup_cert_renewal() {
    (crontab -l 2>/dev/null | grep -v 'certbot\|acme.sh'; \
     echo "0 3 * * * certbot renew --quiet --post-hook 'systemctl reload nginx' >/dev/null 2>&1") | crontab -
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║              XRAY CONFIG GENERATOR                           ║
# ╚═══════════════════════════════════════════════════════════════════╝

generate_xray_config() {
    show_header "Generating Xray Configuration"
    
    local domain="${DOMAIN:-$(cat $CONFIG_DIR/domain 2>/dev/null || echo 'localhost')}"
    local uuid=$(cat /proc/sys/kernel/random/uuid)
    local trojan_pass=$(openssl rand -base32 16)
    local ss_pass=$(openssl rand -base64 16)
    
    local xray_conf="/usr/local/etc/xray"
    mkdir -p "$xray_conf"
    
    cat > "$xray_conf/config.json" << XRAYEOF
{
    "log": {"loglevel": "warning", "access": "${LOG_DIR}/xray_access.log", "error": "${LOG_DIR}/xray_error.log"},
    "dns": {"servers": ["https+local://1.1.1.1/dns-query", "https+local://8.8.8.8/dns-query", "localhost"]},
    "inbounds": [
        {
            "tag": "vless-in", "port": ${XRAY_VLESS_PORT}, "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {"clients": [{"id": "${uuid}", "flow": "xtls-rprx-vision", "email": "user@local"}], "decryption": "none"},
            "streamSettings": {"network": "ws", "wsSettings": {"path": "/vless-ws"}}
        },
        {
            "tag": "vmess-in", "port": ${XRAY_VMESS_PORT}, "listen": "127.0.0.1",
            "protocol": "vmess",
            "settings": {"clients": [{"id": "$(cat /proc/sys/kernel/random/uuid)", "alterId": 0, "email": "user@local"}]},
            "streamSettings": {"network": "ws", "wsSettings": {"path": "/vmess-ws"}}
        },
        {
            "tag": "trojan-in", "port": ${XRAY_TROJAN_PORT}, "listen": "127.0.0.1",
            "protocol": "trojan",
            "settings": {"clients": [{"password": "${trojan_pass}", "email": "user@local"}]},
            "streamSettings": {"network": "ws", "wsSettings": {"path": "/trojan-ws"}}
        },
        {
            "tag": "ss-in", "port": ${XRAY_SS_PORT}, "listen": "127.0.0.1",
            "protocol": "shadowsocks",
            "settings": {"clients": [{"method": "chacha20-ietf-poly1305", "password": "${ss_pass}", "email": "user@local"}]}
        }
    ],
    "outbounds": [
        {"protocol": "freedom", "tag": "direct"},
        {"protocol": "blackhole", "tag": "blocked"}
    ],
    "routing": {"domainStrategy": "IPIfNonMatch", "rules": [
        {"type": "field", "ip": ["geoip:private"], "outboundTag": "direct"}
    ]}
}
XRAYEOF
    
    save_connection_info "$domain" "$uuid" "$trojan_pass" "$ss_pass"
    systemctl restart xray 2>/dev/null || true
    
    echo -e "  ${GREEN}[SUCCESS] Config generated${NC}"
    show_footer
    sleep 1
}

save_connection_info() {
    local d=$1 u=$2 t=$3 s=$4
    cat > "$CONFIG_DIR/connection-info.txt" << EOF
=====================================
CONNECTION INFORMATION
Domain: ${d}
Generated: $(date)
=====================================

[VLESS WS-TLS]
Address: ${d}:443
UUID: ${u}
Path: /vless-ws
TLS: enabled
Flow: xtls-rprx-vision

[VMess WS-TLS]
Address: ${d}:443
Path: /vmess-ws
TLS: enabled

[Trojan WS-TLS]
Address: ${d}:443
Password: ${t}
Path: /trojan-ws
TLS: enabled

[Shadowsocks]
Address: ${d}:${XRAY_SS_PORT}
Password: ${s}
Method: chacha20-ietf-poly1305

[SSH WebSocket]
Address: ${d}:443
Path: /ssh-ws
User: root
EOF
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                 USER MANAGEMENT                              ║
# ╚═══════════════════════════════════════════════════════════════════╝

add_user() {
    show_header "Add User"
    
    read_input "Username" username
    read_password "Password" password
    select_menu "Protocol" "VLESS" "VMess" "Trojan" "Shadowsocks" "SSH"
    local proto=$?
    read_input "Expiry Days" exp "30"
    read_input "Traffic Limit" traffic "10GB"
    
    local expiry=$(date -d "+${exp} days" '+%Y-%m-%d' 2>/dev/null || date -v+${exp}d '+%Y-%m-%d')
    
    local names=("vless" "vmess" "trojan" "shadowsocks" "ssh")
    local pname="${names[$((proto-1))]:-unknown}"
    
    mkdir -p "$CONFIG_DIR/users"
    cat > "$CONFIG_DIR/users/${username}.json" << EOF
{"username":"${username}","password":"${password}","protocol":"${pname}","created":"$(date '+%Y-%m-%d %H:%M:%S')","expiry":"${expiry}","traffic_limit":"${traffic}","used":"0B","status":"active","uuid":"$(cat /proc/sys/kernel/random::uuid)"}
EOF
    
    echo -e "\n  ${GREEN}[OK] User '${username}' created (${pname})${NC}"
    echo -e "     Expiry: ${expiry} | Limit: ${traffic}"
    show_footer
}

list_users() {
    show_header "Active Users"
    
    if [[ ! -d "$CONFIG_DIR/users" ]] || [[ -z "$(ls $CONFIG_DIR/users/*.json 2>/dev/null)" ]]; then
        echo -e "  ${YELLOW}No users found${NC}"
        show_footer
        return
    fi
    
    echo -e "  ${BOLD}Username     │ Proto    │ Status   │ Traffic │ Expiry${NC}"
    draw_line
    
    for f in $CONFIG_DIR/users/*.json; do
        [[ -f "$f" ]] || continue
        local u=$(jq -r '.username' "$f" 2>/dev/null || basename "$f" .json)
        local p=$(jq -r '.protocol' "$f" 2>/dev/null || echo "?")
        local s=$(jq -r '.status' "$f" 2>/dev/null || echo "?")
        local t=$(jq -r '.used' "$f" 2>/dev/null || echo "?")
        local e=$(jq -r '.expiry' "$f" 2>/dev/null || echo "?")
        
        local sc="$s"
        [[ "$s" == "active" ]] && sc="${GREEN}Active${NC}"
        [[ "$s" == "expired" ]] && sc="${RED}Expired${NC}"
        
        printf "  %-12s │ %-8s │ %b │ %-7s │ %s\n" "$u" "$p" "$sc" "$t" "$e"
    done
    
    show_footer
    read -p "  Enter to continue..."
}

delete_user() {
    show_header "Delete User"
    list_users_short
    read_input "Username" username
    
    if [[ -f "$CONFIG_DIR/users/${username}.json" ]]; then
        confirm "Delete '$username'?" && rm -f "$CONFIG_DIR/users/${username}.json" && \
            echo -e "  ${GREEN}[OK] Deleted${NC}" || echo -e "  ${YELLOW}Cancelled${NC}"
    else
        echo -e "  ${RED}Not found${NC}"
    fi
    show_footer
}

list_users_short() {
    [[ -d "$CONFIG_DIR/users" ]] && ls "$CONFIG_DIR/users/"*.json 2>/dev/null | while read f; do
        basename "$f" .json
    done
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                  MONITORING                                   ║
# ╚═══════════════════════════════════════════════════════════════════╝

show_dashboard() {
    show_banner
    echo -e "  ${BOLD}${WHITE}SYSTEM DASHBOARD${NC}\n"
    
    echo -e "  ${CYAN}System${NC}"
    draw_line
    echo -e "  ${WHITE}OS:${NC}         $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "  ${WHITE}Kernel:${NC}      $(uname -r)"
    echo -e "  ${WHITE}Uptime:${NC}      $(uptime -p 2>/dev/null || uptime)"
    echo -e "  ${WHITE}CPU:${NC}         $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)%"
    echo -e "  ${WHITE}Memory:${NC}      $(free -h | awk '/Mem:/ {printf "%s/%s (%.0f%%)", $3, $2, $3/$2*100}')"
    echo -e "  ${WHITE}Disk:${NC}        $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo ""
    
    echo -e "  ${CYAN}Services${NC}"
    draw_line
    for svc in nginx xray ssh ssh-websocket; do
        local st="${RED}● STOPPED${NC}"
        systemctl is-active --quiet "$svc" 2>/dev/null && st="${GREEN}● RUNNING${NC}"
        printf "  %-14s %b\n" "$svc:" "$st"
    done
    echo ""
    
    echo -e "  ${CYAN}Network${NC}"
    draw_line
    echo -e "  ${WHITE}Public IP:${NC}   $(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo 'N/A')"
    echo -e "  ${WHITE}Domain:${NC}       $(cat $CONFIG_DIR/domain 2>/dev/null || echo 'Not set')"
    echo -e "  ${WHITE}Connections:${NC}  $(ss -tnp 2>/dev/null | grep -cE '(xray|ssh)' || echo 0)"
    echo ""
    
    read -p "  Enter to continue..."
}

view_logs() {
    show_header "Log Viewer"
    select_menu "Log File" "Xray Error" "Xray Access" "Nginx Error" "Nginx Access" "Journal(Xray)" "Journal(SSH-WS)"
    local c=$?
    
    case $c in
        1) less "$LOG_DIR/xray_error.log" 2>/dev/null || echo "No log" ;;
        2) less "$LOG_DIR/xray_access.log" 2>/dev/null || echo "No log" ;;
        3) less "$LOG_DIR/nginx_error.log" 2>/dev/null || echo "No log" ;;
        4) less "$LOG_DIR/nginx_access.log" 2>/dev/null || echo "No log" ;;
        5) journalctl -u xray -n 50 --no-pager ;;
        6) journalctl -u ssh-websocket -n 50 --no-pager ;;
        *) return ;;
    esac
    echo ""; read -p "  Enter to continue..."
}

show_conn_info() {
    show_header "Connection Info"
    [[ -f "$CONFIG_DIR/connection-info.txt" ]] && cat "$CONFIG_DIR/connection-info.txt" || echo -e "  ${YELLOW}Run config first${NC}"
    show_footer
    read -p "  Enter to continue..."
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                   UTILITIES                                   ║
# ╚═══════════════════════════════════════════════════════════════════╝

restart_all() {
    show_header "Restart Services"
    local svcs=(nginx xray ssh-websocket)
    local total=${#svcs[@]}
    local i=0
    
    for svc in "${svcs[@]}"; do
        ((i++))
        progress_bar "Restarting $svc" $i $total
        systemctl restart "$svc" 2>/dev/null || true
    done
    
    echo ""; progress_complete "All restarted"
    show_footer; sleep 1
}

renew_ssl() {
    show_header "Renew SSL"
    local d=$(cat $CONFIG_DIR/domain 2>/dev/null || echo "")
    [[ -z "$d" ]] && echo -e "  ${RED}No domain${NC}" && show_footer && return
    
    command -v certbot &>/dev/null && certbot renew --force-renewal || \
        ~/.acme.sh/acme.sh --renew -d "$d" --force 2>/dev/null || true
    systemctl reload nginx 2>/dev/null || true
    echo -e "  ${GREEN}[OK] Renewed${NC}"
    show_footer; sleep 1
}

clear_logs() {
    show_header "Clear Logs"
    confirm "Clear all logs?" && (rm -f "$LOG_DIR"/*.log; journalctl --vacuum-time=1s 2>/dev/null; echo -e "  ${GREEN}[OK] Cleared${NC}") || echo -e "  ${YELLOW}Cancelled${NC}"
    show_footer; sleep 1
}

uninstall_all() {
    show_banner
    echo -e "  ${RED}${BOLD}⚠  UNINSTALL MODE  ⚠${NC}\n"
    confirm "Remove EVERYTHING permanently?" || return
    
    echo -e "\n  ${DIM}Removing...${NC}"
    for svc in xray ssh-websocket; do
        systemctl stop "$svc" 2>/dev/null; systemctl disable "$svc" 2>/dev/null
        rm -f "/etc/systemd/system/${svc}.service"
    done
    
    rm -rf /usr/local/xray /usr/local/etc/xray "$INSTALL_DIR" "$CONFIG_DIR" "$LOG_DIR" "$CACHE_DIR"
    rm -f "$BIN_DIR/ssh-ws-proxy.py" "$BIN_DIR/xray"
    rm -f /etc/nginx/sites-available/tunnel-manager /etc/nginx/sites-enabled/tunnel-manager
    nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || true
    systemctl daemon-reload
    
    echo -e "\n  ${GREEN}[OK] Uninstalled completely${NC}"
    exit 0
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║            ★★★ OS REBUILD / REINSTALL ★★★                    ║
# ╚═══════════════════════════════════════════════════════════════════╝

menu_rebuild_os() {
    while true; do
        show_banner
        echo -e "  ${BOLD}${RED}★ OS REBUILD / REINSTALL CENTER ★${NC}\n"
        
        echo -e "  ${WHITE}Script source: ${ACTIVE_REINSTALL_SCRIPT_URL_1:0:60}...${NC}\n"
        
        echo -e "  ${RED}[1]${NC} Reinstall OS (Interactive Wizard)"
        echo -e "     Pilih OS dan versi, ikuti panduan\n"
        
        echo -e "  ${RED}[2]${NC} Quick Reinstall - Debian 12 (Bookworm)"
        echo -e "  ${RED}[3]${NC} Quick Reinstall - Debian 11 (Bullseye)"
        echo -e "  ${RED}[4]${NC} Quick Reinstall - Ubuntu 22.04 LTS (Jammy)"
        echo -e "  ${RED}[5]${NC} Quick Reinstall - Ubuntu 24.04 LTS (Noble)"
        echo -e "  ${RED}[6]${NC} Quick Reinstall - CentOS Stream 9"
        echo -e "  ${RED}[7]${NC} Quick Reinstall - AlmaLinux 9"
        echo -e "  ${RED}[8]${NC} Quick Reinstall - Rocky Linux 9"
        echo ""
        
        echo -e "  ${YELLOW}[9]${NC} Advanced Options"
        echo -e "     Set password • Change mirror • Custom ISO\n"
        
        echo -e "  ${RED}[0]${NC} Back to Main Menu"
        echo ""
        
        echo -en "  ${RED}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) run_reinstall_wizard ;;
            2) run_quick_reinstall "debian" "12" ;;
            3) run_quick_reinstall "debian" "11" ;;
            4) run_quick_reinstall "ubuntu" "22.04" ;;
            5) run_quick_reinstall "ubuntu" "24.04" ;;
            6) run_quick_reinstall "centos" "9" ;;
            7) run_quick_reinstall "almalinux" "9" ;;
            8) run_quick_reinstall "rockylinux" "9" ;;
            9) menu_rebuild_advanced ;;
            0) return ;;
            *) 
                echo -e "\n  ${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

run_reinstall_wizard() {
    show_header "OS Reinstall Wizard"
    
    echo -e "  ${WHITE}${BOLD}⚠ WARNING: This will ERASE your entire system! ⚠${NC}\n"
    echo -e "  ${DIM}This will download and run the OS reinstall script.${NC}"
    echo -e "  ${DIM}Make sure you have backed up important data!${NC}\n"
    
    confirm "Continue with OS reinstall?" || { show_footer; return; }
    
    echo -e "\n  ${DIM}[INFO] Downloading reinstall script...${NC}"
    
    local script_path="$TEMP_DIR/reinstall.sh"
    
    if download_file "$ACTIVE_REINSTALL_SCRIPT" "$script_path" "Reinstall Script"; then
        chmod +x "$script_path"
        
        echo -e "\n  ${GREEN}[OK] Script downloaded${NC}"
        echo -e "  ${DIM}[INFO] Running interactive wizard...${NC}"
        echo -e "  ${DIM}Follow the on-screen instructions.${NC}\n"
        
        sleep 2
        bash "$script_path"
    else
        echo -e "\n  ${RED}[ERROR] Failed to download reinstall script${NC}"
        echo -e "  ${YELLOW}[TIP] Check your internet connection or change script URL${NC}"
    fi
    
    show_footer
    read -p "  Enter to continue..."
}

run_quick_reinstall() {
    local os=$1
    local ver=$2
    
    show_header "Quick Reinstall: ${os^^} ${ver}"
    
    echo -e "  ${RED}${BOLD}⚠ THIS WILL WIPE YOUR SYSTEM! ⚠${NC}\n"
    echo -e "  Target: ${WHITE}${os^^} ${ver}${NC}"
    echo -e "  Script: ${ACTIVE_REINSTALL_SCRIPT_URL_1:0:50}...\n"
    
    confirm "Reinstall to ${os^^} ${ver} NOW?" || { show_footer; return; }
    
    # Read password
    read_password "New root password" root_pass
    [[ -z "$root_pass" ]] && echo -e "  ${RED}Password required${NC}" && return
    
    echo -e "\n  ${DIM}[INFO] Starting reinstall...${NC}"
    
    local script_path="$TEMP_DIR/reinstall.sh"
    
    if download_file "$ACTIVE_REINSTALL_SCRIPT" "$script_path" "Reinstall Script"; then
        chmod +x "$script_path"
        
        echo -e "  ${DIM}[INFO] Running: bash ${script_path} -${os} ${ver}${NC}\n"
        
        sleep 2
        
        # Run with appropriate flags based on script type
        case $os in
            debian)
                bash "$script_path" -debian "$ver" -pwd "$root_pass"
                ;;
            ubuntu)
                bash "$script_path" -ubuntu "$ver" -pwd "$root_pass"
                ;;
            centos|almalinux|rockylinux)
                bash "$script_path" -centos "$ver" -pwd "$root_pass"
                ;;
            *)
                bash "$script_path"
                ;;
        esac
    else
        echo -e "  ${RED}[ERROR] Download failed${NC}"
    fi
    
    show_footer
}

menu_rebuild_advanced() {
    while true; do
        show_banner
        echo -e "  ${BOLD}${YELLOW}★ ADVANCED REBUILD OPTIONS ★${NC}\n"
        
        echo -e "  ${YELLOW}[1]${NC} Set Root Password"
        echo -e "  ${YELLOW}[2]${NC} Change Download Mirror"
        echo -e "  ${YELLOW}[3]${NC} Use Alternative Script (InstallNET.sh)"
        echo -e "  ${YELLOW}[4]${NC} List All Supported OS"
        echo -e "  ${YELLOW}[5]${NC} DD Mode (Custom Image)"
        echo ""
        echo -e "  ${RED}[0]${NC} Back"
        echo ""
        
        echo -en "  ${YELLOW}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) 
                read_password "New root password" rp
                echo -e "\n  ${DIM}Password saved (use during reinstall)${NC}"
                sleep 1
                ;;
            2)
                echo -e "\n  ${WHITE}Current mirror: Default (auto-detect)${NC}"
                select_menu "Select Mirror" "Auto (Default)" "Aliyun (China)" "Tencent (China)" "Huawei (China)" "Official"
                local mc=$?
                case $mc in
                    1) echo -e "  ${DIM}Using auto mirror${NC}" ;;
                    2) echo -e "  ${DIM}Using Aliyun mirror${NC}" ;;  # Would need to modify script args
                    3) echo -e "  ${DIM}Using Tencent mirror${NC}" ;;
                    4) echo -e "  ${DIM}Using Huawei mirror${NC}" ;;
                    5) echo -e "  ${DIM}Using official mirrors${NC}" ;;
                esac
                sleep 1
                ;;
            3)
                ACTIVE_REINSTALL_SCRIPT="$REINSTALL_SCRIPT_URL_2"
                echo -e "\n  ${GREEN}[OK] Switched to InstallNET.sh${NC}"
                echo -e "  ${DIM}${REINSTALL_SCRIPT_URL_2:0:60}...${NC}"
                sleep 2
                ;;
            4)
                show_supported_os_list
                ;;
            5)
                echo -e "\n  ${WHITE}DD Mode - Install custom image${NC}"
                echo -e "  ${DIM}Provide URL to raw/image file (.iso, .img, .gz)${NC}"
                read_input "Image URL" img_url
                [[ -n "$img_url" ]] && echo -e "  ${DIM}Would run: reinstall.sh -dd ${img_url}${NC}"
                sleep 2
                ;;
            0) return ;;
            *) 
                echo -e "\n  ${RED}Invalid${NC}"
                sleep 1
                ;;
        esac
    done
}

show_supported_os_list() {
    show_header "Supported Operating Systems"
    
    echo -e "  ${BOLD}${WHITE}Linux Distributions:${NC}\n"
    
    echo -e "  ${CYAN}Debian:${NC}"
    echo -e "    • Debian 9 (Stretch)"
    echo -e "    • Debian 10 (Buster)"
    echo -e "    • Debian 11 (Bullseye)"
    echo -e "    • Debian 12 (Bookworm)"
    echo -e "    • Debian 13 (Trixie)\n"
    
    echo -e "  ${CYAN}Ubuntu:${NC}"
    echo -e "    • Ubuntu 18.04 LTS (Bionic Beaver)"
    echo -e "    • Ubuntu 20.04 LTS (Focal Fossa)"
    echo -e "    • Ubuntu 22.04 LTS (Jammy Jellyfish)"
    echo -e "    • Ubuntu 24.04 LTS (Noble Numbat)"
    echo -e "    • Ubuntu 26.04 LTS (Future)\n"
    
    echo -e "  ${CYAN}RHEL Family:${NC}"
    echo -e "    • CentOS 7, 8, 9"
    echo -e "    • RHEL 8, 9, 10"
    echo -e "    • AlmaLinux 8, 9"
    echo -e "    • Rocky Linux 8, 9"
    echo -e "    • Oracle Linux 8, 9\n"
    
    echo -e "  ${CYAN}Others:${NC}"
    echo -e "    • Kali Linux (Rolling)"
    echo -e "    • Fedora (Latest)"
    echo -e "    • Alpine Linux 3.21-3.24"
    echo -e "    • Anolis OS 7, 8, 23"
    echo -e "    • OpenCloudOS 8, 9, Stream 23\n"
    
    echo -e "  ${RED}${BOLD}Windows:${NC}"
    echo -e "    • Windows Server 2019/2022 (via DD mode)"
    echo -e "    • Windows 10/11 (via DD mode)\n"
    
    echo -e "  ${DIM}Note: ARM servers supported for most Linux distros${NC}"
    
    show_footer
    read -p "  Enter to continue..."
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                    MAIN MENUS                                 ║
# ╚═══════════════════════════════════════════════════════════════════╝

main_menu() {
    while true; do
        show_banner
        
        echo -e "  ${BOLD}${WHITE}MAIN MENU${NC}\n"
        
        echo -e "  ${GRAD1}[1]${NC} ${WHITE}Installation Center${NC}"
        echo -e "     Full Setup • Components • Dependencies\n"
        
        echo -e "  ${GRAD2}[2]${NC} ${WHITE}Configuration${NC}"
        echo -e "     Domain/SSL • Xray Config • Nginx\n"
        
        echo -e "  ${GRAD3}[3]${NC} ${WHITE}User Management${NC}"
        echo -e "     Add • List • Delete Users\n"
        
        echo -e "  ${GRAD4}[4]${NC} ${WHITE}Monitoring & Tools${NC}"
        echo -e "     Dashboard • Logs • Connection Info\n"
        
        echo -e "  ${GRAD5}[5]${NC} ${WHITE}Utilities${NC}"
        echo -e "     Restart • Renew SSL • Clear Logs\n"
        
        echo -e "  ${RED}[6]${NC} ${WHITE}${BOLD}★ OS REBUILD / REINSTALL ★${NC}"
        echo -e "     Reinstall OS • 19+ Distros Supported\n"
        
        draw_line
        echo -e "  ${RED}[0]${NC} Exit  ${RED}[U]${NC} Uninstall"
        echo ""
        
        echo -en "  ${CYAN}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) submenu_install ;;
            2) submenu_config ;;
            3) submenu_users ;;
            4) submenu_monitor ;;
            5) submenu_utils ;;
            6) menu_rebuild_os ;;
            0|q|Q) echo -e "\n  ${DIM}Bye!${NC}"; exit 0 ;;
            u|U) uninstall_all ;;
            *)
                echo -e "\n  ${RED}Invalid: ${choice}${NC}"
                sleep 1
                ;;
        esac
    done
}

submenu_install() {
    while true; do
        show_banner
        echo -e "  ${BOLD}${WHITE}INSTALLATION${NC}\n"
        echo -e "  ${CYAN}[1]${NC} Full Installation (All-in-One)"
        echo -e "  ${CYAN}[2]${NC} Packages Only"
        echo -e "  ${CYAN}[3]${NC} Xray-Core Only"
        echo -e "  ${CYAN}[4]${NC} SSH WebSocket Only"
        echo -e "  ${CYAN}[5]${NC} Setup Wizard (Guided)"
        echo ""
        echo -e "  ${RED}[0]${NC} Back"
        echo ""
        echo -en "  ${CYAN}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) full_install ;;
            2) install_packages ;;
            3) install_xray_core ;;
            4) install_ssh_websocket ;;
            5) setup_wizard ;;
            0) return ;;
            *) echo -e "\n  ${RED}Invalid${NC}"; sleep 1 ;;
        esac
    done
}

submenu_config() {
    while true; do
        show_banner
        echo -e "  ${BOLD}${WHITE}CONFIGURATION${NC}\n"
        echo -e "  ${PURPLE}[1]${NC} Domain & SSL Setup"
        echo -e "  ${PURPLE}[2]${NC} Generate Xray Config"
        echo -e "  ${PURPLE}[3]${NC} Configure Nginx"
        echo -e "  ${PURPLE}[4]${NC} View Connection Info"
        echo ""
        echo -e "  ${RED}[0]${NC} Back"
        echo ""
        echo -en "  ${CYAN}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) setup_ssl ;;
            2) generate_xray_config ;;
            3) configure_nginx ;;
            4) show_conn_info ;;
            0) return ;;
            *) echo -e "\n  ${RED}Invalid${NC}"; sleep 1 ;;
        esac
    done
}

submenu_users() {
    while true; do
        show_banner
        echo -e "  ${BOLD}${WHITE}USERS${NC}\n"
        echo -e "  ${GREEN}[1]${NC} Add User"
        echo -e "  ${GREEN}[2]${NC} List Users"
        echo -e "  ${GREEN}[3]${NC} Delete User"
        echo ""
        echo -e "  ${RED}[0]${NC} Back"
        echo ""
        echo -en "  ${CYAN}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) add_user ;;
            2) list_users ;;
            3) delete_user ;;
            0) return ;;
            *) echo -e "\n  ${RED}Invalid${NC}"; sleep 1 ;;
        esac
    done
}

submenu_monitor() {
    while true; do
        show_banner
        echo -e "  ${BOLD}${WHITE}MONITORING${NC}\n"
        echo -e "  ${BLUE}[1]${NC} Dashboard"
        echo -e "  ${BLUE}[2]${NC} View Logs"
        echo -e "  ${BLUE}[3]${NC} Connection Info"
        echo -e "  ${BLUE}[4]${NC} Active Connections"
        echo ""
        echo -e "  ${RED}[0]${NC} Back"
        echo ""
        echo -en "  ${CYAN}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) show_dashboard ;;
            2) view_logs ;;
            3) show_conn_info ;;
            4) ss -tnp | head -20 || echo "No conns" ;;
            0) return ;;
            *) echo -e "\n  ${RED}Invalid${NC}"; sleep 1 ;;
        esac
    done
}

submenu_utils() {
    while true; do
        show_banner
        echo -e "  ${BOLD}${WHITE}UTILITIES${NC}\n"
        echo -e "  ${YELLOW}[1]${NC} Restart All Services"
        echo -e "  ${YELLOW}[2]${NC} Renew SSL Certificate"
        echo -e "  ${YELLOW}[3]${NC} Clear Logs"
        echo ""
        echo -e "  ${RED}[0]${NC} Back"
        echo ""
        echo -en "  ${CYAN}▸${NC} Select: "
        read -r choice
        
        case $choice in
            1) restart_all ;;
            2) renew_ssl ;;
            3) clear_logs ;;
            0) return ;;
            *) echo -e "\n  ${RED}Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                 INSTALLATION WIZARDS                          ║
# ╚═══════════════════════════════════════════════════════════════════╝

full_install() {
    show_header "Full Installation"
    
    echo -e "  ${WHITE}This will install:${NC}"
    echo -e "  • System packages"
    echo -e "  • Xray-Core v$(get_xray_real_version) ($ARCH)"
    echo -e "  • SSH WebSocket Proxy"
    echo -e "  • Nginx + SSL\n"
    
    confirm "Proceed?" || { show_footer; return; }
    
    echo ""
    install_packages
    install_xray_core
    install_ssh_websocket
    setup_ssl
    configure_nginx
    generate_xray_config
    
    echo -e "\n  ${GREEN}${BOLD}✓ Installation complete!${NC}"
    show_footer
    sleep 1
}

setup_wizard() {
    show_header "Setup Wizard"
    
    echo -e "  ${WHITE}Welcome! Follow the steps below.\n${NC}"
    
    echo -e "  ${BOLD}${CYAN}Step 1/4: Domain${NC}"
    read_input "Domain" DOMAIN
    read_input "Email" DOMAIN_EMAIL "admin@${DOMAIN}"
    echo "$DOMAIN" > "$CONFIG_DIR/domain"
    echo "$DOMAIN_EMAIL" > "$CONFIG_DIR/email"
    echo -e "  ${GREEN}[OK]${NC}\n"
    
    echo -e "  ${BOLD}${CYAN}Step 2/4: Install Components${NC}"
    install_packages
    install_xray_core
    install_ssh_websocket
    echo -e "  ${GREEN}[OK]${NC}\n"
    
    echo -e "  ${BOLD}${CYAN}Step 3/4: SSL & Nginx${NC}"
    setup_ssl
    configure_nginx
    echo -e "  ${GREEN}[OK]${NC}\n"
    
    echo -e "  ${BOLD}${CYAN}Step 4/4: Final Config${NC}"
    generate_xray_config
    echo -e "  ${GREEN}[OK]${NC}\n"
    
    echo -e "  ${GREEN}${BOLD}✓ Setup complete!${NC}"
    show_footer
    read -p "  Enter to see dashboard..." && show_dashboard
}

# ╔═══════════════════════════════════════════════════════════════════╗
# ║                      MAIN ENTRY                               ║
# ╚═══════════════════════════════════════════════════════════════════╝

main() {
    init_system
    main_menu
}

cleanup() {
    rm -rf "$TEMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

main "$@"
