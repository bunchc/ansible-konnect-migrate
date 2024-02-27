#!/bin/bash

# Set script variables (adjust paths and file names as needed)
ADMIN_API_LIST_FILE="admin_api_endpoints.txt"
INVENTORY_FILE="inventory.yaml"
OUTPUT_FILE="inventory_updated.yaml"

# Check if required files exist
if [[ ! -f "$ADMIN_API_LIST_FILE" ]]; then
  echo "Error: File '$ADMIN_API_LIST_FILE' not found."
  exit 1
fi

if [[ ! -f "$INVENTORY_FILE" ]]; then
  echo "Error: File '$INVENTORY_FILE' not found."
  exit 1
fi

# Copy initial inventory to avoid modifying the original
cp "$INVENTORY_FILE" "$OUTPUT_FILE"

# Loop through each admin API endpoint
while IFS= read -r admin_api_endpoint; do
  # Extract host portion from the URL
  admin_api_host=$(echo "$admin_api_endpoint" | cut -d '/' -f3)

  # Add top-level entry for this admin API
  echo "  - $admin_api_host" >> "$OUTPUT_FILE"

  # Enumerate workspaces from the admin API (replace with your actual API call)
  workspaces=$(curl -s "$admin_api_endpoint/workspaces")

  # Add each workspace as a child entry
  for workspace in $(echo "$workspaces" | jq -r '.[].name'); do
    echo "    - $workspace" >> "$OUTPUT_FILE"
  done

  echo "" >> "$OUTPUT_FILE"  # Add newline for better readability

done < "$ADMIN_API_LIST_FILE"

# Move the updated inventory to the original file
mv "$OUTPUT_FILE" "$INVENTORY_FILE"

echo "Inventory updated successfully!"
