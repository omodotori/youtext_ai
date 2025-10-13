import tempfile
from pathlib import Path

import streamlit as st

try:
    import torch
except ImportError:
    torch = None

from core.audio import to_wav_16k_mono
from core.downloader import download_audio
from core.stt import transcribe

try:
    from extras.summarize import summarize_text
except ImportError:
    summarize_text = None


st.set_page_config(page_title="YouText AI", layout="wide")
st.title("YouText AI: YouTube to text locally")

st.markdown(
    "Paste a YouTube link to pull the audio, run Whisper locally, and get a "
    "timestamped transcript with an optional summary. No paid APIs required."
)

url = st.text_input("YouTube link")
col1, col2, col3 = st.columns(3)

with col1:
    model_size = st.selectbox("Whisper model", ["tiny", "small", "medium"], index=1)

with col2:
    language_option = st.selectbox("Language", ["auto", "ru", "en"], index=1)

with col3:
    if torch is not None:
        device = "cuda" if torch.cuda.is_available() else "cpu"
    else:
        device = "cpu"
    st.write(f"Device: **{device}**")

use_summary = summarize_text is not None and st.checkbox(
    "Generate summary (requires transformers)",
    value=False,
)


def _resolve_language(value: str) -> str | None:
    """Translate the UI selection to the whisper argument."""
    if value == "auto":
        return None
    return value


if st.button("Transcribe") and url:
    try:
        with st.spinner("Processing..."):
            with tempfile.TemporaryDirectory() as tmp_dir:
                tmp_path = Path(tmp_dir)

                st.info("Downloading audio with yt-dlp...")
                m4a_path = download_audio(url, tmp_path)

                st.info("Converting to 16 kHz mono WAV with ffmpeg...")
                wav_path = to_wav_16k_mono(m4a_path, tmp_path / "audio.wav")

                st.info(f"Running Whisper {model_size}...")
                transcript_text, segments = transcribe(
                    wav_path,
                    model_size=model_size,
                    device=device,
                    language=_resolve_language(language_option),
                )

        st.success("Done!")
        st.text_area("Transcript with timestamps", transcript_text, height=360)
        st.download_button("Download .txt", transcript_text, file_name="transcript.txt")

        if segments:
            with st.expander("Segments"):
                for seg in segments:
                    st.write(f"[{seg['start']:.1f}s - {seg['end']:.1f}s] {seg['text']}")

        if use_summary:
            with st.spinner("Generating summary..."):
                summary = summarize_text(transcript_text)
            st.subheader("Summary")
            st.write(summary)

    except Exception as exc:  # pragma: no cover
        st.error(f"Processing failed: {exc}")
