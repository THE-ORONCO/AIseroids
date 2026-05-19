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
windows
```shell
python .\scripts\stable_baselines3_example.py --save_checkpoint_frequency=20000 --experiment_name=spaceshipV000
```

linux
```shell
python ./scripts/stable_baselines3_example.py --save_checkpoint_frequency=20000 --experiment_name=spaceshipV000 
```

## 4. View the progress using tensorboard
run
```shell
tensorboard --logdir logs/sb3
```
then open [`http://localhost:6008/`](http://localhost:6008/)

# Learning
## V001-V003
just tests with different policies

## V004 
- fixed policies
## V005
- continue training of V004
