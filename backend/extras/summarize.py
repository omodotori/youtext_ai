"""Optional text summarisation utilities."""

from __future__ import annotations

from typing import List

from transformers import pipeline


def summarize_text(
    text: str,
    model_name: str = "t5-small",
    max_chars: int = 3000,
) -> str:
    """Summarise long text using a transformer model."""
    normalized = " ".join(text.split())
    if not normalized:
        return "Nothing to summarise."

    chunks: List[str] = [
        normalized[i : i + max_chars] for i in range(0, len(normalized), max_chars)
    ]
    summarizer = pipeline("summarization", model=model_name, device=-1)

    outputs: List[str] = []
    for chunk in chunks:
        result = summarizer(chunk, max_length=150, min_length=30, truncation=True)
        outputs.append(result[0]["summary_text"])
    return " ".join(outputs)
