#!/usr/bin/env bash

set -e  # Exit on any error

SESSION_NAME="install-dev"

# Function to handle user choice when session exists
handle_existing_session() {
    echo "Tmux session 🚩'$SESSION_NAME'🚩 already exists!"
    echo ""
    echo "What would you like to do?"
    echo "1) Kill existing session and create new one"
    echo "2) Attach to existing session"
    echo "3) Cancel operation"
    echo ""

    while true; do
        read -p "Enter choice (1/2/3): " choice
        case $choice in
            1)
                echo "Killing existing session..."
                if tmux kill-session -t $SESSION_NAME 2>/dev/null; then
                    echo "Session '$SESSION_NAME' killed successfully."
                    # Continue with script to create new session
                    return 0
                else
                    echo "Failed to kill session '$SESSION_NAME'."
                    exit 1
                fi
                ;;
            2)
                echo "Attaching to existing session..."
                tmux attach-session -t $SESSION_NAME
                exit 0
                ;;
            3)
                echo "Operation cancelled."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# If a session with this name already exists, ask user what to do
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    handle_existing_session
fi

# make a key value env file of servers and their IPs
set -o allexport
source $REPO_ROOT/.env
set +o allexport

nix flake check --all-systems

tmux new-session -d -s $SESSION_NAME -n "hel-d-w"
tmux send-keys -t $SESSION_NAME:0 "clan machines install hel-d-w --update-hardware-config nixos-facter --target-host root@[$HEL_D_W] --yes" C-m

tmux new-window -t $SESSION_NAME -n "fsn-d-m"
tmux send-keys -t $SESSION_NAME:1 "clan machines install fsn-d-m --update-hardware-config nixos-facter --target-host root@[$FSN_D_M] --yes" C-m

tmux new-window -t $SESSION_NAME -n "fsn-d-w"
tmux send-keys -t $SESSION_NAME:2 "clan machines install fsn-d-w --update-hardware-config nixos-facter --target-host root@[$FSN_D_W] --yes" C-m

tmux new-window -t $SESSION_NAME -n "nbg-d-m"
tmux send-keys -t $SESSION_NAME:3 "clan machines install nbg-d-m --update-hardware-config nixos-facter --target-host root@[$NBG_D_M] --yes" C-m

tmux new-window -t $SESSION_NAME -n "nbg-d-w"
tmux send-keys -t $SESSION_NAME:4 "clan machines install nbg-d-w --update-hardware-config nixos-facter --target-host root@[$NBG_D_W] --yes" C-m

echo "Tmux created session ✨'$SESSION_NAME'✨"
tmux attach-session -t $SESSION_NAME
