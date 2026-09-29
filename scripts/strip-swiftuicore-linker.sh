#!/usr/bin/env bash
# Remove invalid -weak_framework SwiftUICore from Runner (added by an old Podfile; apps cannot link it).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export FLICK_REPO_ROOT="$ROOT"
PBX="$ROOT/app/ios/Runner.xcodeproj/project.pbxproj"

if [[ ! -f "$PBX" ]]; then
  echo "No project.pbxproj at $PBX"
  exit 0
fi

if ! grep -q 'SwiftUICore' "$PBX"; then
  echo "OK: no SwiftUICore in project.pbxproj"
  exit 0
fi

python3 <<PY
from pathlib import Path
import os
import re

root = Path(os.environ["FLICK_REPO_ROOT"])
pbx = root / "app/ios/Runner.xcodeproj/project.pbxproj"
text = pbx.read_text()
original = text

text = re.sub(r'\n\t\t\t\t"-weak_framework",\n\t\t\t\t"SwiftUICore",', '', text)
text = re.sub(r'\n\t\t\t\t"-weak_framework SwiftUICore",', '', text)
text = re.sub(r'\s*-weak_framework SwiftUICore\s*', ' ', text)
text = re.sub(r'\s*-weak_framework\s+SwiftUICore\s*', ' ', text)
# Clean empty OTHER_LDFLAGS arrays if needed — leave inherited only
text = re.sub(r'\(\s*\n\t\t\t\t"\\$\(inherited)",\s*\n\t\t\t\);', '("$(inherited)");', text)

if "SwiftUICore" in text:
    print("WARN: SwiftUICore still present — fix in Xcode → Runner → Build Settings → Other Linker Flags")
    for i, line in enumerate(text.splitlines(), 1):
        if "SwiftUICore" in line:
            print(f"  line {i}: {line.strip()}")
    raise SystemExit(1)

if text != original:
    pbx.write_text(text)
    print("Removed SwiftUICore linker flags from project.pbxproj")
else:
    print("No changes made")
PY
