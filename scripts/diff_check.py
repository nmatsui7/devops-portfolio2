#!/usr/bin/env python3
"""
Compare your code in app/ against the solutions/ reference implementation.

Shows line-by-line differences so you can spot typos, missing code,
or logic errors. Only shows files that differ.

Usage:
    python scripts/diff_check.py                    # check all .py files
    python scripts/diff_check.py app.py             # check one file
    python scripts/diff_check.py models.py app.py   # check specific files
"""

import sys
import os
from difflib import Differ

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)

APP_DIR = os.path.join(PROJECT_DIR, "app")
SOLUTION_DIR = os.path.join(PROJECT_DIR, "solutions", "app")

ALL_FILES = ["config.py", "models.py", "app.py", "migrations.py"]

def green(text):
    return f"\033[92m{text}\033[0m"

def red(text):
    return f"\033[91m{text}\033[0m"

def yellow(text):
    return f"\033[93m{text}\033[0m"

def cyan(text):
    return f"\033[96m{text}\033[0m"

def bold(text):
    return f"\033[1m{text}\033[0m"

def compare_files(filename):
    app_path = os.path.join(APP_DIR, filename)
    sol_path = os.path.join(SOLUTION_DIR, filename)

    if not os.path.exists(app_path):
        print(f"  {red('[MISSING]')} {filename} not found in app/")
        return "error"

    if not os.path.exists(sol_path):
        print(f"  {yellow('[SKIP]')} {filename} has no solution file")
        return "error"

    with open(app_path) as f:
        app_lines = f.readlines()
    with open(sol_path) as f:
        sol_lines = f.readlines()

    differ = Differ()
    diff = list(differ.compare(app_lines, sol_lines))

    has_diff = False
    for line in diff:
        if line.startswith("+ ") or line.startswith("- "):
            has_diff = True
            break

    if not has_diff:
        return "match"

    print(f"\n  {bold(filename)}")
    print(f"  {'=' * len(filename) + '  ' + '=' * 30}")

    in_header = True
    for i, line in enumerate(diff):
        if line.startswith("+ ") or line.startswith("- ") or line.startswith("? "):
            if in_header:
                in_header = False
            if line.startswith("+ "):
                print(f"    {green(line.rstrip())}")
            elif line.startswith("- "):
                print(f"    {red(line.rstrip())}")
            else:
                print(f"    {cyan(line.rstrip())}")
        elif not in_header:
            print(f"    {line.rstrip()}")

    return "diff"


def main():
    filenames = sys.argv[1:] if len(sys.argv) > 1 else ALL_FILES

    print(bold("\n\u2728 Diff Check: Your Code vs. Solutions"))
    print("  " + green("+ lines") + " = missing from your code (add these)")
    print("  " + red("- lines") + " = extra or wrong in your code (remove/fix)")
    print("  " + cyan("? lines") + " = hints about what changed")
    print()

    has_diff = False
    has_error = False
    for fname in filenames:
        if fname not in ALL_FILES:
            print(f"  {yellow('[SKIP]')} unknown file: {fname}")
            has_error = True
            continue
        result = compare_files(fname)
        if result == "diff":
            has_diff = True
        elif result == "error":
            has_error = True

    if not has_diff and not has_error:
        print(green("  All checked files match the solutions! \u2714"))
    elif not has_diff and has_error:
        print()
        print(yellow("  \u2139\ufe0f  Some files could not be checked — see messages above."))
    else:
        print()
        print(yellow("  \u2139\ufe0f  Lines shown above differ from the solutions."))
        print(yellow("     '+' lines are in solutions but missing from your code."))
        print(yellow("     '-' lines are in your code but not in the solutions."))


if __name__ == "__main__":
    main()
