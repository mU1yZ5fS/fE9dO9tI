# -*- coding: utf-8 -*-
"""GDScript 轻量语法自检：缩进一致性 + 括号配平（无 godot CLI 时的兜底）。"""
import io
import re
import sys

FILES = [
    r"数据脚本/地图数据/map_service.gd",
    r"数据脚本/systems/war_system.gd",
    r"数据脚本/game_manager.gd",
    r"数据脚本/ui/调试控制台.gd",
]

fail = False
for path in FILES:
    t = io.open(path, encoding="utf-8").read()
    lines = t.splitlines()

    space_indented = [(i + 1, l) for i, l in enumerate(lines) if re.match(r"^ +\S", l)]

    no_str = re.sub(r'"(?:[^"\\]|\\.)*"', '""', t)
    no_comment = re.sub(r"#.*", "", no_str)
    ok_paren = no_comment.count("(") == no_comment.count(")")
    ok_brack = no_comment.count("[") == no_comment.count("]")

    status = "OK" if (not space_indented and ok_paren and ok_brack) else "CHECK"
    if status != "OK":
        fail = True
    print("%s: %s space_indent=%d paren_bal=%s bracket_bal=%s"
          % (path, status, len(space_indented), ok_paren, ok_brack))
    for ln, l in space_indented[:3]:
        print("   line %d: %r" % (ln, l[:60]))

sys.exit(1 if fail else 0)
