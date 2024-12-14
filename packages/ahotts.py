import os
import subprocess
import tempfile

import sys


def main(text_to_synthesize: str, output_file: str, speed: int = 100,
         lang: str = "eu", tts_binary: str = "/usr/bin/AhoTTS/tts"):
    print(f"Text to synthesize: {text_to_synthesize}")
    print(f"Speed: {speed}")
    print(f"TTS Binary: {tts_binary}")

    # Use a temporary directory for intermediate files
    with tempfile.TemporaryDirectory() as tmp_dir:
        input_file = os.path.join(tmp_dir, "input.txt")
        # Save the text to a temporary input file with WINDOWS-1252 encoding
        with open(input_file, 'w', encoding='windows-1252') as txt_input:
            txt_input.write(text_to_synthesize)

        # Run TTS command
        args = [tts_binary, f"-Speed={speed}", f"-Lang={lang}", f"-InputFile={input_file}",
                f"-OutputFile={output_file}"]
        exit_code = subprocess.call(args)  # exit code 1 on success
        if not os.path.isfile(output_file):
            raise RuntimeError("TTS synth failed")

        print(f"Saved: {output_file}")
        return output_file


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python ahotts.py <speed> <tts_binary_path> <text>")
        sys.exit(1)

    text = sys.argv[1]
    outut_file = sys.argv[2]
    try:
        speed_arg = int(sys.argv[3])  # 25 - 300 - default 100
    except:
        speed_arg = 100
    main(text, outut_file, speed_arg)
