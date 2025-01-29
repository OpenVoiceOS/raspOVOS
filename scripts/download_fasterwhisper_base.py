from huggingface_hub import snapshot_download

repo_id = "Systran/faster-whisper-base"
file_path = snapshot_download(repo_id=repo_id)
print(f"Downloaded {repo_id}")
