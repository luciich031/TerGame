#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAMES_CONF="$SCRIPT_DIR/games.conf"
WINE_PREFIX_BASE="$HOME/.wine-games"

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
    echo -e "${CYAN}Game Launcher for Arch Linux${NC}"
    echo "Usage:"
    echo "  $0 list              - List available games"
    echo "  $0 run <game-name>   - Launch a game by name"
    echo "  $0 add <name> <path> - Add a game to the registry"
    echo "  $0 remove <name>     - Remove a game"
    echo "  $0 <path-to-exe>     - Run a .exe file directly"
}

check_wine() {
    if ! command -v wine &>/dev/null; then
        echo -e "${RED}Error: Wine is not installed.${NC}"
        echo "Install with: sudo pacman -S wine wine-mono wine-gecko"
        exit 1
    fi
}

list_games() {
    if [[ ! -f "$GAMES_CONF" ]]; then
        echo -e "${YELLOW}No games registered yet. Use '$0 add <name> <path>' to add one.${NC}"
        return
    fi
    echo -e "${CYAN}Registered Games:${NC}"
    echo "─────────────────────────────────────────"
    local i=1
    while IFS='=' read -r name path; do
        [[ -z "$name" || "$name" == \#* ]] && continue
        echo "  ${i}. ${name} → ${path}"
        ((i++))
    done < "$GAMES_CONF"
}

add_game() {
    local name="$1"
    local path="$2"
    if [[ ! -f "$path" ]]; then
        echo -e "${RED}Error: File '$path' not found.${NC}"
        exit 1
    fi
    # remove existing entry if present
    grep -v "^${name}=" "$GAMES_CONF" > "${GAMES_CONF}.tmp" 2>/dev/null || true
    mv "${GAMES_CONF}.tmp" "$GAMES_CONF"
    echo "${name}=${path}" >> "$GAMES_CONF"
    echo -e "${GREEN}Added: ${name} → ${path}${NC}"
}

remove_game() {
    local name="$1"
    grep -v "^${name}=" "$GAMES_CONF" > "${GAMES_CONF}.tmp" 2>/dev/null || true
    mv "${GAMES_CONF}.tmp" "$GAMES_CONF"
    echo -e "${GREEN}Removed: ${name}${NC}"
}

run_game() {
    local name="$1"
    local path=""
    while IFS='=' read -r n p; do
        [[ "$n" == "$name" ]] && path="$p"
    done < "$GAMES_CONF"

    if [[ -z "$path" ]]; then
        echo -e "${RED}Error: Game '$name' not found in registry.${NC}"
        exit 1
    fi
    launch_exe "$path"
}

launch_exe() {
    local exe_path="$1"
    local game_name
    game_name="$(basename "$(dirname "$exe_path")")"

    local prefix="$WINE_PREFIX_BASE/$game_name"

    # Initialize the prefix on first run
    if [[ ! -d "$prefix/drive_c" ]]; then
        echo -e "${YELLOW}Initializing Wine prefix (first run, may take a moment)...${NC}"
        WINEPREFIX="$prefix" wineboot -u
    fi

    echo -e "${GREEN}Launching: $exe_path${NC}"
    echo -e "Prefix: $prefix"
    echo "─────────────────────────────────────────"

    # cd into the game's directory — many Windows programs expect this
    cd "$(dirname "$exe_path")"

    WINEPREFIX="$prefix" wine "$exe_path"
}

# main
case "${1:-}" in
    list|ls)
        check_wine
        list_games
        ;;
    run)
        check_wine
        [[ -z "${2:-}" ]] && { echo "Usage: $0 run <game-name>"; exit 1; }
        run_game "$2"
        ;;
    add)
        check_wine
        [[ -z "${2:-}" || -z "${3:-}" ]] && { echo "Usage: $0 add <name> <path-to-exe>"; exit 1; }
        touch "$GAMES_CONF"
        add_game "$2" "$3"
        ;;
    remove|rm)
        check_wine
        [[ -z "${2:-}" ]] && { echo "Usage: $0 remove <game-name>"; exit 1; }
        remove_game "$2"
        ;;
    help|-h|--help)
        usage
        ;;
    "")
        usage
        ;;
    *)
        # treat argument as a direct .exe path
        if [[ -f "$1" ]]; then
            check_wine
            launch_exe "$1"
        else
            echo -e "${RED}Error: '$1' is not a valid file or command.${NC}"
            usage
            exit 1
        fi
        ;;
esac   