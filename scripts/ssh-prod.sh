#!/usr/bin/env bash
set -e  # Exit on any error

SESSION_NAME="ssh-prod"

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

tmux new-session -d -s $SESSION_NAME -n "hel-p-m"
tmux send-keys -t $SESSION_NAME:0 "ssh root@hel-p-m" C-m

tmux new-window -t $SESSION_NAME -n "hel-p-w"
tmux send-keys -t $SESSION_NAME:1 "ssh root@hel-p-w" C-m

tmux new-window -t $SESSION_NAME -n "fsn-p-m"
tmux send-keys -t $SESSION_NAME:2 "ssh root@fsn-p-m" C-m

tmux new-window -t $SESSION_NAME -n "fsn-p-w"
tmux send-keys -t $SESSION_NAME:3 "ssh root@fsn-p-w" C-m

tmux new-window -t $SESSION_NAME -n "nbg-p-m"
tmux send-keys -t $SESSION_NAME:4 "ssh root@nbg-p-m" C-m

tmux new-window -t $SESSION_NAME -n "nbg-p-w"
tmux send-keys -t $SESSION_NAME:5 "ssh root@nbg-p-w" C-m

echo "Tmux created session ✨'$SESSION_NAME'✨"
tmux attach-session -t $SESSION_NAME