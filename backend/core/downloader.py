"""Helpers for downloading audio from YouTube using yt-dlp."""

from __future__ import annotations

import subprocess
from pathlib import Path


def download_audio(url: str, out_dir: Path) -> Path:
    """Download the audio track as .m4a and return the resulting path."""
    out_dir.mkdir(parents=True, exist_ok=True)
    target = out_dir / "source.m4a"
    # yt-dlp writes using template placeholders, so keep the %(ext)s suffix.
    template = out_dir / "source.%(ext)s"
    cmd = [
        "yt-dlp",
        "-x",
        "--audio-format",
        "m4a",
        "-o",
        str(template),
        url,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"yt-dlp error: {result.stderr[:500]}")
    if not target.exists():
        raise FileNotFoundError("Failed to save .m4a audio file")
    return target
