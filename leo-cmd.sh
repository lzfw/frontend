#!/usr/bin/env bash
set -euo pipefail

# Change the log format for nginx to JSON and send messages through syslog;
sed -E -i 's/(access_log\s*.+\s*vhost);/\1 ; \naccess_log syslog:server=graylog:5555 syslog_json if=$external;/gi' /app/nginx.tmpl

exec "$@"

