#!/bin/bash

# Получение списка установленных приложений через Chocolatey
echo "Получение списка установленных приложений через Chocolatey..."
choco_apps=$(choco list | awk '{print $1}' | tail -n +2)

# Логирование списка установленных приложений
echo "$choco_apps"

# Проверка наличия приложений в Scoop
echo "Проверка приложений в Scoop..."
can_migrate=()
cannot_migrate=()

for app in $choco_apps; do
    echo "Поиск $app"
    # Проверяем, доступно ли приложение в Scoop
    scoop_result=$(scoop search "$app" 2>/dev/null)
    if echo "$scoop_result" | grep -q "$app"; then
        can_migrate+=("$app")
    else
        cannot_migrate+=("$app")
    fi
done

# Вывод результатов
echo "Приложения, которые можно перенести из Chocolatey в Scoop:"
for app in "${can_migrate[@]}"; do
    echo "- $app"
done

echo ""
echo "Приложения, которые нельзя перенести из Chocolatey в Scoop:"
for app in "${cannot_migrate[@]}"; do
    echo "- $app"
done