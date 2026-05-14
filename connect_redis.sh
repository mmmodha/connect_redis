#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/redis_hosts.conf"

RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
RESET="$(tput sgr0 2>/dev/null || printf '')"
BOLD="$(tput bold 2>/dev/null || printf '')"


print_logo() {

  figlet -f isometric1 "Redis" | sed "s/^/${RED}/; s/$/${RESET}/"

}

print_logo

error() {
  printf '%sError:%s %s\n' "$RED" "$RESET" "$1"
}

info() {
  printf '%s%s%s\n' "$BLUE" "$1" "$RESET"
}

success() {
  printf '%s%s%s\n' "$GREEN" "$1" "$RESET"
}

repeat_char() {
  local char="$1"
  local count="$2"
  printf '%*s' "$count" '' | tr ' ' "$char"
}

ping_redis() {
  local host="$1"
  local port="$2"
  local password="$3"
  if [ -n "$password" ]; then
    REDISCLI_AUTH="$password" redis-cli -h "$host" -p "$port" PING 2>/dev/null
  else
    redis-cli -h "$host" -p "$port" PING 2>/dev/null
  fi
}

open_redis() {

  local host="$1"
  local port="$2"
  local password="$3"
  local db="$4"
  if [ -n "$password" ]; then
    REDISCLI_AUTH="$password" exec redis-cli -h "$host" -p "$port" -n "$db"
  else
    exec redis-cli -h "$host" -p "$port" -n "$db"
  fi
}

if [ ! -f "$CONFIG_FILE" ]; then
  error "Config file not found: $CONFIG_FILE"
  exit 1
fi

INSTANCES=()

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ""|\#*) continue ;;
  esac
  INSTANCES+=("$line")
done < "$CONFIG_FILE"

if [ "${#INSTANCES[@]}" -eq 0 ]; then
  error "No valid entries found in $CONFIG_FILE"
  exit 1
fi

ROWS=()
INDEX_W=1
NAME_W=4
HOST_W=4
PORT_W=4
DB_W=2
PASS_W=8

for i in "${!INSTANCES[@]}"; do
  read -r name host port password db <<< "${INSTANCES[$i]}"
  db="${db:-0}"

if [[ -z "$password" ]]; then
  pass_text="NO PASSWORD - may required one"
  pass_color="$YELLOW"
else
  pass_text="SET"
  pass_color="$GREEN"
fi

[ "${#pass_text}" -gt "$PASS_W" ] && PASS_W="${#pass_text}"
pass_status="${pass_color}$(printf '%-*s' "$PASS_W" "$pass_text")${RESET}"

  ROWS+=("$i|$name|$host|$port|$db|$pass_status")

  [ "${#i}" -gt "$INDEX_W" ] && INDEX_W="${#i}"
  [ "${#name}" -gt "$NAME_W" ] && NAME_W="${#name}"
  [ "${#host}" -gt "$HOST_W" ] && HOST_W="${#host}"
  [ "${#port}" -gt "$PORT_W" ] && PORT_W="${#port}"
  [ "${#db}" -gt "$DB_W" ] && DB_W="${#db}"
  [ "${#pass_text}" -gt "$PASS_W" ] && PASS_W="${#pass_text}"
done

SEP="+-$(repeat_char '-' "$INDEX_W")-+-$(repeat_char '-' "$NAME_W")-+-$(repeat_char '-' "$HOST_W")-+-$(repeat_char '-' "$PORT_W")-+-$(repeat_char '-' "$DB_W")-+-$(repeat_char '-' "$PASS_W")-+"

info "Available Redis instances:"
printf '%s\n' "$SEP"
printf '| %-*s | %-*s | %-*s | %-*s | %-*s | %-*s |\n' \
  "$INDEX_W" "#" \
  "$NAME_W" "name" \
  "$HOST_W" "host" \
  "$PORT_W" "port" \
  "$DB_W" "db" \
  "$PASS_W" "password"
printf '%s\n' "$SEP"

for row in "${ROWS[@]}"; do
  IFS='|' read -r idx name host port db pass_status <<< "$row"
 printf '| %-*s | %-*s | %-*s | %-*s | %-*s | %s |\n' \
  "$INDEX_W" "$idx" \
  "$NAME_W" "$name" \
  "$HOST_W" "$host" \
  "$PORT_W" "$port" \
  "$DB_W" "$db" \
  "$pass_status"
done

printf '%s\n' "$SEP"

choice=""
while :; do
  printf 'Select instance number or type quit: '
  read -r choice

  if [ "$choice" = "quit" ]; then
    info "Exiting."
    exit 0
  fi

  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt "${#INSTANCES[@]}" ]; then
    break
  fi

  error "Invalid selection. Type a number from the table or quit."
done

read -r name host port password db <<< "${INSTANCES[$choice]}"
db="${db:-0}"

printf 'Selected: %s (%s:%s), DB %s\n' "$name" "$host" "$port" "$db"

PING_RESULT="$(ping_redis "$host" "$port" "$password")"

if [ "$PING_RESULT" = "PONG" ]; then
  success "Connection successful"
  open_redis "$host" "$port" "$password" "$db"
fi

if [ -z "$password" ]; then
  error "Connection failed. This instance may require authentication."
else
  error "Connection failed with the configured password. You can try entering a different one."
fi

while :; do
  printf 'Enter password (or type quit): '
  read -rs input_pass
  printf '\n'

  if [ "$input_pass" = "quit" ]; then
    info "Exiting."
    exit 0
  fi

  PING_RESULT="$(ping_redis "$host" "$port" "$input_pass")"

  if [ "$PING_RESULT" = "PONG" ]; then
    success "Authentication successful"
    open_redis "$host" "$port" "$input_pass" "$db"
  fi

  error "Invalid password. Try again or type quit."
done