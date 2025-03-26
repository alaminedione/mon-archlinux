#!/bin/bash

# Colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

echo -e "${BLUE}### Swap Creation Script for Arch Linux ###${NC}"

# Ask the user for the swap size
echo -ne "${YELLOW}Enter the swap size in GB: ${NC}"
read SWAP_SIZE

# Check if the size is an integer
if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: The size must be an integer.${NC}"
    exit 1
fi

# Ask if the swap should be permanent
echo -ne "${YELLOW}Do you want the swap to be permanent? (y/n): ${NC}"
read PERMANENT

# Swap file path
SWAP_FILE="/swapfile"

# Create the swap file
echo -e "${BLUE}Creating a ${SWAP_SIZE} GB swap file...${NC}"
sudo fallocate -l ${SWAP_SIZE}G $SWAP_FILE
sudo chmod 600 $SWAP_FILE

# Set up the swap file
echo -e "${BLUE}Configuring the swap...${NC}"
sudo mkswap $SWAP_FILE
sudo swapon $SWAP_FILE

# Display the current swap status
echo -e "${GREEN}The ${SWAP_SIZE} GB swap is now active.${NC}"
swapon --show

# Set up permanent swap if desired
if [[ "$PERMANENT" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Adding swap to /etc/fstab to make it permanent...${NC}"
    echo "$SWAP_FILE none swap defaults 0 0" | sudo tee -a /etc/fstab > /dev/null
    echo -e "${GREEN}The swap is now permanent.${NC}"
else
    echo -e "${YELLOW}The swap is temporary and will be disabled on the next reboot.${NC}"
fi

echo -e "${GREEN}Script completed.${NC}"

