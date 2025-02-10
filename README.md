# Project Setup Instructions

These instructions will guide you through setting up the project.

## Prerequisites

*   A web server (e.g., Apache, Nginx)
*   PHP
*   MySQL
*   phpMyAdmin (optional, but recommended for database management)

## Setup Steps

1.  **Make the setup script executable:**

    ```bash
    chmod +x /var/www/test.silkroademart.com/setup.sh
    ```

2.  **Modify configuration variables in `setup.sh`:**

    Edit the `setup.sh` file and update the following variables to match your environment:

    *   `PROJECT_DIR` (line 9): The project directory on your server.
    *   `baseDir` (line 861):  Base directory used in the javascript code.
    *   `BASE_URL` (line 867): The base URL of your project.

    ```bash
    # Example:
    PROJECT_DIR="/var/www/your_project_directory"
    ```

3.  **Run the setup script:**

    ```bash
    sudo /var/www/test.silkroademart.com/setup.sh
    ```

4.  **Add your CSV file:**

    After the script completes, place your product data CSV file (e.g., `products.csv`) into the `/data` directory.

## Database Setup

1.  **Access the MySQL database:**

    ```bash
    sudo mysql -u root -p
    ```

    Enter your MySQL root password when prompted.

2.  **Create the database and user (if they don't exist):**

    ```sql
    CREATE DATABASE IF NOT EXISTS all_products_db;
    CREATE USER IF NOT EXISTS 'all_products_user'@'%' IDENTIFIED WITH mysql_native_password BY 'your_database_password';
    GRANT ALL ON all_products_db.* TO 'all_products_user'@'%';
    FLUSH PRIVILEGES;
    ```

    **Important:** Replace `your_database_password` with a strong, secure password.

3.  **(Optional) Verify database and user creation:**

    ```sql
    SHOW DATABASES;
    SELECT User FROM mysql.user;
    EXIT;
    ```

## Import Product Data

You can import product data into the `all_products_db` database using phpMyAdmin or the MySQL command line.

### Using phpMyAdmin

1.  Log in to phpMyAdmin with the `all_products_user` and the password you set during database setup.

2.  **For the initial CSV upload (creating the table):**

    *   Select the `all_products_db` database.
    *   Click "Import".
    *   Choose your `products.csv` file.
    *   Select "CSV" as the format.
    *   Ensure the "The first line of the file contains the table column names" checkbox is selected.
    *   Click "Import".

3.  **For subsequent CSV uploads (adding data to an existing table):**

    *   Select the `all_products_db` database.
    *   Select the `products` table.
    *   Click "Import".
    *   Choose your `products.csv` file.
    *   Select "CSV" as the format.
    *   **Remove the header row from the CSV file before importing.**
    *   Click "Import".

## Configure Search Functionality

1.  **Place `search.php` in the correct directory:**

    Copy the `search.php` file to the `/var/www/test.silkroademart.com/public/products` directory.

2.  **Update database credentials in `search.php`:**

    Edit the `search.php` file and update the database connection details (lines 25-28) to match your database configuration:

    ```php
    'host'     => 'your_database_host',
    'username' => 'all_products_user',
    'password' => 'your_database_password',
    'database' => 'all_products_db'
    ```

    Replace `your_database_host` and `your_database_password` with the correct values.

## Removing the Project

1.  **To remove the project folder:**

    ```bash
    rm -r /var/www/your_project_directory
    ```

2.  **To empty the project folder:**

    ```bash
    sudo rm -rf /var/www/your_project_directory/*
    ```

    Replace `/var/www/your_project_directory` with the actual path to your project directory.