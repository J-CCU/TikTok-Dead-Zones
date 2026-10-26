#!/bin/bash
# Double-click on a Mac to build "CashCards LIVE.app" (if macOS blocks it: right-click > Open).
cd "$(dirname "$0")" || exit 1
echo
echo " === Building CashCards LIVE.app ==="
echo

SRC="$(ls *LIVE\ Dashboard*.pyw *LIVE\ Dashboard*.py 2>/dev/null | head -1)"
if [ -z "$SRC" ]; then
  echo " Could not find 'CashCards LIVE Dashboard.pyw' in this folder."
  echo " Put this build file in the same folder as the app and run it again."
  read -n1 -rsp $'\n Press any key to close...'; exit 1
fi
echo " Source: $SRC"

# Python with Tk (python.org install preferred)
PY=""
for P in /Library/Frameworks/Python.framework/Versions/Current/bin/python3 /opt/homebrew/bin/python3 /usr/local/bin/python3 /usr/bin/python3; do
  if [ -x "$P" ] && "$P" -c "import tkinter" 2>/dev/null; then PY="$P"; break; fi
done
if [ -z "$PY" ]; then
  echo " Python 3 (with Tk) not found. Install it from https://www.python.org/downloads/ and run this again."
  read -n1 -rsp $'\n Press any key to close...'; exit 1
fi
echo " Python: $PY"
echo

# Build in a private environment so nothing on the Mac gets changed
VENV="${TMPDIR:-/tmp}/ccl_build_venv"
"$PY" -m venv "$VENV" || { echo " Could not create build environment."; read -n1 -rsp $'\n Press any key...'; exit 1; }
"$VENV/bin/python" -m pip install --upgrade --quiet pip pyinstaller || { echo " Could not install PyInstaller."; read -n1 -rsp $'\n Press any key...'; exit 1; }

rm -rf "CashCards LIVE.app"
"$VENV/bin/python" -m PyInstaller --windowed --noconfirm --clean \
  --name "CashCards LIVE" \
  --distpath "$PWD" --workpath "${TMPDIR:-/tmp}/ccl_build" --specpath "${TMPDIR:-/tmp}/ccl_build" \
  "$SRC" || { echo; echo " Build FAILED - see the messages above."; read -n1 -rsp $'\n Press any key...'; exit 1; }

rm -rf "CashCards LIVE"            # leftover folder; the .app is what you send
xattr -cr "CashCards LIVE.app" 2>/dev/null

echo
echo " =========================================================="
echo "  Done:  $PWD/CashCards LIVE.app"
echo
echo "  Send people:  CashCards LIVE.app (zip it first)  +  your env file"
echo "  Built for this Mac's chip: $(uname -m)"
echo " =========================================================="
open -R "CashCards LIVE.app"
read -n1 -rsp $'\n Press any key to close...'
