#!/usr/bin/env bash
set -euo pipefail

############################################
# Paths
############################################

DOWNLOADS="$HOME/Downloads"
PICTURES="$HOME/Pictures"
DOCUMENTS="$HOME/Documents"
VIDEOS="$HOME/Videos"
MUSIC="$HOME/Music"
GIT_ROOT="$HOME/Documents/git"

REPORT_DIR="$HOME/.local/share/housekeeping"
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
REPORT_FILE="$REPORT_DIR/report_$TIMESTAMP.txt"
LOG_TAG="HOUSEKEEPING"

mkdir -p "$REPORT_DIR"

############################################
# Colors (terminal only)
############################################

RED="\033[31m"
YELLOW="\033[33m"
CYAN="\033[36m"
BOLD="\033[1m"
RESET="\033[0m"

############################################
# Logging
############################################

strip_colors() {
    sed 's/\x1B\[[0-9;]*[A-Za-z]//g'
}

log_file() {
    echo -e "$(date '+%F %T') $1" >> "$REPORT_FILE"
}

log_syslog() {
    echo -e "$1" | strip_colors | logger -t "$LOG_TAG"
}

log_all() {
    log_file "$1"
    log_syslog "$1"
}

############################################
# Utilities
############################################

lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }

print_header() {
    printf "\n${BOLD}${CYAN}%-20s | %-15s | %-60s${RESET}\n" "CATEGORY" "STATUS" "DETAIL"
    printf "%-20s-+-%-15s-+-%-60s\n" "--------------------" "---------------" "------------------------------------------------------------"
}

print_row() {
    local category="$1"
    local status="$2"
    local detail="$3"
    local color="$4"

    if [[ -n "$color" ]]; then
        printf "${color}%-20s | %-15s | %-60s${RESET}\n" "$category" "$status" "$detail"
    else
        printf "%-20s | %-15s | %-60s\n" "$category" "$status" "$detail"
    fi
}

############################################
# Tracking
############################################

declare -a attention_rows=()
declare -A HASH_MAP=()

############################################
# Start
############################################

echo
echo "Housekeeping Scan : $(date)"
print_header

log_all "Housekeeping Scan Started at $(date)"

############################################
# 1. File Classification + Duplicate Detection
############################################

shopt -s nullglob

for file in "$DOWNLOADS"/*; do
    [[ -f "$file" ]] || continue

    base="$(basename "$file")"
    ext="$(lower "${base##*.}")"
    target=""

    case "$ext" in
        zip|tar|gz|tgz|bz2|xz)         target="$DOWNLOADS/compressed" ;;
        deb|rpm|apk|ipa|app|dmg|exe|war|AppImage)  target="$DOWNLOADS/packages" ;;
        jpg|jpeg|png|gif|bmp|webp|svg|tiff) target="$PICTURES" ;;
        doc|docx|odt|rtf)            target="$DOCUMENTS/docs" ;;
        ppt|pptx|odp)                target="$DOCUMENTS/ppt" ;;
        xls|xlsx|ods|csv)            target="$DOCUMENTS/excel" ;;
        mp4|mkv|avi|mov|webm|flv|mpeg) target="$VIDEOS" ;;
        mp3|aac)                       target="$MUSIC" ;;
        pdf)                         target="$DOWNLOADS/pdf" ;;
        *)                           continue ;;
    esac

    ##################################
    # Duplicate detection
    ##################################

    hash="$(sha256sum "$file" | awk '{print $1}')"

    if [[ -n "${HASH_MAP[$hash]:-}" ]]; then
        msg="Duplicate: $base == ${HASH_MAP[$hash]}"
        attention_rows+=("FILES|DUPLICATE|$msg")
        print_row "FILES" "DUPLICATE" "$msg" "$YELLOW"
        log_all "$msg"
    else
        HASH_MAP[$hash]="$base"
    fi

    ##################################
    # Move logic
    ##################################

    if [[ -d "$target" ]]; then
        mv -n "$file" "$target/" && log_all "Moved $base → $target/"
    else
        msg="Missing target dir: $target for file $base"
        attention_rows+=("FILES|SKIPPED|$msg")
        print_row "FILES" "SKIPPED" "$msg" "$YELLOW"
        log_all "$msg"
    fi
done

############################################
# 2. Git Status Scan (Local Only)
############################################

shopt -s nullglob
for dir in "$GIT_ROOT"/*; do
    [[ -d "$dir/.git" ]] || continue

    repo="$(basename "$dir")"
    cd "$dir"

    status="$(git status -sb 2>/dev/null | head -n1)"

    if [[ "$status" == *"ahead"* ]]; then
        msg="Repo has unpushed commits: $repo"
        attention_rows+=("GIT|UNPUSHED|$repo")
        print_row "GIT" "UNPUSHED" "$repo" "$RED"
        log_all "$msg"

    elif [[ "$status" != *"..."* ]]; then
        msg="Repo has no upstream: $repo"
        attention_rows+=("GIT|NO-UPSTREAM|$repo")
        print_row "GIT" "NO-UPSTREAM" "$repo" "$YELLOW"
        log_all "$msg"

    else
        log_all "Repo clean: $repo"
    fi
done

############################################
# 3. Final Summary
############################################

echo
printf "${BOLD}Summary:${RESET}\n"
printf "  Items requiring attention : %s\n" "${#attention_rows[@]}"
printf "  Report file                : %s\n" "$REPORT_FILE"
echo

log_all "Scan completed. Attention items: ${#attention_rows[@]}"
log_all "Report file: $REPORT_FILE"

############################################
# Optional desktop notification
############################################

if command -v notify-send &>/dev/null; then
    notify-send "Housekeeping Completed" \
      "Attention items: ${#attention_rows[@]}"
fi
