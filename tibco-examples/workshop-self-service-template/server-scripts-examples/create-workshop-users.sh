
# create-workshop-users.sh
# Example script for creating workshop users
# This script demonstrates how to use the environment variables passed from the template

set -e

# Environment variables passed from template:
# USER_COUNT - number of users to create
# USER_PREFIX - prefix for usernames (e.g., "workshop")
# DEFAULT_PASSWORD - default password for users
# USER_SHELL - default shell for users
# WORKSHOP_NAME - name of the workshop

# Default values if not provided
USER_COUNT=${USER_COUNT:-10}
USER_PREFIX=${USER_PREFIX:-workshop}
DEFAULT_PASSWORD=${DEFAULT_PASSWORD:-Workshop2024!}
USER_SHELL=${USER_SHELL:-/bin/bash}
WORKSHOP_NAME=${WORKSHOP_NAME:-"TIBCO Workshop"}

echo "Creating $USER_COUNT workshop users with prefix '$USER_PREFIX'"
echo "Workshop: $WORKSHOP_NAME"

# Create workshop group if it doesn't exist
if ! getent group workshop >/dev/null 2>&1; then
    echo "Creating workshop group..."
    sudo groupadd workshop
fi

# Function to create a single user
create_user() {
    local user_number=$1
    local username="${USER_PREFIX}$(printf "%02d" $user_number)"

    if id "$username" >/dev/null 2>&1; then
        echo "User $username already exists, skipping..."
        return 0
    fi

    echo "Creating user: $username"

    # Create user with home directory
    sudo useradd -m -g workshop -s "$USER_SHELL" "$username"

    # Set password
    echo "$username:$DEFAULT_PASSWORD" | sudo chpasswd

    # Create workshop directory in user's home
    sudo mkdir -p "/home/$username/workshop"
    sudo chown "$username:workshop" "/home/$username/workshop"

    echo "User $username created successfully"
}

# Create users
for ((i=1; i<=USER_COUNT; i++)); do
    create_user $i
done

echo "Workshop user creation completed!"
echo "Created $USER_COUNT users: ${USER_PREFIX}01 through ${USER_PREFIX}$(printf "%02d" $USER_COUNT)"
echo "Default password: $DEFAULT_PASSWORD"
echo ""
echo "IMPORTANT: Remind users to change their passwords on first login!"
