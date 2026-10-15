#!/usr/bin/env python3
"""Pack a theme folder (theme.json + assets/**.svg) into one uploadable bundle.

Usage: make-bundle.py <theme-folder> <out.theme.json>
"""
import json, pathlib, sys

src, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
theme = json.loads((src / "theme.json").read_text())
theme["assets"] = {
    str(p.relative_to(src)): p.read_text()
    for p in sorted((src / "assets").rglob("*.svg"))
}
out.write_text(json.dumps(theme, indent=2) + "\n")
print(f"{out}: {len(theme['assets'])} assets, {out.stat().st_size // 1024} KiB")
