#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
main_file="${1:-thesis0525.tex}"
mode="${2:-}"
out_dir="$repo_root/review-diff"

if ! command -v latexdiff >/dev/null 2>&1; then
  echo "latexdiff not found" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

old_dir="$tmpdir/old"
new_dir="$tmpdir/new"
mkdir -p "$old_dir" "$new_dir" "$out_dir"

git -C "$repo_root" archive HEAD | tar -xf - -C "$old_dir"

rsync -a \
  --exclude '.git' \
  --exclude '.texpadtmp' \
  --exclude 'review-diff' \
  --exclude 'diff' \
  --exclude '*.aux' \
  --exclude '*.bbl' \
  --exclude '*.bcf' \
  --exclude '*.blg' \
  --exclude '*.fdb_latexmk' \
  --exclude '*.fls' \
  --exclude '*.lof' \
  --exclude '*.log' \
  --exclude '*.lot' \
  --exclude '*.out' \
  --exclude '*.run.xml' \
  --exclude '*.synctex.gz' \
  --exclude '*.toc' \
  --exclude '*.xdv' \
  "$repo_root/" "$new_dir/"

diff_tex="$out_dir/${main_file##*/}"

latexdiff --flatten "$old_dir/$main_file" "$new_dir/$main_file" > "$diff_tex"

echo "Generated $diff_tex"

if grep -q '\\input{chapters' "$diff_tex"; then
  echo "Warning: diff file still contains chapter inputs; flatten may be incomplete." >&2
fi

if [[ "$mode" == "--pdf" ]]; then
  if ! command -v latexmk >/dev/null 2>&1; then
    echo "latexmk not found" >&2
    exit 1
  fi
  (
    cd "$repo_root"
    latexmk -xelatex -interaction=nonstopmode -halt-on-error -output-directory="$out_dir" "$diff_tex"
  )
  echo "Generated ${diff_tex%.tex}.pdf"
fi
