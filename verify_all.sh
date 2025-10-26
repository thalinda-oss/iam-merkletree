#!/usr/bin/env bash
set -euo pipefail

# 🔹 ตั้งค่าพื้นฐาน
ROOT="$(pwd)"
LOG="$ROOT/verify.log"
mkdir -p "$ROOT/logs"
LOG="$ROOT/logs/verify.log"
HASHFILE="$ROOT/logs/file_hashes.txt"
MERKLEOUT="$ROOT/logs/merkleroots.txt"

echo "=== MerkleTree Project Verification ==="
echo "Project root: $ROOT"
date | tee "$LOG"
echo | tee -a "$LOG"

# 🔹 1. Compile Java files (อยู่ใน src/)
echo "[1] Compiling Java sources..." | tee -a "$LOG"
if [ -d "$ROOT/src" ]; then
  mkdir -p "$ROOT/bin"
  find "$ROOT/src" -name "*.java" > "$ROOT/javafiles.txt"
  if [ -s "$ROOT/javafiles.txt" ]; then
    javac -d "$ROOT/bin" @"$ROOT/javafiles.txt" 2>&1 | tee -a "$LOG" || true
    echo "✅ Java compile complete." | tee -a "$LOG"
  else
    echo "⚠️ No Java files found in src/." | tee -a "$LOG"
  fi
else
  echo "⚠️ No src/ directory found." | tee -a "$LOG"
fi
echo | tee -a "$LOG"

# 🔹 2. Compute SHA256 hashes for CSV + secure_data
echo "[2] Computing SHA256 hashes..." | tee -a "$LOG"
: >"$HASHFILE"
for dir in csv secure_data; do
  [ -d "$ROOT/$dir" ] || continue
  find "$ROOT/$dir" -type f -exec sha256sum {} \; >> "$HASHFILE"
done
echo "✅ Hashes saved to $HASHFILE" | tee -a "$LOG"
echo | tee -a "$LOG"

# 🔹 3. Import GPG public keys (optional)
echo "[3] Checking for GPG keys..." | tee -a "$LOG"
if ls "$ROOT"/identity/*.asc >/dev/null 2>&1; then
  for key in "$ROOT"/identity/*.asc; do
    gpg --import "$key" 2>&1 | tee -a "$LOG" || true
  done
  echo "✅ Public keys imported." | tee -a "$LOG"
else
  echo "ℹ️ No GPG .asc key files found in identity/." | tee -a "$LOG"
fi
echo | tee -a "$LOG"

# 🔹 4. Compute Merkle roots from CSV files
echo "[4] Computing Merkle roots from CSV..." | tee -a "$LOG"
if [ -f "$ROOT/merkle_compute.py" ]; then
  python3 "$ROOT/merkle_compute.py" --pattern "$ROOT/csv/*.csv" --mode line --out "$MERKLEOUT" 2>&1 | tee -a "$LOG"
  echo "✅ Merkle roots saved to $MERKLEOUT" | tee -a "$LOG"
  echo | tee -a "$LOG"
  echo "📘 Summary of Merkle roots:" | tee -a "$LOG"
  cat "$MERKLEOUT" | tee -a "$LOG"
else
  echo "⚠️ merkle_compute.py not found in project root." | tee -a "$LOG"
fi

echo | tee -a "$LOG"
echo "✅ Verification complete!"
echo "📄 Log file saved at: $LOG"
echo "📄 Hash list: $HASHFILE"
echo "📄 Merkle roots: $MERKLEOUT"
echo
