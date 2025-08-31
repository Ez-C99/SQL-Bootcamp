#!/usr/bin/env bash
set -euo pipefail
DIR="sql-ultimate-course/datasets/postgres"
echo "Auditing $DIR ..."
grep -RIn --color=always -E '\bAUTO_INCREMENT\b|`[^`]+`|\bIFNULL\s*\(|\bNVARCHAR\b|\bNCHAR\b|\bGO\b|\bIDENTITY\s*\(|\bGETDATE\s*\(|\bDATETIME\b|\bENGINE=|USE\s+\w+;|^\s*DELIMITER\b' "$DIR" || true
echo "If anything printed above, it's likely not valid PostgreSQL."
