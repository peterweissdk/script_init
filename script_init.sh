#!/bin/bash
# ----------------------------------------------------------------------------
# Script Name: script_init.sh
# Description: Helper, to set info
# Author: peterweissdk
# Email: peterweissdk@flems.dk
# Date: 2025-01-05
# Version: v0.1.2
# Usage: [-i | --install] [-u | --update-version] [-v | --version] [-h | --help]" 
# ----------------------------------------------------------------------------

# Installs script
install() {
    read -p "Do you want to install this script? (yes/no): " answer
    case $answer in
        [Yy]* )
            # Set default installation path
            default_path="/usr/local/bin"
            
            # Prompt for installation path
            read -p "Enter the installation path [$default_path]: " install_path
            install_path=${install_path:-$default_path}  # Use default if no input

            # Get the filename of the script
            script_name=$(basename "$0")

            # Copy the script to the specified path
            echo "Copying $script_name to $install_path..."
            
            # Check if the user has write permissions
            if [ ! -w "$install_path" ]; then
                echo "You need root privileges to install the script in $install_path."
                if sudo cp "$0" "$install_path/$script_name"; then
                    sudo chmod +x "$install_path/$script_name"
                    echo "Script installed successfully."
                else
                    echo "Failed to install script."
                    exit 1
                fi
            else
                if cp "$0" "$install_path/$script_name"; then
                    chmod +x "$install_path/$script_name"
                    echo "Script installed successfully."
                else
                    echo "Failed to install script."
                    exit 1
                fi
            fi
            ;;
        [Nn]* )
            echo "Exiting script."
            exit 0
            ;;
        * )
            echo "Please answer yes or no."
            install
            ;;
    esac

    exit 0
}

# Updates version of script
update_version() {
    # Extract the current version from the script header
    version_line=$(grep '^# Version:' "$0")
    current_version=${version_line#*: }  # Remove everything up to and including ": "
    
    echo "Current version: $current_version"
    
    # Prompt the user for a new version
    read -p "Enter new version (current: $current_version): " new_version
    
    # Update the version in the script
    sed -i "s/^# Version: .*/# Version: $new_version/" "$0"
    
    echo "Version updated to: $new_version"

    exit 0
}

# Prints out version
version() {
    # Extract the current version from the script header
    version_line=$(grep '^# Version:' "$0")
    current_version=${version_line#*: }  # Remove everything up to and including ": "
    
    echo "Script version: $current_version"

    exit 0
}

# Prints out help
help() {
    echo "Run script to setup a new shell script file."
    echo "Usage: $0 [-c | --create] [-i | --install] [-u | --update-version] [-v | --version] [-h | --help]"

    exit 0
}

# Function to prompt for a valid directory
prompt_for_directory() {
    while true; do
        read -p "Enter the directory to store the script (default is current directory): " directory
        # Use current directory if no input is given
        directory=${directory:-.}

        # Check if the directory exists
        if [ ! -d "$directory" ]; then
            echo "Directory '$directory' does not exist."
            read -p "Would you like to create it? (y/n): " create_choice
            case "$create_choice" in
                [yY])
                    if mkdir -p "$directory"; then
                        echo "Directory '$directory' created successfully."
                    else
                        echo "Failed to create directory. Please check permissions."
                        continue
                    fi
                    ;;
                [nN])
                    echo "Exiting..."
                    exit 1
                    ;;
                *)
                    echo "Invalid choice. Please try again."
                    continue
                    ;;
            esac
        fi

        # Check write permission
        if [ ! -w "$directory" ]; then
            echo "No write permission for directory '$directory'"
            read -p "Would you like to try a (n)ew directory or e(x)it? (n/x): " choice
            case "$choice" in
                [nN])
                    continue
                    ;;
                [xX])
                    echo "Exiting..."
                    exit 1
                    ;;
                *)
                    echo "Invalid choice. Please try again."
                    continue
                    ;;
            esac
        else
            break
        fi
    done

    echo "Using directory: $directory"
    script_dir="$directory"

}

# Function to create the script
create() {
    # Get script information from user
    read -p "Enter the script name (without .sh extension): " script_name
    read -p "Enter a description: " description
    read -p "Enter your name: " author
    read -p "Enter your email: " email

    # Get the current date in YYYY-MM-DD format
    current_date=$(date +%Y-%m-%d)
    read -p "Enter the date (YYYY-MM-DD, default is ${current_date}): " date
    date=${date:-$current_date}  # Use current date if no input is given

    read -p "Enter the version: " version
    read -p "Enter usage instructions: " usage

    # Prompt for directory
    prompt_for_directory

    # Create the script file path
    script_file="${script_dir}/${script_name}.sh"

    # Write the script content
    {
        echo '#!/bin/bash'
        echo '# ----------------------------------------------------------------------------'
        echo "# Script Name: ${script_name}.sh"
        echo "# Description: ${description}"
        echo "# Author: ${author}"
        echo "# Email: ${email}"
        echo "# Date: ${date}"
        echo "# Version: ${version}"
        echo "# Usage: ${usage}"
        echo '# ----------------------------------------------------------------------------'
        echo ''
        echo '# Installs script'
        echo 'install() {'
        echo '    read -p "Do you want to install this script? (yes/no): " answer'
        echo '    case $answer in'
        echo '        [Yy]* )'
        echo '            # Set default installation path'
        echo '            default_path="/usr/local/bin"'
        echo '            '
        echo '            # Prompt for installation path'
        echo '            read -p "Enter the installation path [$default_path]: " install_path'
        echo '            install_path=${install_path:-$default_path}  # Use default if no input'
        echo ''
        echo '            # Get the filename of the script'
        echo '            script_name=$(basename "$0")'
        echo ''
        echo '            # Copy the script to the specified path'
        echo '            echo "Copying $script_name to $install_path..."'
        echo '            '
        echo '            # Check if the user has write permissions'
        echo '            if [ ! -w "$install_path" ]; then'
        echo '                echo "You need root privileges to install the script in $install_path."'
        echo '                if sudo cp "$0" "$install_path/$script_name"; then'
        echo '                    sudo chmod +x "$install_path/$script_name"'
        echo '                    echo "Script installed successfully."'
        echo '                else'
        echo '                    echo "Failed to install script."'
        echo '                    exit 1'
        echo '                fi'
        echo '            else'
        echo '                if cp "$0" "$install_path/$script_name"; then'
        echo '                    chmod +x "$install_path/$script_name"'
        echo '                    echo "Script installed successfully."'
        echo '                else'
        echo '                    echo "Failed to install script."'
        echo '                    exit 1'
        echo '                fi'
        echo '            fi'
        echo '            ;;'
        echo '        [Nn]* )'
        echo '            echo "Exiting script."'
        echo '            exit 0'
        echo '            ;;'
        echo '        * )'
        echo '            echo "Please answer yes or no."'
        echo '            install'
        echo '            ;;'
        echo '    esac'
        echo ''
        echo '    exit 0'
        echo '}'
        echo ''
        echo '# Updates version of script'
        echo 'update_version() {'
        echo '    # Extract the current version from the script header'
        echo '    version_line=$(grep "^# Version:" "$0")'
        echo '    current_version=${version_line#*: }  # Remove everything up to and including ": "'
        echo '    '
        echo '    echo "Current version: $current_version"'
        echo '    '
        echo '    # Prompt the user for a new version'
        echo '    read -p "Enter new version (current: $current_version): " new_version'
        echo '    '
        echo '    # Update the version in the script'
        echo '    sed -i "s/^# Version: .*/# Version: $new_version/" "$0"'
        echo '    '
        echo '    echo "Version updated to: $new_version"'
        echo ''
        echo '    exit 0'
        echo '}'
        echo ''
        echo '# Prints out version'
        echo 'version() {'
        echo '    # Extract the current version from the script header'
        echo '    version_line=$(grep "^# Version:" "$0")'
        echo '    current_version=${version_line#*: }  # Remove everything up to and including ": "'
        echo '    '
        echo '    echo "$0: $current_version"'
        echo ''
        echo '    exit 0'
        echo '}'
        echo ''
        echo '# Prints out help'
        echo 'help() {'
        echo '    echo "Run script to setup a new shell script file."'
        echo '    echo "Usage: $0 [-i | --install] [-u | --update-version] [-v | --version] [-h | --help]"'
        echo ''
        echo '    exit 0'
        echo '}'
        echo ''
        echo '# Check for flags'
        echo 'while [[ "$#" -gt 0 ]]; do'
        echo '    case $1 in'
        echo '        -i|--install) install; shift ;;'
        echo '        -u|--update-version) update_version; shift ;;'
        echo '        -v|--version) version; shift ;;'
        echo '        -h|--help) help; shift ;;'
        echo '        *) echo "Unknown option: $1"; help; exit 1 ;;'
        echo '    esac'
        echo 'done'
        echo ''
        echo '# Your code here'
    } > "$script_file"

    # Make the script executable
    chmod +x "${script_file}"

    echo "Script '${script_file}' created successfully!"

    exit 0
}

# Check for flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--create) create; shift ;;
        -i|--install) install; shift ;;
        -u|--update-version) update_version; shift ;;
        -v|--version) version; shift ;;
        -h|--help) help; shift ;;
        *) echo "Unknown option: $1"; help; exit 1 ;;
    esac
done

# If no arguments were provided, show help
if [ "$#" -eq 0 ]; then
    help
    exit 0
fi
