#!/bin/bash
APPS_TSV="config/apps.tsv"
CMDS_TSV="config/commands.tsv"

echo "Checking apps.tsv..."
while IFS=$'\t' read -r number slug name page aliases script function; do
    [[ -z "$number" || "$number" == "#"* ]] && continue
    if [[ ! -f "$script" ]]; then
        echo "Missing script for app $slug: $script"
    fi
done < "$APPS_TSV"

echo "Checking commands.tsv..."
while IFS=$'\t' read -r slug script function; do
    [[ -z "$slug" || "$slug" == "#"* ]] && continue
    if [[ ! -f "$script" ]]; then
        echo "Missing script for command $slug: $script"
    fi
done < "$CMDS_TSV"

echo "Checking lib/installers/ for missing functions based on apps.tsv..."
while IFS=$'\t' read -r number slug name page aliases script function; do
    [[ -z "$number" || "$number" == "#"* ]] && continue
    grep -q -r "function $function" lib/installers/ || grep -q -r "^$function()" lib/installers/ || echo "Function $function not found in lib/installers/ for app $slug"
done < "$APPS_TSV"

echo "Checking lib/installers/ for missing functions based on commands.tsv..."
while IFS=$'\t' read -r slug script function; do
    [[ -z "$slug" || "$slug" == "#"* ]] && continue
    grep -q -r "function $function" lib/installers/ || grep -q -r "^$function()" lib/installers/ || echo "Function $function not found in lib/installers/ for cmd $slug"
done < "$CMDS_TSV"

echo "Checking for unreferenced files in apps/"
for f in apps/*.sh; do
    grep -q "$f" "$APPS_TSV" || echo "Unreferenced app script: $f"
done

echo "Checking for unreferenced files in commands/"
for f in commands/*.sh; do
    grep -q "$f" "$CMDS_TSV" || echo "Unreferenced cmd script: $f"
done

echo "Checking for unreferenced installers in lib/installers/"
for f in lib/installers/*.sh; do
    func_name=$(basename "$f" .sh)
    grep -q "$func_name" "$APPS_TSV" || grep -q "$func_name" "$CMDS_TSV" || echo "Unreferenced installer (filename/function): $f"
done
