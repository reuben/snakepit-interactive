#!/bin/bash
set -e

if [[ $# -ne 2 ]]; then
    echo "$0 <job name> <job allocation>" > /dev/stderr
    echo -e "\tStarts a pit job with given name and resource allocation, waits for"\
             "SSHD to be available in the job, then forwards a local port to SSHD"\
             "on the job and starts an SSH shell." | fmt > /dev/stderr
    exit 1
fi

source shared.sh

jobname="$1"
joballoc="$2"

jobnumber=$(pit run "$jobname" "$joballoc" | grep "job number:" | cut -d' ' -f4 | tr -d '[:space:]')
echo "Job $jobnumber submit. Waiting for it to run..." > /dev/stderr

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

forward_and_connect $jobnumber
