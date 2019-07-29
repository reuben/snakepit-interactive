# snakepit-interactive

Helper for interactive jobs with [snakepit](https://github.com/mozilla/snakepit-client).

Add your SSH public key to .compute and modify .real_compute to suit your needs.

`./run-interactive.sh <job name> <job allocation>` will start a job, wait for it
    to run and SSHD to be available, then forward a local port to SSHD on the job
    and connect to it, attaching into the existing tmux session that is running
    on the job. If you're on macOS running on iTerm2, it'll use iTerm2's tmux
    integration. You'll then be attached into the session running .real_compute
    and can go from there. Commands executed in the interactive shell and their
    outputs will be logged to |pit log| normally. If you create new tmux panes/
    windows, those won't be logged into |pit log|. This can be fixed, patches
    welcome :)

If available, uses [autossh](https://www.harding.motd.ca/autossh/) to automatically restart the SSH session if the connection drops.
