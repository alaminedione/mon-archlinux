#!/bin/bash

# Log file setup
LOGFILE="blackarch_install.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Function to print messages in color
print_color() {
  local color="$1"
  shift
  echo -e "${color}$*${NC}"
}

# Function to check if a command exists
check_command() {
  command -v "$1" >/dev/null 2>&1 || {
    print_color "$RED" "Error: $1 is not installed. Please install it first."
    exit 1
  }
}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
EMOJI_CHECK="✅"
EMOJI_CROSS="❌"

# Function to check if a command exists and install it if not found
check_and_install_command() {
  local cmd="$1"
  print_color "$BLUE" "Checking for $cmd..."

  if ! command -v "$cmd" >/dev/null 2>&1; then
    print_color "$YELLOW" "$cmd is not installed. Installing..."
    sudo pacman -S "$cmd" --noconfirm
    if [[ $? -eq 0 ]]; then
      print_color "$GREEN" "${EMOJI_CHECK} $cmd installed successfully!"
    else
      print_color "$RED" "${EMOJI_CROSS} Failed to install $cmd!"
      exit 1
    fi
  else
    print_color "$GREEN" "${EMOJI_CHECK} $cmd is already installed."
  fi
}

# Check for required commands
check_and_install_command "curl"
check_and_install_command "git" # Uncomment if you need git

# Function to check if the user has sudo privileges
check_sudo() {
  if ! sudo -v >/dev/null 2>&1; then
    print_color "$RED" "You need sudo privileges to run this script."
    exit 1
  fi
}

# Check if the user has sudo privileges
check_sudo

# Update Arch Linux
print_color "$BLUE" "Updating Arch Linux..."
sudo pacman -Syyu --noconfirm

# Download BlackArch installation script if not already present
print_color "$BLUE" "Checking if BlackArch installation script is already downloaded..."
if [[ ! -f "strap.sh" ]]; then
  print_color "$BLUE" "Downloading BlackArch installation script..."
  if curl -O https://blackarch.org/strap.sh; then
    print_color "$GREEN" "${EMOJI_CHECK} Download successful!"
  else
    print_color "$RED" "${EMOJI_CROSS} Download failed!"
    exit 1
  fi
else
  print_color "$GREEN" "${EMOJI_CHECK} Script already downloaded."
fi

# Verify the script's integrity (optional but recommended)
print_color "$YELLOW" "Verifying the integrity of the script..."
sha256sum strap.sh
print_color "$YELLOW" "Please compare the result with the expected value on the BlackArch website."

# Ask user for confirmation to continue
read -p "Do you want to continue with the installation? (y/n): " choice
if [[ "$choice" != "y" ]]; then
  print_color "$RED" "${EMOJI_CROSS} Installation aborted by user."
  exit 1
fi

# Make the script executable
print_color "$BLUE" "Making the installation script executable..."
sudo chmod +x strap.sh

# Execute the installation script with progress indication
print_color "$BLUE" "Executing the BlackArch installation script..."
if sudo ./strap.sh; then
  print_color "$GREEN" "${EMOJI_CHECK} Installation script executed successfully!"
else
  print_color "$RED" "${EMOJI_CROSS} Failed to execute installation script!"
  exit 1
fi

# Ask user if they want to install all BlackArch tools
read -p "Do you want to install all BlackArch tools? (y/n): " install_choice
if [[ "$install_choice" == "y" ]]; then
  print_color "$GREEN" "Installing all BlackArch tools..."
  if sudo pacman -S blackarch --noconfirm; then
    print_color "$GREEN" "${EMOJI_CHECK} Installation of BlackArch tools completed!"
  else
    print_color "$RED" "${EMOJI_CROSS} Failed to install BlackArch tools!"
    exit 1
  fi
else
  print_color "$RED" "${EMOJI_CROSS} Installation of tools aborted by user."
fi

# Summary of actions taken
print_color "$CYAN" "=============================="
print_color "$CYAN" "Installation Summary:"
print_color "$CYAN" "- Arch Linux updated."
print_color "$CYAN" "- BlackArch installation script downloaded and executed."
if [[ "$install_choice" == "y" ]]; then
  print_color "$CYAN" "- All BlackArch tools installed."
else
  print_color "$CYAN" "- Installation of tools was skipped."
fi
print_color "$CYAN" "Check $LOGFILE for detailed logs."
print_color "$GREEN" "Installation process finished!"
