#!/usr/bin/env python3
import argparse
import os
import subprocess
from pathlib import Path

LAMBDA_ROOT = Path("lambdas")

def run(cmd: list[str]) -> str:
    return subprocess.check_output(cmd, text=True).strip()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-ref", required=True, help="Git ref to compare against, e.g. origin/main")
    args = ap.parse_args()

    if not LAMBDA_ROOT.exists():
        return

    # Get changed files
    diff = run(["git", "diff", "--name-only", f"{args.base_ref}...HEAD"])
    if not diff:
        return

    changed = set()
    for line in diff.splitlines():
        p = Path(line)
        # only consider changes under lambdas/<lambda_name>/
        parts = p.parts
        if len(parts) >= 2 and parts[0] == "lambdas":
            changed.add(parts[1])

    # Output one per line (stable)
    for name in sorted(changed):
        # Ensure the folder still exists (skip deletions)
        if (LAMBDA_ROOT / name).exists():
            print(name)

if __name__ == "__main__":
    main()
