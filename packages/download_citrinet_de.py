from huggingface_hub import hf_hub_download

repo_id = "neongeckocom/stt_de_citrinet_512_gamma_0_25"
subfolder = "onnx"

files = ["model.onnx", "tokenizer.spm", "preprocessor.ts"]
for file in files:
    file_path = hf_hub_download(repo_id=repo_id, filename=file, subfolder=subfolder)
    print(f"Downloaded {file} to {file_path}")
