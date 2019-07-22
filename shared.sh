#!/bin/bash

TMUX="tmux"

# Use tmux mode on iTerm
if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
    TMUX="tmux -CC"
fi

SSH="ssh"

# Use autossh if available
if command -v autossh &>/dev/null; then
    SSH="autossh"
fi

# $1 = job number
job_status() {
    pit show job:$1 | grep 'State:' | tr -s ' ' | cut -d' ' -f2 | tr -d '[:space:]'
}

# $1 = job number
sshd_status() {
    pit exec $1 -- systemctl is-active ssh | tr -d '[:space:]'
}

# $1 = job number
forward_and_connect() {
    # Forward 31337 local port to SSHD in the job
    if [[ ! $(lsof -i tcp:31337) ]]; then
        tmux new-session -d 'pit forward '"$1"' 31337:22'

        # Wait for forwarding
        while [[ ! $(lsof -i tcp:31337) ]]; do
            sleep 2
        done
    fi

    # This will drop you in a shell in the job
    # Disable host key checking as the key will be different for every job
    $SSH -M 20000 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -R 52698:localhost:52698 -p 31337 root@127.0.0.1
}
