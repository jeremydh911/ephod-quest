#!/usr/bin/env python3
"""
Audio Splitter for Combined SFX Files
Detects silence gaps and splits combined audio into individual files
"""

import os
import sys

try:
    from pydub import AudioSegment
    from pydub.silence import detect_nonsilent
except ImportError:
    print("❌ pydub not installed. Install with:")
    print("   pip install pydub")
    print("   sudo apt install ffmpeg  # Required by pydub")
    sys.exit(1)

def split_audio_file(input_path, output_dir, min_silence_len=500, silence_thresh=-40):
    """
    Split a combined audio file into individual segments
    
    Args:
        input_path: Path to combined WAV file
        output_dir: Directory to save split files
        min_silence_len: Minimum silence length in ms (default 500ms)
        silence_thresh: Silence threshold in dBFS (default -40)
    """
    print(f"\n🎵 Processing: {os.path.basename(input_path)}")
    
    # Load audio
    audio = AudioSegment.from_wav(input_path)
    
    # Detect non-silent chunks
    nonsilent_ranges = detect_nonsilent(
        audio,
        min_silence_len=min_silence_len,
        silence_thresh=silence_thresh
    )
    
    print(f"   Found {len(nonsilent_ranges)} sound segments")
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Extract each segment
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    
    for i, (start, end) in enumerate(nonsilent_ranges, 1):
        segment = audio[start:end]
        duration = (end - start) / 1000.0  # Convert to seconds
        
        output_path = os.path.join(output_dir, f"{base_name}_part{i:02d}.wav")
        segment.export(output_path, format="wav")
        
        print(f"   ✅ Segment {i}: {duration:.2f}s → {os.path.basename(output_path)}")
    
    return len(nonsilent_ranges)

def main():
    sfx_dir = "assets/audio/sfx"
    output_dir = "assets/audio/sfx/split"
    
    if not os.path.exists(sfx_dir):
        print(f"❌ Directory not found: {sfx_dir}")
        return
    
    # Find all combined audio files (long filenames with underscores)
    combined_files = [
        f for f in os.listdir(sfx_dir)
        if f.endswith('.wav') and len(f) > 50  # Long filenames = combined
    ]
    
    if not combined_files:
        print("✅ No combined audio files found!")
        return
    
    print(f"📦 Found {len(combined_files)} combined audio files")
    print("=" * 60)
    
    total_segments = 0
    for filename in combined_files:
        input_path = os.path.join(sfx_dir, filename)
        try:
            segments = split_audio_file(input_path, output_dir)
            total_segments += segments
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    print("=" * 60)
    print(f"\n✅ Split {len(combined_files)} files into {total_segments} segments")
    print(f"📁 Output directory: {output_dir}")
    print("\n📋 Next steps:")
    print("1. Review split files in assets/audio/sfx/split/")
    print("2. Rename files based on content (footstep.wav, chest_open.wav, etc.)")
    print("3. Move to appropriate locations (voice/ subfolder for murmurs)")
    print("4. Delete original combined files")

if __name__ == "__main__":
    main()
