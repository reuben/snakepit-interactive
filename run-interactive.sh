#!/bin/bash
set -e

if [[ $# -ne 2 ]]; then
    echo "$0 <job name> <job allocation>" > /dev/stderr
    echo -e "\tStarts a pit job with given name and resource allocation, waits for"\
             "SSHD to be available in the job, then forwards a local port to SSHD"\
             "on the job and starts an SSH shell." | fmt > /dev/stderr
    exit 1
fi

TMUX="tmux"

# Use tmux mode on iTerm
if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
    TMUX="tmux -CC"
fi

SSH="ssh"

# Use autossh if available
if command -v autossh; then
    SSH="autossh"
fi

jobname="$1"
joballoc="$2"

jobnumber=$(pit run "$jobname" "$joballoc" | grep "job number:" | cut -d' ' -f4 | tr -d '[:space:]')
echo "Job $jobnumber submit. Waiting for it to run..." > /dev/stderr

job_status() {
    pit show job:$1 | grep 'State:' | tr -s ' ' | cut -d' ' -f2 | tr -d '[:space:]'
}

sshd_status() {
    pit exec $1 -- systemctl is-active ssh | tr -d '[:space:]'
}

# Wait for running
while [[ $(job_status $jobnumber) != "RUN" ]]; do
    sleep 1
done
echo "Job $jobnumber is running. Waiting for SSHD..." > /dev/stderr

# Wait for SSHD
while [[ $(sshd_status $jobnumber) != "active" ]]; do
    sleep 2
done
echo "SSHD is active. Forwarding port and starting SSH session..." > /dev/stderr

# Forward 31337 local port to SSHD in the job
tmux new-session -d 'pit forward '"$jobnumber"' 31337:22'

# Wait for forwarding
while [[ ! $(lsof -i tcp:31337) ]]; do
    echo "a"
    sleep 2
done

# Use autossh to detect stale connections as the VPN can be spotty
# This will drop you in a shell in the job
tmux new-window -d ''$SSH' -M 20000 -o "UserKnownHostsFile /dev/null" -R 52698:localhost:52698 -p 31337 root@127.0.0.1'

# Attach to tmux
$TMUX attach
