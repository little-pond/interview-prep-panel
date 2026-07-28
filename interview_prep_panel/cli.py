"""
interview-prep-panel CLI.

Installs the interview-prep-panel Claude Code skill by fetching it from GitHub
into your Claude Code skills directory (default: ~/.claude/skills). Kept as a thin
downloader so the wheel stays tiny and never ships the ~940MB transcript corpus.

Usage:
    interview-prep-panel install [--dir DIR] [--ref REF] [--build-corpus]
    interview-prep-panel path
    interview-prep-panel --version
"""
from __future__ import annotations

import argparse
import io
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
from pathlib import Path

from . import __version__

REPO = "little-pond/interview-prep-panel"
NAME = "interview-prep-panel"


def _skills_dir(cli_dir: str | None) -> Path:
    if cli_dir:
        return Path(cli_dir).expanduser()
    return Path(os.environ.get("SKILLS_DIR", Path.home() / ".claude" / "skills")).expanduser()


def _c(code: str, text: str) -> str:
    return f"\033[{code}m{text}\033[0m" if sys.stdout.isatty() else text


def _download_and_extract(ref: str, dest: Path) -> None:
    url = f"https://github.com/{REPO}/archive/refs/heads/{ref}.tar.gz"
    print(_c("1;36", "▸") + f" Downloading {url}")
    try:
        with urllib.request.urlopen(url) as resp:  # noqa: S310 (trusted GitHub host)
            blob = resp.read()
    except Exception as exc:  # pragma: no cover
        print(_c("1;31", "✗") + f" Download failed: {exc}", file=sys.stderr)
        raise SystemExit(1)

    with tempfile.TemporaryDirectory() as tmp:
        with tarfile.open(fileobj=io.BytesIO(blob)) as tar:
            try:
                tar.extractall(tmp, filter="data")  # py3.12+ safe extraction
            except TypeError:
                tar.extractall(tmp)  # older pythons
        roots = [p for p in Path(tmp).iterdir() if p.is_dir()]
        if not roots:
            print(_c("1;31", "✗") + " Archive was empty.", file=sys.stderr)
            raise SystemExit(1)
        src = roots[0]
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(src, dest)


def cmd_install(args: argparse.Namespace) -> None:
    skills = _skills_dir(args.dir)
    dest = skills / NAME
    skills.mkdir(parents=True, exist_ok=True)
    action = "Updating" if dest.exists() else "Installing"
    print(_c("1;36", "▸") + f" {action} {NAME} → {dest}")
    _download_and_extract(args.ref, dest)
    print(_c("1;32", "✓") + f" Installed (KB-only mode ready) at {dest}")

    if args.build_corpus:
        script = dest / "build" / "pull_transcripts.sh"
        if shutil.which("yt-dlp"):
            print(_c("1;36", "▸") + " Building transcript corpus (~940MB, ~45–60 min)…")
            subprocess.run(["bash", str(script)], check=False)
            print(_c("1;32", "✓") + " Corpus built — live retrieval enabled.")
        else:
            print(_c("1;33", "!") + " yt-dlp not found; skipping corpus build.")
            print(f"    Install it, then run: bash \"{script}\"")

    _print_next(dest)


def cmd_path(args: argparse.Namespace) -> None:
    dest = _skills_dir(args.dir) / NAME
    print(dest)
    if not dest.exists():
        print(_c("1;33", "!") + " (not installed yet — run: interview-prep-panel install)", file=sys.stderr)


def _print_next(dest: Path) -> None:
    print(
        "\n  Next:\n"
        "    • In Claude Code, ask an interview question — the panel auto-routes:\n"
        '        "I have a PMM interview in two weeks — give me a full prep plan."\n'
        f"    • Prompt ideas:  {dest / 'PROMPTS.md'}\n"
        f"    • Full guide:    {dest / 'README.md'}\n"
        f"    • (Optional) live retrieval — build the ~940MB corpus (needs yt-dlp):\n"
        f"        bash \"{dest / 'build' / 'pull_transcripts.sh'}\"\n"
    )


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(prog=NAME, description="Install the interview-prep-panel Claude Code skill.")
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    sub = parser.add_subparsers(dest="command")

    p_install = sub.add_parser("install", help="Install/update the skill into your Claude Code skills dir.")
    p_install.add_argument("--dir", help="Skills directory (default: $SKILLS_DIR or ~/.claude/skills).")
    p_install.add_argument("--ref", default="main", help="Git branch/tag to install (default: main).")
    p_install.add_argument("--build-corpus", action="store_true", help="Also pull the ~940MB transcript corpus (needs yt-dlp).")
    p_install.set_defaults(func=cmd_install)

    p_path = sub.add_parser("path", help="Print where the skill is/would be installed.")
    p_path.add_argument("--dir", help="Skills directory to check.")
    p_path.set_defaults(func=cmd_path)

    args = parser.parse_args(argv)
    if not getattr(args, "command", None):
        # bare `interview-prep-panel` → default to install
        args = parser.parse_args((argv or []) + ["install"])
    args.func(args)


if __name__ == "__main__":
    main()
