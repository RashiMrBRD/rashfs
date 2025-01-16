#!/bin/bash

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Function to display tips
show_tips() {
    echo -e "\n${GREEN}=== Helpful Tips ===${RESET}"
    echo -e "${YELLOW}1. NFS Setup:${RESET}"
    echo "   - Ensure NFS server is running and accessible"
    echo "   - Check firewall settings (ports 111, 2049)"
    echo "   - Test NFS connection: mount -t nfs server:/share /mnt/test"
    
    echo -e "\n${YELLOW}2. Common Issues:${RESET}"
    echo "   - Permission denied: Check NFS export permissions"
    echo "   - Connection refused: Verify NFS service is running"
    echo "   - Timeout: Check network connectivity and firewall"
    
    echo -e "\n${YELLOW}3. Useful Commands:${RESET}"
    echo "   - showmount -e <server>     : List available shares"
    echo "   - systemctl status autofs   : Check autofs status"
    echo "   - tail -f /var/log/syslog   : Monitor autofs logs"
    echo "   - exportfs -v               : View exported shares"
    
    echo -e "\n${YELLOW}4. Configuration Files:${RESET}"
    echo "   - /etc/auto.master          : Master map file"
    echo "   - /etc/auto.nfs             : NFS mount points"
    echo "   - /etc/exports              : NFS export config"
    
    echo -e "\n${YELLOW}5. Testing:${RESET}"
    echo "   - Access mount point to trigger automount"
    echo "   - Use 'df -h' to verify mounted shares"
    echo "   - Check 'mount | grep nfs' for active mounts"
}

# Function to display usage
usage() {
    echo -e "${GREEN}Usage: $0 [option]${RESET}"
    echo -e "${YELLOW}Options:${RESET}"
    echo "  install   - Install and configure autofs"
    echo "  uninstall - Remove autofs and cleanup configuration"
    echo "  tips      - Show helpful tips and troubleshooting guide"
    echo "  status    - Check autofs service status"
    echo "  -h,--help - Show this help message"
    echo -e "\n${YELLOW}Examples:${RESET}"
    echo "  $0                  # Run installation"
    echo "  $0 install         # Run installation explicitly"
    echo "  $0 uninstall      # Remove autofs and cleanup"
    echo "  $0 tips           # Show helpful tips"
    exit 1
}

# Function to check status
check_status() {
    echo -e "${GREEN}=== Autofs Status ===${RESET}"
    if systemctl is-active --quiet autofs; then
        echo -e "${GREEN}● Autofs service is running${RESET}"
    else
        echo -e "${RED}○ Autofs service is not running${RESET}"
    fi
    
    echo -e "\n${YELLOW}Active Mounts:${RESET}"
    mount | grep "autofs" || echo "No autofs mounts found"
    
    echo -e "\n${YELLOW}Service Status:${RESET}"
    systemctl status autofs
}

# Function to uninstall autofs
uninstall_autofs() {
    echo -e "${YELLOW}Uninstalling autofs...${RESET}"
    
    # Stop autofs service
    echo "Stopping autofs service..."
    sudo systemctl stop autofs
    
    # Remove autofs package
    echo "Removing autofs package..."
    sudo apt-get remove -y autofs
    sudo apt-get autoremove -y
    
    # Backup and remove configuration files
    local backup_dir="/etc/autofs_backup_$(date +%Y%m%d_%H%M%S)"
    sudo mkdir -p "$backup_dir"
    
    if [ -f "/etc/auto.master" ]; then
        echo "Backing up /etc/auto.master..."
        sudo cp /etc/auto.master "$backup_dir/"
        sudo rm /etc/auto.master
    fi
    
    if [ -f "/etc/auto.nfs" ]; then
        echo "Backing up /etc/auto.nfs..."
        sudo cp /etc/auto.nfs "$backup_dir/"
        sudo rm /etc/auto.nfs
    fi
    
    echo -e "${GREEN}Autofs has been uninstalled${RESET}"
    echo -e "${YELLOW}Configuration files backed up to: $backup_dir${RESET}"
    echo -e "${YELLOW}Tip: To restore configurations later, copy files back from the backup directory${RESET}"
    exit 0
}

# Function to display a progress bar
progress_bar() {
    local duration=$1
    already_done() { for ((done=0; done<$elapsed; done++)); do printf "▇"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }
    for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
        already_done; remaining; percentage
        sleep 0.1
        clean_line
    done
    printf "\n"
}

# Function to display a completion message in ASCII art
display_completion_message() {
    echo -e "${GREEN}RRRRRRRR AAAAAAAA SSSSSSSS HHHHHHHH R R A A S H H RRRRRRRR AAAAAAAA SSSSSSSS HHHHHHHH R R A A S H H R R A A SSSSSSSS H H${RESET}"
    echo -e "${GREEN}  RRRR   AAAAA  SSSS  H   H  III  N   N  SSSS  TTTTT  AAAAA  L     L${RESET}"
    echo -e "${GREEN}  R   R  A   A  S     H   H   I   NN  N  S        T    A   A  L     L${RESET}"
    echo -e "${GREEN}  RRRR   AAAAA  SSSS  HHHHH   I   N N N   SSSS    T    AAAAA  L     L${RESET}"
    echo -e "${GREEN}  R  R   A   A      S H   H   I   N  NN       S    T    A   A  L     L${RESET}"
    echo -e "${GREEN}  R   R  A   A  SSSS  H   H  III  N   N  SSSS    T    A   A  LLLLL LLLLL${RESET}"
    echo -e "${GREEN}iiii n n sssss ttttt a l i nn n s t a a l i n n n sss t aaaa l i n nn n s t a a l iiii n n sssss t a a lllll${RESET}"
    echo ""
}

# Check command line arguments
case "$1" in
    "install"|"")
        echo -e "${GREEN}Starting autofs installation...${RESET}"
        echo -e "${BLUE}RRRRRRRR AAAAAAAA SSSSSSSS HHHHHHHH R R A A S H H RRRRRRRR AAAAAAAA SSSSSSSS HHHHHHHH R R A A S H H R R A A SSSSSSSS H H${RESET}"
        echo -e "${BLUE}  RRRR   AAAAA  SSSS  H   H  III  N   N  SSSS  TTTTT  AAAAA  L     L${RESET}"
        echo -e "${BLUE}  R   R  A   A  S     H   H   I   NN  N  S        T    A   A  L     L${RESET}"
        echo -e "${BLUE}  RRRR   AAAAA  SSSS  HHHHH   I   N N N   SSSS    T    AAAAA  L     L${RESET}"
        echo -e "${BLUE}  R  R   A   A      S H   H   I   N  NN       S    T    A   A  L     L${RESET}"
        echo -e "${BLUE}  R   R  A   A  SSSS  H   H  III  N   N  SSSS    T    A   A  LLLLL LLLLL${RESET}"
        echo -e "${BLUE}iiii n n sssss ttttt a l i nn n s t a a l i n n n sss t aaaa l i n nn n s t a a l iiii n n sssss t a a lllll${RESET}"
        echo ""

        echo "Starting autofs setup..."

        # Create directories
        DEFAULT_DIRS="ArBackup,Seapedia1T,WDHDElements,TOSHIBA,HitaExBuffer,HitachI500BD,stereotypes,RashDATA,InRash,WDBLUE160,GRestore,WRoot,RRoot"
        read -p "Enter custom directory names separated by commas (or press Enter to use defaults): " CUSTOM_DIRS

        DIRS=${CUSTOM_DIRS:-$DEFAULT_DIRS}

        # Check and create directories if they don't exist
        DIR_CREATED=false
        IFS=',' read -ra ADDR <<< "$DIRS"
        for dir in "${ADDR[@]}"; do
            if [ ! -d "/mnt/$dir" ]; then
                if [ "$DIR_CREATED" = false ]; then
                    echo "Creating directories in /mnt..."
                    DIR_CREATED=true
                fi
                sudo mkdir -p "/mnt/$dir"
            fi
        done

        # Check if autofs is installed
        if dpkg -l | grep -q autofs; then
            echo "autofs is already installed."
        else
            echo "Installing autofs..."
            sudo apt-get install -y autofs
            progress_bar 20
        fi

        # Setup autofs
        AUTO_MASTER_FILE="/etc/auto.master"
        AUTO_NFS_CONFIG="/mnt /etc/auto.nfs --ghost --timeout=60"

        echo "Configuring autofs..."
        if grep -Fxq "$AUTO_NFS_CONFIG" "$AUTO_MASTER_FILE"; then
            echo "Configuration already exists in $AUTO_MASTER_FILE ignoring..."
        else
            echo "$AUTO_NFS_CONFIG" | sudo tee -a "$AUTO_MASTER_FILE"
        fi

        # Create auto.nfs file
        AUTO_NFS_FILE="/etc/auto.nfs"
        AUTO_MASTER_FILE="/etc/auto.master"

        # Check if /etc/auto.nfs is referenced in /etc/auto.master
        if grep -q "$AUTO_NFS_FILE" "$AUTO_MASTER_FILE"; then
            echo "$AUTO_NFS_FILE is already referenced in $AUTO_MASTER_FILE."
        else
            echo "$AUTO_NFS_FILE is not referenced in $AUTO_MASTER_FILE."
            # Optionally, you can add code here to prompt the user to add the reference
        fi

        # Check if the auto.nfs file exists and handle accordingly
        if [ ! -f "$AUTO_NFS_FILE" ]; then
            echo "Creating $AUTO_NFS_FILE..."
            sudo touch "$AUTO_NFS_FILE"
            sudo nano "$AUTO_NFS_FILE"
        else
            read -p "$AUTO_NFS_FILE already exists. Do you want to open it for editing? (y/N): " OPEN_FILE
            OPEN_FILE=${OPEN_FILE:-N}
            if [[ "$OPEN_FILE" =~ ^[Yy]$ ]]; then
                echo "Opening for editing..."
                sudo nano "$AUTO_NFS_FILE"
            else
                echo "Skipping file editing."
                read -p "Press Enter to continue..."
            fi
        fi

        # Read and process each line in /etc/auto.nfs
        echo "Reading configuration from $AUTO_NFS_FILE..."
        while IFS= read -r line || [ -n "$line" ]; do
            # Ignore empty lines
            if [ -n "$line" ]; then
                echo "Processing line: $line"
                # Add your processing logic here
            fi
        done < "$AUTO_NFS_FILE"

        progress_bar 20
        # Prompt to check if auto.master and auto.nfs are present
        read -p "Do you want to check if auto.master and auto.nfs are present in /etc/ directory? (Y/n): " CHECK_FILES
        CHECK_FILES=${CHECK_FILES:-Y}

        if [[ "$CHECK_FILES" =~ ^[Yy]$ ]]; then
            echo "Checking files..."
            # Ask if the user wants to open the folders referenced in /etc/auto.nfs
            read -p "Do you want to open the folders referenced in /etc/auto.nfs to check if they are being read? (y/N): " OPEN_FOLDERS
            OPEN_FOLDERS=${OPEN_FOLDERS:-N}

            if [[ "$OPEN_FOLDERS" =~ ^[Yy]$ ]]; then
                echo "Opening folders..."
                while IFS= read -r line || [ -n "$line" ]; do
                    # Ignore empty lines
                    if [ -n "$line" ]; then
                        # Extract the folder path from the line
                        FOLDER_PATH=$(echo "$line" | awk '{print $1}')
                        if [ -d "$FOLDER_PATH" ]; then
                            echo "Folder $FOLDER_PATH exists and is being read."
                        else
                            echo "Folder $FOLDER_PATH does not exist or is not being read."
                        fi
                    fi
                done < /etc/auto.nfs
            else
                echo "Skipping folder check."
            fi
        else
            echo "Skipping file check."
        fi

        # Prompt to check when everything is unmounted
        read -p "Do you want to watch for NFS mounts? (Y/n): " WATCH_NFS
        WATCH_NFS=${WATCH_NFS:-Y}

        if [[ "$WATCH_NFS" =~ ^[Yy]$ ]]; then
            echo "Watching for NFS mounts... Press Enter to stop."
            while true; do
                watch -n 1 "mount | grep nfs" &
                WATCH_PID=$!
                read -r -t 1 -n 1 key
                if [[ $key == "" ]]; then
                    kill $WATCH_PID
                    break
                fi
            done
        else
            echo "Skipping NFS mount watch."
        fi

        # Check if autofs is working
        echo "Checking autofs status..."
        progress_bar 20
        # Ensure figlet is installed
        if ! command -v figlet &> /dev/null; then
            echo "Installing figlet for ASCII art..."
            sudo apt-get install -y figlet
        fi
        # Display completion message in ASCII art
        display_completion_message
        sudo systemctl restart autofs
        sudo systemctl status autofs
        ;;
    "uninstall")
        uninstall_autofs
        ;;
    "tips")
        show_tips
        ;;
    "status")
        check_status
        ;;
    "-h"|"--help")
        usage
        ;;
    *)
        echo -e "${RED}Invalid option: $1${RESET}"
        usage
        ;;
esac
