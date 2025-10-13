"""Speech-to-text helpers built on top of faster-whisper."""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Dict, List, Tuple

from faster_whisper import WhisperModel

Segment = Dict[str, float | str]


@lru_cache(maxsize=2)
def _load_model(model_size: str, device: str) -> WhisperModel:
    """Cache model instances so repeated requests are faster."""
    return WhisperModel(model_size, device=device)


def transcribe(
    wav_path: str | Path,
    model_size: str = "small",
    device: str = "cpu",
    language: str | None = "ru",
) -> Tuple[str, List[Segment]]:
    """Transcribe a WAV file and return formatted text plus segment metadata."""
    model = _load_model(model_size, device)
    segments_iter, _ = model.transcribe(
        str(wav_path),
        beam_size=5,
        language=language,
    )

    lines: List[str] = []
    meta: List[Segment] = []

    for seg in segments_iter:
        text = seg.text.strip()
        lines.append(f"[{seg.start:.1f}s - {seg.end:.1f}s] {text}")
        meta.append({"start": float(seg.start), "end": float(seg.end), "text": text})

    if not lines:
        lines.append("No speech segments detected.")

    return "\n".join(lines), meta
