# Product Catalog Setup

This document outlines the steps to set up and run the product catalog system. This system automates the generation of static HTML product pages from a CSV file, downloads product images, generates a sitemap, and creates an XML file for product data.

## Prerequisites

*   A Linux-based server with shell access.
*   MySQL installed and configured.
*   PHP installed and configured with phpMyAdmin (optional).
*   Node.js and npm installed.

## Setup Instructions

1.  **Clone the Repository:**

    ```bash
    git clone <repository_url>
    cd <project_directory> # e.g., /var/www/yourproject
    ```

2.  **Configure Environment Variables:**

    *   Copy the `.env.example` file to `.env`:

        ```bash
        cp .env.example .env
        ```

    *   Edit the `.env` file and configure the following variables:

        ```
        PROJECT_DIR=<project_directory> # e.g., /var/www/yourproject
        BASE_DIR=<base_directory> # e.g., /var/www/yourproject
        BASE_URL=<base_url> # e.g., https://yourdomain.com

        DB_HOST=<your_db_host>
        DB_USERNAME=<your_db_username>
        DB_PASSWORD=<your_db_password>
        DB_NAME=<your_db_name>
        MYSQL_ROOT_PASSWORD=<your_mysql_root_password>

        API_URL=<your_api_url> # e.g., https://your-api.com/wp-json/wc/v3
        API_CONSUMER_KEY=<your_api_consumer_key>
        API_CONSUMER_SECRET=<your_api_consumer_secret>

        CART_URL_BASE=<your_cart_url_base> # e.g., https://your-site.com/cart/

        NAV_SHOP=<your_shop_url> # e.g., https://your-site.com/shop/
        NAV_CATEGORIES=<your_categories_url> # e.g., https://your-site.com/categories/
        NAV_ABOUT=<your_about_url> # e.g., https://your-site.com/about/
        NAV_CONTACT=<your_contact_url> # e.g., https://your-site.com/contact/

        LOGO_URL=<your_logo_url> # e.g., https://your-site.com/
        LOGO_IMAGE_URL=<your_logo_image_url> # e.g., https://your-site.com/images/logo.png
        LOGO_TITLE=<your_logo_title> # e.g., Your Company Name
        ```

    **Important:** Ensure the `.env` file is added to your `.gitignore` file to prevent sensitive information from being committed to your repository.

3.  **Make the Setup Script Executable:**

    ```bash
    chmod +x setup.sh
    ```

4.  **Run the Setup Script:**

    ```bash
    sudo ./setup.sh
    ```

    This script will:

    *   Create the necessary directory structure (`data`, `views`, `public/products`, `public/images`).
    *   Initialize a Node.js project and install dependencies.
    *   Create the `product.ejs` template.
    *   Create the `parse-csv.js` script.
    *   Set appropriate file permissions.

5.  **Prepare Product Data:**

    *   Place your product CSV file (e.g., `products.csv`) in the `data` directory:

        ```bash
        cp your_products.csv <project_directory>/data/products.csv # e.g., cp your_products.csv /var/www/yourproject/data/products.csv
        ```

    *   Ensure your CSV file has the following columns (case-sensitive):

        ```
        Title, Regular Price, Category, Image, Short_description, description
        ```

6.  **Database Setup (MySQL):**

    *   Access the MySQL server:

        ```bash
        sudo mysql -u root -p
        ```

        Enter the MySQL root password when prompted.

    *   Create the database and user (if they don't exist):

        ```sql
        CREATE DATABASE IF NOT EXISTS all_products_db;
        CREATE USER IF NOT EXISTS 'all_products_user'@'%' IDENTIFIED WITH mysql_native_password BY 'all_products_2@';
        GRANT ALL PRIVILEGES ON all_products_db.* TO 'all_products_user'@'%';
        FLUSH PRIVILEGES;
        EXIT;
        ```

7.  **Import Product Data to MySQL:**

    *   Download the XML file located in `<project_directory>/data/products_database.xml`.
    *   Open the XML file in Excel.
    *   Save the Excel file as `products.csv`.
    *   Log in to phpMyAdmin.
    *   Select the `all_products_db` database.

    *   **For the First Time (Creating the Table):**

        1.  Click "Import".
        2.  Choose the `products.csv` file.
        3.  Select "CSV" as the format.
        4.  Check "The first line of the file contains the table column names."
        5.  Click "Go".

    *   **For Subsequent Imports (Adding Data):**

        1.  Open the `products.csv` file and remove the header row.
        2.  Click the `products` table.
        3.  Click "Import".
        4.  Choose the `products.csv` file.
        5.  Select "CSV" as the format.
        6.  Click "Go".

8.  **Run the Data Processing Script:**

    ```bash
    cd <project_directory> # e.g., cd /var/www/yourproject
    node parse-csv.js
    ```

    This script will:

    *   Read the product data from `products.csv`.
    *   Download product images.
    *   Generate HTML files for each product in the `public/products` directory.
    *   Create a `sitemap.xml` file.
    *   Create `products_database.xml`.

9.  **Configure Search Functionality:**

    *   Place the `search.php` file in the `<project_directory>/public/products` directory.

    *   Modify the database connection details in `search.php` to match your environment variables:

        ```php
            'host'     => getenv('DB_HOST'),
            'username' => getenv('DB_USERNAME'),
            'password' => getenv('DB_PASSWORD'),
            'database' => getenv('DB_NAME')
        ```

        Also ensure to load environment variables in `search.php` using a package like `vlucas/phpdotenv`

10. **Web Server Configuration:**

    *   Configure your web server (e.g., Apache, Nginx) to serve the files in the `public` directory.
    *   Ensure that PHP is properly configured to process `search.php`.

## Additional Information

*   **Database Location:** Ensure the database server is accessible from the web server for images and other data to display correctly.
*   **File Management:**
    *   To remove a folder: `rm -r <directory_to_remove>`
    *   To empty a folder: `sudo rm -rf <directory_to_empty>/*`

## Contributing

Contributions are welcome! Please submit pull requests with detailed explanations of your changes.

## License

[Specify License, e.g., MIT License]