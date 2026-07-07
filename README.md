# [AI]steroids

A simple asteroid like game that contains AI adversaries.

## Getting Started
### 1. Setup the VENV
```shell
uv venv
uv sync
```

### 2. Activate the VENV
windows
```shell
.venv/Scripts/activate
```

linux
```shell
source .venv/bin/activate
```

### 3. Train

The training commands can be generated for you in the main menu. After definin the training run in the UI just click on the `Copy CMD to Clipboard` button to copy a command that starts the server with the parameters that were just configured. 

#### start training
windows
```shell
python .\scripts\stable_baselines3_example.py --onnx_export_path=models/model.onnx --timesteps 300000
```

linux
```shell
python3 ./scripts/stable_baselines3_example.py --onnx_export_path=models/model.onnx --timesteps 300000
```

#### train with checkpoints
to persist the training model / allow for re-training later use 
windows
```shell
python .\scripts\stable_baselines3_example.py --save_checkpoint_frequency=50000 --experiment_name=spaceshipV000
```

linux
```shell
python3 ./scripts/stable_baselines3_example.py --save_checkpoint_frequency=50000 --experiment_name=spaceshipV000 
```

#### continue from checkpoint
The training can be continued from checkpoints or old models. This allows for trying again at critical inflection points
during the training or to improve a model further.

windows
```shell
python .\scripts\stable_baselines3_example.py  --save_checkpoint_frequency=50000 --experiment_name=spaceshipV000 --resume_model_path=logs/sb3/experiment_checkpoints/experiment_1000000_steps.zip
```

linux
```shell
python3 ./scripts/stable_baselines3_example.py  --save_checkpoint_frequency=50000 --experiment_name=spaceshipV000 --resume_model_path=logs/sb3/experiment_checkpoints/experiment_1000000_steps.zip
```

### 4. View the progress using tensorboard
run
```shell
tensorboard --logdir logs/sb3
```
then open [`http://localhost:6008/`](http://localhost:6008/)

### 5. Refine further
the script has many options to modify learning behaviour
```
usage: stable_baselines3_example.py [-h] [--env_path ENV_PATH] [--experiment_dir EXPERIMENT_DIR] [--experiment_name EXPERIMENT_NAME] [--seed SEED] [--resume_model_path RESUME_MODEL_PATH] [--save_model_path SAVE_MODEL_PATH]
									[--save_checkpoint_frequency SAVE_CHECKPOINT_FREQUENCY] [--onnx_export_path ONNX_EXPORT_PATH] [--timesteps TIMESTEPS] [--inference] [--linear_lr_schedule] [--viz] [--speedup SPEEDUP] [--n_parallel N_PARALLEL]
									[--learning_rate LEARNING_RATE] [--clip_range CLIP_RANGE] [--n_steps N_STEPS]

options:
  -h, --help            show this help message and exit
  --env_path ENV_PATH   The Godot binary to use, do not include for in editor training
  --experiment_dir EXPERIMENT_DIR
						The name of the experiment directory, in which the tensorboard logs and checkpoints (if enabled) are getting stored.
  --experiment_name EXPERIMENT_NAME
						The name of the experiment, which will be displayed in tensorboard and for checkpoint directory and name (if enabled).
  --seed SEED           seed of the experiment
  --resume_model_path RESUME_MODEL_PATH
						The path to a model file previously saved using --save_model_path or a checkpoint saved using --save_checkpoints_frequency. Use this to resume training or infer from a saved model.
  --save_model_path SAVE_MODEL_PATH
						The path to use for saving the trained sb3 model after training is complete. Saved model can be used later to resume training. Extension will be set to .zip
  --save_checkpoint_frequency SAVE_CHECKPOINT_FREQUENCY
						If set, will save checkpoints every 'frequency' environment steps. Requires a unique --experiment_name or --experiment_dir for each run. Does not need --save_model_path to be set.
  --onnx_export_path ONNX_EXPORT_PATH
						If included, will export onnx file after training to the path specified.
  --timesteps TIMESTEPS
						The number of environment steps to train for, default is 1_000_000. If resuming from a saved model, it will continue training for this amount of steps from the saved state without counting previously trained steps
  --inference           Instead of training, it will run inference on a loaded model for --timesteps steps. Requires --resume_model_path to be set.
  --linear_lr_schedule  Use a linear LR schedule for training. If set, learning rate will decrease until it reaches 0 at --timestepsvalue. Note: On resuming training, the schedule will reset. If disabled, constant LR will be used.
  --viz                 If set, the simulation will be displayed in a window during training. Otherwise training will run without rendering the simulation. This setting does not apply to in-editor training.
  --speedup SPEEDUP     Whether to speed up the physics in the env
  --n_parallel N_PARALLEL
						How many instances of the environment executable to launch - requires --env_path to be set if > 1.
  --learning_rate LEARNING_RATE
						Optimizer learning rate for policy updates (typical: 1e-5–3e-4). Lower = smaller parameter steps and more stable but slower training; raise cautiously with smaller clip-range or larger batch size.
  --clip_range CLIP_RANGE
						PPO clip range ε for the probability-ratio (r in [1-ε,1+ε]). Smaller values (0.05–0.1) make updates more conservative; larger values (0.15–0.3) allow bigger policy changes. Monitor approx_kl and clip_fraction when tuning.
  --n_steps N_STEPS     Number of environment steps collected per environment between updates. Total rollout size = n_steps * n_envs. Larger n_steps → bigger on-policy batch, lower gradient variance, higher memory/latency; smaller n_steps → more frequent updates and
						higher variance. Common defaults: 128 or 256 for vectorized envs.
```

# Results
The results were recorded in video recordings in [./recordings](recordings):
- [recordings/ship-1.mp4](recordings/ship-1.mp4): `ship-1`
- [recordings/ship-2.mp4](recordings/ship-2.mp4): `ship-2`
- [recordings/ship-3.mp4](recordings/ship-3.mp4): `ship-3`
- [recordings/ship-4.mp4](recordings/ship-4.mp4): `ship-4`
- [recordings/ship-5.mp4](recordings/ship-5.mp4): `ship-5`

Each version of the agent can also be found in the [./models](models) directory and also directly experienced through 
clicking on the specific entry in the main menu.

