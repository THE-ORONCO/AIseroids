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

windows
```shell
python .\scripts\stable_baselines3_example.py --onnx_export_path=models/model.onnx --timesteps 300000
```

linux
```shell
python3 ./scripts/stable_baselines3_example.py --onnx_export_path=models/model.onnx --timesteps 300000
```


to persist the training model / allow for re-training later use 
```shell
python .\scripts\stable_baselines3_example.py --onnx_export_patth=modles/spaceshipV000/model.onnx --save_checkpoint_frequency=20000 --experiment_name=spaceshipV000 --experiment_dir=models/spaceshipV000
```

# Learning
## V001-V003
just tests with different policies

## V004 
- fixed policies
## V005
- continue training of V004
