#!/bin/bash

# create-shared-folder.sh
# Example script for creating shared workshop folders and materials

set -e

# Environment variables from template
WORKSHOP_NAME=${WORKSHOP_NAME:-"TIBCO Workshop"}
USER_PREFIX=${USER_PREFIX:-workshop}
USER_COUNT=${USER_COUNT:-10}

echo "Creating shared workshop folder for: $WORKSHOP_NAME"

# Create main shared folder
SHARED_FOLDER="/shared/workshop"
mkdir -p "$SHARED_FOLDER"

# Set permissions for shared folder
chmod 755 "$SHARED_FOLDER"

# Create subdirectories
mkdir -p "$SHARED_FOLDER/materials"
mkdir -p "$SHARED_FOLDER/exercises"
mkdir -p "$SHARED_FOLDER/solutions"
mkdir -p "$SHARED_FOLDER/resources"
mkdir -p "$SHARED_FOLDER/submissions"

# Create materials structure
cat > "$SHARED_FOLDER/README.md" << EOF
# $WORKSHOP_NAME - Shared Resources

Welcome to the shared workshop folder!

## Folder Structure

- **materials/** - Workshop presentations, documents, and guides
- **exercises/** - Practice exercises and lab instructions
- **solutions/** - Solution files and code examples
- **resources/** - Additional resources, tools, and references
- **submissions/** - Submit your work here (organized by username)

## Guidelines

1. **Read-only access** to materials, exercises, solutions, and resources
2. **Write access** only to your personal submission folder
3. Please be respectful of shared resources
4. Ask instructors if you need help accessing any materials

## Workshop Information

- **Name**: $WORKSHOP_NAME
- **Participants**: $USER_COUNT users
- **User prefix**: $USER_PREFIX

Happy learning! 🎉
EOF

# Create individual submission folders for each user
mkdir -p "$SHARED_FOLDER/submissions"
for ((i=1; i<=USER_COUNT; i++)); do
    username="${USER_PREFIX}$(printf "%02d" $i)"
    user_folder="$SHARED_FOLDER/submissions/$username"
    
    if id "$username" >/dev/null 2>&1; then
        echo "Creating submission folder for: $username"
        mkdir -p "$user_folder"
        chown "$username:workshop" "$user_folder"
        chmod 755 "$user_folder"
        
        # Create a personal README for the user
        cat > "$user_folder/README.md" << EOF
# $username - Personal Submission Folder

This is your personal folder for workshop submissions and work.

## Instructions

1. Save your exercise solutions here
2. Organize your work in subfolders if needed
3. Include documentation for your solutions
4. Follow the naming conventions provided in exercises

## Workshop Details

- **Workshop**: $WORKSHOP_NAME
- **Your Username**: $username
- **Submission Folder**: $user_folder

Good luck with the workshop!
EOF
        
        chown "$username:workshop" "$user_folder/README.md"
    else
        echo "User $username does not exist, skipping submission folder..."
    fi
done

# Create sample workshop materials
cat > "$SHARED_FOLDER/materials/getting-started.md" << EOF
# Getting Started with $WORKSHOP_NAME

## Workshop Overview

Welcome to $WORKSHOP_NAME! This workshop is designed to help you learn and practice with TIBCO technologies.

## Prerequisites

- Basic knowledge of programming concepts
- Familiarity with command line interfaces
- Your workshop credentials

## Workshop Environment

- **Server Access**: Use SSH with your workshop credentials
- **Shared Folder**: /shared/workshop
- **Your Submission Folder**: /shared/workshop/submissions/[your-username]
- **Tools Available**: Check available tools with \`workshop-info\` command

## Getting Help

1. Check the resources folder for additional documentation
2. Ask your instructor for assistance
3. Collaborate with fellow participants (encouraged!)

## Next Steps

1. Log into your workshop account
2. Explore the shared folder structure
3. Review the exercise materials
4. Start with Exercise 1 in the exercises folder

Let's begin! 🚀
EOF

# Create sample exercise
cat > "$SHARED_FOLDER/exercises/exercise-01-hello-world.md" << EOF
# Exercise 1: Hello World

## Objective

Create a simple "Hello World" application to verify your workshop environment.

## Instructions

1. Navigate to your submission folder:
   \`\`\`bash
   cd /shared/workshop/submissions/[your-username]
   \`\`\`

2. Create a new folder for this exercise:
   \`\`\`bash
   mkdir exercise-01
   cd exercise-01
   \`\`\`

3. Create a simple script in your preferred language:

   **Python example:**
   \`\`\`python
   # hello.py
   print("Hello from $WORKSHOP_NAME!")
   print("Username: [your-username]")
   \`\`\`

   **Node.js example:**
   \`\`\`javascript
   // hello.js
   console.log("Hello from $WORKSHOP_NAME!");
   console.log("Username: [your-username]");
   \`\`\`

4. Run your script and verify it works

5. Create a README.md file documenting what you did

## Submission

Save your work in your personal submission folder. Include:
- Your script file
- README.md with documentation
- Any additional notes or observations

## Next Steps

When complete, move on to Exercise 2 in the exercises folder.
EOF

# Set permissions for shared content
chown -R root:workshop "$SHARED_FOLDER"
chmod -R 755 "$SHARED_FOLDER/materials"
chmod -R 755 "$SHARED_FOLDER/exercises"
chmod -R 755 "$SHARED_FOLDER/solutions"
chmod -R 755 "$SHARED_FOLDER/resources"
chmod -R 755 "$SHARED_FOLDER/README.md"

# Create symbolic links in user home directories
for ((i=1; i<=USER_COUNT; i++)); do
    username="${USER_PREFIX}$(printf "%02d" $i)"
    
    if id "$username" >/dev/null 2>&1; then
        user_home="/home/$username"
        
        # Create symlink to shared folder
        if [ ! -L "$user_home/shared" ]; then
            ln -s "$SHARED_FOLDER" "$user_home/shared"
            chown -h "$username:workshop" "$user_home/shared"
        fi
        
        # Create symlink to personal submission folder
        if [ ! -L "$user_home/submissions" ]; then
            ln -s "$SHARED_FOLDER/submissions/$username" "$user_home/my-submissions"
            chown -h "$username:workshop" "$user_home/my-submissions"
        fi
        
        echo "Created symlinks for user: $username"
    fi
done

echo "Shared workshop folder setup completed!"
echo ""
echo "Shared folder location: $SHARED_FOLDER"
echo "Structure created:"
echo "├── materials/     (workshop presentations and guides)"
echo "├── exercises/     (practice exercises)"
echo "├── solutions/     (solution examples)"
echo "├── resources/     (additional resources)"
echo "└── submissions/   (user submission folders)"
echo ""
echo "Users can access via:"
echo "- Direct path: $SHARED_FOLDER"
echo "- Symlink from home: ~/shared"
echo "- Personal submissions: ~/my-submissions"