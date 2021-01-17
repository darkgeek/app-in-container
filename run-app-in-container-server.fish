#!/usr/bin/env fish

function find_handler_path
    set -l current_path (status --current-filename)
    set -l parts (string split / $current_path)
    set -l parts[-1] $HANDLER_NAME
    echo (string join / $parts)
end

function pre_check
    set -l arg_lenth (count $argv)
    if test $arg_lenth -eq 0
        echo "Usage: run-app-in-container-server.fish 127.0.0.1 9999"
        exit 1
    end
end

pre_check $argv

set FIFO_PATH /tmp/run-container-app.fifo
set HANDLER_NAME handler.fish
set HANDLER_PATH (find_handler_path)

if test ! -e $FIFO_PATH
    mkfifo $FIFO_PATH
end

# Start server in the infinite loop
while true
    cat $FIFO_PATH | xargs -n 1 -d '\n' $HANDLER_PATH 2>&1 | nc -lv $argv > $FIFO_PATH
end
