#!/usr/bin/env bash
#
# discript-qa — автоматический установщик
#
# Запуск:
#   curl -fsSL https://raw.githubusercontent.com/ikobzar-git/discript-qa/main/install.sh | bash
#
# Что делает:
#   1. Бэкап ~/.claude/settings.json
#   2. Клонирует плагин в ~/.claude/plugins/marketplaces/discript-qa
#   3. Регистрирует marketplace и включает плагин в settings.json
#   4. Просит перезапустить Cursor
#

set -euo pipefail

PLUGIN_NAME="discript-qa"
REPO_URL="https://github.com/ikobzar-git/discript-qa.git"
CLAUDE_DIR="$HOME/.claude"
MARKETPLACES_DIR="$CLAUDE_DIR/plugins/marketplaces"
PLUGIN_DIR="$MARKETPLACES_DIR/$PLUGIN_NAME"
SETTINGS="$CLAUDE_DIR/settings.json"
KNOWN_MARKETPLACES="$CLAUDE_DIR/plugins/known_marketplaces.json"

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

printf "\n${BLUE}🧪 discript-qa — установка${NC}\n\n"

# --- Проверки ---
command -v git >/dev/null 2>&1 || { printf "${RED}❌ Нужен git${NC}\n"; exit 1; }
command -v python3 >/dev/null 2>&1 || { printf "${RED}❌ Нужен python3${NC}\n"; exit 1; }

if [ ! -d "$CLAUDE_DIR" ]; then
  printf "${RED}❌ Папка ~/.claude не найдена.${NC}\n"
  printf "Сначала установи Claude Code: https://claude.com/code\n"
  exit 1
fi

# --- Шаг 1: бэкап ---
printf "${BLUE}[1/4]${NC} Делаю бэкап настроек...\n"
if [ -f "$SETTINGS" ]; then
  BACKUP="$SETTINGS.backup-$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS" "$BACKUP"
  printf "      Бэкап: ${YELLOW}$BACKUP${NC}\n"
else
  printf "      settings.json не найден — создам новый\n"
fi

# --- Шаг 2: клонирование ---
printf "${BLUE}[2/4]${NC} Скачиваю плагин из GitHub...\n"
mkdir -p "$MARKETPLACES_DIR"
if [ -d "$PLUGIN_DIR/.git" ]; then
  (cd "$PLUGIN_DIR" && git pull --quiet)
  printf "      Обновлено (${PLUGIN_DIR})\n"
else
  git clone --quiet "$REPO_URL" "$PLUGIN_DIR"
  printf "      Склонировано (${PLUGIN_DIR})\n"
fi

# --- Шаг 3: регистрация в настройках ---
printf "${BLUE}[3/4]${NC} Регистрирую плагин в Claude Code...\n"
python3 - <<PYEOF
import json, os
from datetime import datetime, timezone

settings_path = "$SETTINGS"
known_path = "$KNOWN_MARKETPLACES"
plugin_dir = "$PLUGIN_DIR"

# settings.json
s = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        s = json.load(f)

s.setdefault("extraKnownMarketplaces", {})["discript-qa"] = {
    "source": {"source": "github", "repo": "ikobzar-git/discript-qa"}
}
s.setdefault("enabledPlugins", {})["discript-qa@discript-qa"] = True

with open(settings_path, "w") as f:
    json.dump(s, f, indent=2, ensure_ascii=False)

# known_marketplaces.json
os.makedirs(os.path.dirname(known_path), exist_ok=True)
m = {}
if os.path.exists(known_path):
    with open(known_path) as f:
        m = json.load(f)

m["discript-qa"] = {
    "source": {"source": "github", "repo": "ikobzar-git/discript-qa"},
    "installLocation": plugin_dir,
    "lastUpdated": datetime.now(timezone.utc).isoformat()
}

with open(known_path, "w") as f:
    json.dump(m, f, indent=2)

print("      settings.json и known_marketplaces.json обновлены")
PYEOF

# --- Шаг 4: финал ---
printf "${BLUE}[4/4]${NC} Проверяю установку...\n"
AGENTS_COUNT=$(ls "$PLUGIN_DIR/agents/" 2>/dev/null | wc -l | tr -d ' ')
COMMANDS_COUNT=$(ls "$PLUGIN_DIR/commands/" 2>/dev/null | wc -l | tr -d ' ')
printf "      Агентов: $AGENTS_COUNT, команд: $COMMANDS_COUNT\n"

printf "\n${GREEN}✅ Плагин discript-qa успешно установлен!${NC}\n\n"
printf "${YELLOW}ЧТО ДАЛЬШЕ:${NC}\n"
printf "  1. Полностью закрой Cursor: ${BLUE}Cmd+Q${NC} (не просто окно)\n"
printf "  2. Открой Cursor заново\n"
printf "  3. В Claude Code набери ${BLUE}/qa-help${NC} — появится список команд\n"
printf "  4. Для первого аудита: ${BLUE}/qa-start${NC}\n\n"
printf "Документация: ${BLUE}https://github.com/ikobzar-git/discript-qa${NC}\n\n"
