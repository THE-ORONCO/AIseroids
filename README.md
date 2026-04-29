inspiration for physics: https://novadrift.io/

## Getting Started
### 1. Setup the VENV
```shell
uv venv
uv sync
```

### 2. Activate the VENV
```shell
.venv/Scripts/activate
```

### 3. Train
```shell
python .\scripts\stable_baselines3_example.py --onnx_export_path=models/model.onnx --timesteps 300000
python3 ./scripts/stable_baselines3_example.py --onnx_export_path=models/model.onnx --timesteps 300000

```
