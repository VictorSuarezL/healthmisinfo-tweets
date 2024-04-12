# Create a script to copy files and directories from one location to another. All the files I only want to copy are .R, .rmd, .html, .py, .sh 
# Usage: copy.zsh <source> <destination>
# Example: copy.zsh /home/user1 /home/user2

#!/bin/zsh
source=$1
destination=$2

# Check if source and destination are provided
if [ -z "$source" ] || [ -z "$destination" ]; then
    echo "Usage: copy.zsh <source> <destination>"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$source" ]; then
    echo "Source directory does not exist"
    exit 1
fi

# Check if destination directory exists, if not create it
if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
fi

# Copy files with specific extensions
find "$source" -type f \( -name "*.R" -o -name "*.rmd" -o -name "*.html" -o -name "*.py" -o -name "*.sh" \) -exec cp {} "$destination" \;

echo "Files copied successfully"
