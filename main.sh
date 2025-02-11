#!/bin/bash

# Exit on any error
set -e

echo "Starting main process..."

# Function to update config.json
update_config() {
    echo "Updating config.json settings..."
    
    # Project settings
    read -p "Enter project directory [/path/to/your/directory]: " project_dir
    project_dir=${project_dir:-/path/to/your/directory}
    read -p "Enter base URL [https://yourdomain.com]: " base_url
    base_url=${base_url:-https://yourdomain.com}
    
    # Database settings
    read -p "Enter database host [yourdatabasehost]: " db_host
    db_host=${db_host:-yourdatabasehost}
    read -p "Enter database username [db_user]: " db_user
    db_user=${db_user:-db_user}
    read -p "Enter database password [db_pass]: " db_pass
    db_pass=${db_pass:-db_pass}
    read -p "Enter database name [db_name]: " db_name
    db_name=${db_name:-db_name}
    read -p "Enter database root password [db_root_pass]: " db_root_pass
    db_root_pass=${db_root_pass:-db_root_pass}
    
    # API settings
    read -p "Enter API URL [https://yourdomain.com/wp-json/wc/v3]: " api_url
    api_url=${api_url:-https://yourdomain.com/wp-json/wc/v3}
    read -p "Enter API consumer key [ck_xxxxx]: " api_key
    api_key=${api_key:-ck_xxxxx}
    read -p "Enter API consumer secret [cs_xxxxx]: " api_secret
    api_secret=${api_secret:-cs_xxxxx}
    
    # Create updated config.json
    cat > config.json << EOF
{
  "project": {
    "directory": "$project_dir",
    "baseUrl": "$base_url"
  },
  "database": {
    "host": "$db_host",
    "username": "$db_user",
    "password": "$db_pass",
    "name": "$db_name",
    "rootPassword": "$db_root_pass"
  },
  "api": {
    "url": "$api_url",
    "consumerKey": "$api_key",
    "consumerSecret": "$api_secret"
  },
  "cart": {
    "baseUrl": "https://yourdomain.com/cart/"
  },
  "navigation": {
    "shop": "https://yourdomain.com/shop/",
    "categories": "https://yourdomain.com/elements/product-categories/",
    "about": "https://yourdomain.com/about/",
    "contact": "https://yourdomain.com/contact-us/"
  },
  "branding": {
    "logoUrl": "https://yourdomain.com/",
    "logoImageUrl": "https://yourdomain.com/wp-content/uploads/logo.png",
    "logoTitle": "Your Domain",
    "faviconUrl": "https://yourdomain.com/wp-content/uploads/favicon.png"
  },
  "copyright": {
    "text": "CopyrightYourDomain"
  }
}
EOF
    echo "config.json has been updated."
}

# Function to update search.php
update_search_php() {
    local config_file="config.json"
    echo "Updating database configuration in search.php..."
    
    # Get database configuration from config.json
    local db_host=$(jq -r '.database.host' "$config_file")
    local db_user=$(jq -r '.database.username' "$config_file")
    local db_pass=$(jq -r '.database.password' "$config_file")
    local db_name=$(jq -r '.database.name' "$config_file")
    
    # Create a temporary file
    local temp_file=$(mktemp)
    
    # Read search.php and update only the database configuration
    awk -v host="$db_host" -v user="$db_user" -v pass="$db_pass" -v dbname="$db_name" '
    {
        if ($0 ~ /\$db_config = array\(/) {
            print "$db_config = array("
            print "    '\''host'\''     => '\''" host "'\'',"
            print "    '\''username'\'' => '\''" user "'\'',"
            print "    '\''password'\'' => '\''" pass "'\'',"
            print "    '\''database'\'' => '\''" dbname "'\''"
            print ");"
            # Skip the next 5 lines (original db config)
            for(i=0; i<5; i++) { getline }
        } else {
            print $0
        }
    }' search.php > "$temp_file"
    
    # Replace original file with updated content
    mv "$temp_file" search.php
    
    echo "Database configuration in search.php has been updated."
}

# Function to convert XML to CSV
convert_xml_to_csv() {
    local xml_file="$1/data/products_database.xml"
    local csv_file="$1/data/products_database.csv"
    
    if [ -f "$xml_file" ]; then
        echo "Converting XML to CSV..."
        # Create CSV header
        echo "Title,Price,Product Link,Category,Image URL" > "$csv_file"
        
        # Extract and format data using grep and sed, with proper CSV escaping
        grep -A5 "<product>" "$xml_file" | \
        sed -n '/<title>/,/<\/title>/{s/.*CDATA\[\(.*\)\]\].*/\1/p}; 
                /<price>/,/<\/price>/{s/.*CDATA\[\(.*\)\]\].*/\1/p}; 
                /<product_link>/,/<\/product_link>/{s/.*CDATA\[\(.*\)\]\].*/\1/p}; 
                /<category>/,/<\/category>/{s/.*CDATA\[\(.*\)\]\].*/\1/p}; 
                /<image_url>/,/<\/image_url>/{s/.*CDATA\[\(.*\)\]\].*/\1/p}' | \
        awk 'BEGIN { OFS="," }
             NR%5==1 { title=$0 }
             NR%5==2 { price=$0 }
             NR%5==3 { link=$0 }
             NR%5==4 { category=$0 }
             NR%5==0 { 
                image=$0
                gsub(/"/, "\"\"", title)  # Escape any double quotes
                printf "\"%s\",%s,\"%s\",\"%s\",\"%s\"\n", 
                       title, price, link, category, image
             }' >> "$csv_file"
        
        echo "CSV file generated successfully at: $csv_file"
        
        # Verify the CSV was created with data
        local line_count=$(wc -l < "$csv_file")
        echo "CSV file contains $line_count lines (including header)"
        
        # Show first few lines of the CSV
        echo "First few lines of the CSV file:"
        head -n 3 "$csv_file"
    else
        echo "Warning: XML file not found at $xml_file"
        return 1
    fi
}

# Check for config.json
if [ ! -f "config.json" ]; then
    echo "config.json not found. Creating new configuration..."
    update_config
else
    read -p "Do you want to update config.json? (y/n): " update_config_choice
    if [ "$update_config_choice" = "y" ] || [ "$update_config_choice" = "Y" ]; then
        update_config
    fi
fi

# Get project directory
PROJECT_DIR=$(jq -r '.project.directory' config.json)

# Update search.php
update_search_php

# Ask if setup.sh should be run
read -p "Do you want to run setup.sh? (y/n): " run_setup

if [ "$run_setup" = "y" ] || [ "$run_setup" = "Y" ]; then
    echo "Running setup script..."
    bash setup.sh
    echo "Setup completed."
fi

# After setup (or if skipped), check if XML exists and convert to CSV
if [ -f "$PROJECT_DIR/data/products_database.xml" ]; then
    echo "XML file found, converting to CSV..."
    convert_xml_to_csv "$PROJECT_DIR"
else
    echo "XML file not found at $PROJECT_DIR/data/products_database.xml"
    echo "Make sure the XML file exists before running the conversion."
    exit 1
fi

echo "All processes completed successfully!"
