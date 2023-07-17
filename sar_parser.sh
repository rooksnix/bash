#!/bin/bash

#Script to parse sar data on debian boxes
#To use this script, follow these steps:
#Open a text editor and copy the script into a new file (e.g., sar_parser.sh).
#Save the file and exit the text editor.
#Make the script executable by running the following command in the terminal:
#chmod +x sar_parser.sh
#Run the script with the desired command line options. Examples:
#To generate output files for the latest SAR data in PDF and PNG formats:
#Run the script with the desired command line options. Examples:
#./sar_parser.sh
#To generate output files for a specific date (e.g., 05/07/2023) in PDF and PNG formats:
#./sar_parser.sh 05/07/2023
#To generate output files for a specific date and time (e.g., 05/07/2023 10:30:00:000000) in PDF and PNG formats:
#./sar_parser.sh 05/07/2023\ 10:30:00:000000
#The script will install the sysstat package if necessary, parse the SAR data based on the provided or default
#date and time, and generate output files in PDF and PNG formats with appropriate filenames.
#Please note that this script assumes you are using a Debian-based distribution, such as Ubuntu, where apt-get is used for package management. If you are using a different distribution, you may need to modify the package installation command accordingly.



# Function to check if sysstat package is installed and install it if not
check_sysstat_package() {
    if ! dpkg -s sysstat >/dev/null 2>&1; then
        echo "Sysstat package is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install sysstat -y
    else
        echo "Sysstat package is already installed."
    fi
}

# Function to parse SAR data and generate output files
parse_sar_data() {
    output_dir="output"
    date_suffix=$(date +'%Y%m%d%H%M%S%N')

    # Check command line options
    if [[ $# -eq 0 ]]; then
        sar_command="sar"
        output_filename="${output_dir}/sar_${date_suffix}"
    elif [[ $# -eq 1 && $1 =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
        sar_command="sar -f /var/log/sysstat/sa$(date -d $1 +'%d')"
        output_filename="${output_dir}/sar_${1}_${date_suffix}"
    elif [[ $# -eq 1 && $1 =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}\ [0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{6}$ ]]; then
        sar_command="sar -f /var/log/sysstat/sa$(date -d ${1%% *} +'%d') -s ${1#* }"
        output_filename="${output_dir}/sar_${1}_${date_suffix}"
    else
        echo "Invalid date or date and time format."
        exit 1
    fi

    # Create output directory if it doesn't exist
    mkdir -p $output_dir

    # Generate PDF output file
    sar -P ALL -f /var/log/sysstat/sa* | sadf -p $sar_command > "${output_filename}.pdf"

    # Generate PNG output file
    sar -P ALL -f /var/log/sysstat/sa* | sadf -g $sar_command > "${output_filename}.png"

    echo "Output files generated: ${output_filename}.pdf ${output_filename}.png"
}

# Check if sysstat package is installed
check_sysstat_package

# Parse SAR data and generate output files
parse_sar_data "$@"
