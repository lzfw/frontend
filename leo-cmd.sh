#!/usr/bin/env bash
set -euo pipefail

sed -E -i 's/access_log\s*(.+)\s*vhost\s*;/access_log \1 gelf_json if=$external;/gi' /app/nginx.tmpl

exec "$@"

