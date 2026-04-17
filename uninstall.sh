#!/usr/bin/env bash
#
# discript-qa — удаление плагина
#
# Запуск:
#   curl -fsSL https://raw.githubusercontent.com/ikobzar-git/discript-qa/main/uninstall.sh | bash
#

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
PLUGIN_DIR="$CLAUDE_DIR/plugins/marketplaces/discript-qa"
SETTINGS="$CLAUDE_DIR/settings.json"
KNOWN_MARKETPLACES="$CLAUDE_DIR/plugins/known_marketplaces.json"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

printf "\n${BLUE}🧪 discript-qa — удаление${NC}\n\n"

# Бэкап
if [ -f "$SETTINGS" ]; then
  BACKUP="$SETTINGS.backup-$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS" "$BACKUP"
  printf "Бэкап settings.json: ${YELLOW}$BACKUP${NC}\n"
fi

# Удаляем из settings.json
python3 - <<PYEOF
import json, os

for path in ["$SETTINGS", "$KNOWN_MARKETPLACES"]:
    if not os.path.exists(path):
        continue
    with open(path) as f:
        data = json.load(f)
    if "extraKnownMarketplaces" in data and "discript-qa" in data["extraKnownMarketplaces"]:
        del data["extraKnownMarketplaces"]["discript-qa"]
    if "enabledPlugins" in data:
        data["enabledPlugins"] = {k: v for k, v in data["enabledPlugins"].items() if not k.startswith("discript-qa@")}
    if "discript-qa" in data:
        del data["discript-qa"]
    with open(path, "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
print("Плагин удалён из настроек.")
PYEOF

# Удаляем папку плагина
if [ -d "$PLUGIN_DIR" ]; then
  rm -rf "$PLUGIN_DIR"
  printf "Удалена папка: ${YELLOW}$PLUGIN_DIR${NC}\n"
fi

printf "\n${GREEN}✅ discript-qa удалён${NC}\n"
printf "Перезапусти Cursor (${BLUE}Cmd+Q${NC}) для применения изменений.\n\n"
