#!/bin/bash
set -e

if [[ $# -ne 1 ]]; then
    echo "$0 <job number>" > /dev/stderr
    echo -e "\tForwards a local port to SSHD on the job and starts an SSH shell." > /dev/stderr
    exit 1
fi

source shared.sh

jobnumber="$1"

if [[ $(job_status $jobnumber) != "RUN" ]]; then
    echo "Job $jobnumber is not running." > /dev/stderr
    exit 1
fi

forward_and_connect $jobnumber
