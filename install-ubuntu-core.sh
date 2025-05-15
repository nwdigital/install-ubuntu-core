#!/bin/bash
echo "Ubuntu Core Install Tool by Mathew Moore. Copyright 2025 NWDigital. https://nwdigital.cloud"

echo "This tool will attempt to download and install a custom Ubuntu Core 22 or 24 image on the root drive of this device."
read -p "Continue? (yes or no) " continue
continue=${continue:-N}
echo "Your answer was $continue"

# Setup some variables
core22_download_url="https://iob.fcp.cloud/ucore/22.img.xz"
core24_download_url="https://iob.fcp.cloud/ucore/24.img.xz"
test_good_download_url="https://github.com/nwdigital/nwd-agent/archive/refs/heads/main.zip"
test_bad_download_url="https://github.com/nwdigital/nwd-agent/archive/refs/heads/main.bad"
disk_name=""
core_version=""

get_main_disk() {
    disk_name=$(lsblk | grep 'disk $' | awk 'NR==1 {print $1}')
}

process_download() {
    destination_path="/dev/$disk_name"
    echo "Installation started for Ubuntu Core $core_version to $destination_path"
    echo "Command to run: xzcat -d $1 | sudo dd of=$destination_path bs=32M status=progress; sync"
    read -p "Continue with current command? (yes or no)" continue_install

    case $continue_install in
        yes|y)
            echo "Installing..."
            if xzcat -d $1 | sudo dd of=$destination_path bs=32M status=progress; sync; then
                echo "Installation successful."
                sudo reboot
            else
                echo "Installation failed."
            fi
            ;;
        no|n)
            echo "Exiting installer."
            ;;
        *)
            echo "Invalid option. Please enter 'yes' or 'no'."
            ;;
    esac
}

download_core() {
    case $1 in
        22)
            if wget -O ubuntu_core_22.img.xz $core22_download_url; then
                echo "Download successful."
                process_download ubuntu_core_22.img.xz
            else
                echo "Download failed."
            fi
            ;;
        24)
            if wget -O ubuntu_core_24.img.xz $core24_download_url; then
                echo "Download successful."
                process_download ubuntu_core_24.img.xz
            else
                echo "Download failed."
            fi
            ;;
        test_good)
        # Use for testing
            if wget -O ubuntu_core_good_test.img.xz $test_good_download_url; then
                echo "Download successful."
                process_download ubuntu_core_good_test.img.xz
            else
                echo "Download failed."
            fi
            ;;
        test_bad)
        # Use for testing
            if wget -O ubuntu_core_bad_test.img.xz $test_bad_download_url; then
                echo "Download successful."
                process_download ubuntu_core_bad_test.img.x
            else
                echo "Download failed."
            fi
            ;;
        *)
            ;;
    esac
}

ask_which_version() {
    read -p "Which version of Ubuntu Core would you like to install? ( 22, 24, 'q' to quit ) " core_version

    case $core_version in
        22)
            #echo "Attempting to download Ubuntu Core 22 -> $core22_download_url"
            echo "Attempting to download Ubuntu Core 22."
            download_core 22
            ;;
        24)
            #echo "Attempting to download Ubuntu Core 24 -> $core24_download_url"
            echo "Attempting to download Ubuntu Core 24."
            download_core 24
            ;;
        test_good)
        # Use for testing
            echo "Attempting download good test."
            download_core "test_good"
            ;;
        test_bad)
        # Use for testing
            echo "Attempting download bad test."
            download_core "test_bad"
            ;;
        q)
            ;;
        *)
            echo "Invalid option. Please enter '22' or '24'."
            ;;
    esac
}

run_main() {
    case $continue in
        yes|y)
            # echo "You said '$continue', you'd like to continue."
            get_main_disk
            ask_which_version
            ;;
        no|n)
            # echo "You said '$continue', you'd like to stop."
            ;;
        *)
            # echo "Invalid option. Please enter 'yes' or 'no'."
            ;;
    esac
}



run_main
