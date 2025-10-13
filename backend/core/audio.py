"""Audio conversion utilities powered by ffmpeg."""

from __future__ import annotations

import subprocess
from pathlib import Path


def to_wav_16k_mono(src_path: Path, dst_path: Path) -> Path:
    """Convert the input file to a 16 kHz mono WAV and return the destination."""
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        str(src_path),
        "-ar",
        "16000",
        "-ac",
        "1",
        str(dst_path),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"ffmpeg error: {result.stderr[:500]}")
    if not dst_path.exists():
        raise FileNotFoundError("Failed to create WAV file")
    return dst_path
