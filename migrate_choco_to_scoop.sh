#!/bin/bash

# Получение списка установленных приложений через Chocolatey
echo "Получение списка установленных приложений через Chocolatey..."
choco_apps=$(choco list | awk '{print $1}' | tail -n +2)

# Проверка наличия приложений в Scoop
echo "Проверка приложений в Scoop..."
can_migrate=()
cannot_migrate=()

# Файл для логирования результатов проверки приложений
log_file="scoop_check.log"
declare -A scoop_cache

# Загрузка существующего лога, если он есть
if [ -f "$log_file" ]; then
    while IFS=":" read -r app status; do
        scoop_cache["$app"]="$status"
    done < "$log_file"
fi

for app in $choco_apps; do
    if [ -n "${scoop_cache["$app"]}" ]; then
        # Используем кэшированные результаты
        if [ "${scoop_cache["$app"]}" == "can_migrate" ]; then
            can_migrate+=("$app")
        else
            cannot_migrate+=("$app")
        fi
    else
        # Выполняем запрос к Scoop
        scoop_result=$(scoop search "$app" 2>/dev/null)
        if echo "$scoop_result" | grep -q "$app"; then
            can_migrate+=("$app")
            scoop_cache["$app"]="can_migrate"
            echo "$app:can_migrate" >> "$log_file"
        else
            cannot_migrate+=("$app")
            scoop_cache["$app"]="cannot_migrate"
            echo "$app:cannot_migrate" >> "$log_file"
        fi
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

# Команда для удаления всех приложений, которые можно смигрировать
if [ "${#can_migrate[@]}" -gt 0 ]; then
    echo ""
    echo "Команда для удаления приложений через Chocolatey:"
    echo "choco uninstall ${can_migrate[*]}"
fi


# Команда для установки всех приложений, которые можно смигрировать
if [ "${#can_migrate[@]}" -gt 0 ]; then
    echo ""
    echo "Команда для установки приложений через Scoop:"
    echo "scoop install ${can_migrate[*]}"
fi