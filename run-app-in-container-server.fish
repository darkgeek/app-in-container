#!/usr/bin/env fish

function find_handler_path
    set -l current_path (status --current-filename)
    set -l parts (string split / $current_path)
    set -l parts[-1] $HANDLER_NAME
    echo (string join / $parts)
end

set FIFO_PATH /tmp/run-container-app.fifo
set HANDLER_NAME handler.fish
set HANDLER_PATH (find_handler_path)

if test ! -e $FIFO_PATH
    mkfifo $FIFO_PATH
end

# Start server in the infinite loop
while true
    cat $FIFO_PATH | xargs -n 1 -d '\n' $HANDLER_PATH 2>&1 | nc -lv 9999 > $FIFO_PATH
end
