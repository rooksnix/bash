#create a bash script which will scan a folder given as a relative or full path on the command line. The script should #output a list of all folders in the given path which are empty. The script should prompt the user as to whether to delete #or ignore the folders. On answering the prompt all empty folder should be deleted in the event of a request for deletion.

#Save this script to a file (e.g., empty_directory_cleaner.sh), make it executable (chmod +x empty_directory_cleaner.sh), #and then you can run it by providing the target directory as an argument:

#./empty_directory_cleaner.sh /path/to/your/directory
#The script will list all empty directories within the provided path and prompt you for deletion confirmation. If you #choose to delete a directory, it will be removed from the filesystem. If you choose to ignore, it will move on to the #next empty directory. The script will then display a message when the operation is completed.

#!/bin/bash

# Function to check if a directory is empty
is_empty_directory() {
  local dir="$1"
  [ -n "$(ls -A "$dir")" ]
}

# Function to prompt user for deletion confirmation
ask_for_deletion() {
  local dir="$1"
  read -p "Do you want to delete the empty directory '$dir'? (y/n): " choice
  case "$choice" in
    [Yy])
      echo "Deleting $dir ..."
      rm -r "$dir"
      ;;
    *)
      echo "Ignoring $dir."
      ;;
  esac
}

# Main script starts here
if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

target_dir="$1"

# Check if the provided path exists
if [ ! -d "$target_dir" ]; then
  echo "Error: '$target_dir' is not a valid directory."
  exit 1
fi

# List all empty directories
empty_dirs=$(find "$target_dir" -type d -empty)

if [ -z "$empty_dirs" ]; then
  echo "No empty directories found in '$target_dir'."
  exit 0
fi

echo "Empty directories found in '$target_dir':"
echo "$empty_dirs"

# Prompt for deletion confirmation
for dir in $empty_dirs; do
  ask_for_deletion "$dir"
done

echo "Operation completed."
