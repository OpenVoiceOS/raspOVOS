from huggingface_hub import hf_hub_download

repo_id = "Jarbas/stt_es_citrinet_512_onnx"
subfolder = "onnx"

files = ["model.onnx", "tokenizer.spm", "preprocessor.ts"]
for file in files:
    file_path = hf_hub_download(repo_id=repo_id, filename=file, subfolder=subfolder)
    print(f"Downloaded {file} to {file_path}")
