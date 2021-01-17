#!/usr/bin/env fish

set http_req $argv
set app_runtime_log_path /tmp/container-app.log

function show_error
    echo "illegal HTTP header"
    echo $http_req
end

function pre_check
    if test $argv -lt 2
        show_error
        exit 1
    end
end

function send_http_resp
    set -l http_basic_resp_header "HTTP/1.1 200 OK"
    set -l success_ack "OK"
    set -l http_resp_header "$http_basic_resp_header\nContent-Length: "(string length $success_ack)
    set -l http_resp "$http_resp_header\n\n$success_ack"

    echo -e $http_resp
end

function start_app
    # http reqeust example: /ls/A=2/B=3/...
    set -l params (echo $http_req | awk '/GET/ {print $2}' | string split /)
    set -l params_length (count $params)

    pre_check $params_length

    set -l app_name $params[2]

    for i in (seq $params_length)
        if test $i -lt 3
            continue
        end

        set -l part $params[$i]
        set -l env_pair (string split = $part)

        # set environment variables
        set -x $env_pair[1] $env_pair[2]
    end

    # Start the app in request
    command $app_name > $app_runtime_log_path 2>&1 &
end

# main action
start_app

# return http response
send_http_resp
