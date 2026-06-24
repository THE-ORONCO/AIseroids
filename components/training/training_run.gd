class_name TrainingRun
extends Resource

## Name of the experiment that was trained
@export var experiment_name: String

## the scenario used for the training
@export var scenario: Scenario
## number of horizontal spaces
@export_range(1, 10, 1, "or_greater") var horizontal_spaces: int = 3
## number of vertical spaces
@export_range(1, 10, 1, "or_greater") var vertical_spaces: int = 3
## the policies used for rewards
@export var policies: Array[RewardPolicy]

## fixed hyper params that cannot be changed between training runs
@export var hyper_params: HyperParams

@export_group("model params")
## where to save the trained model to TODO
@export var save_model_path: String
## where to save the onnx model to (relative to the models folder) TODO
@export var onnx_export_path: String
## how often snapshots of the model are saved TODO
@export_range(0, 100_000, 100, "or_greater") var save_checkpoint_frequency: int = 50000  
## how long to run the training for TODO
@export_range(0, 1_000_000_000,1000, "or_greater") var timesteps: int = 1_000_000

@export_group("variable learning params")
## if the learning rate should decrease linearly to 0 over the training run TODO
@export var linear_lr_schedule: bool = false 
## the initial learning rate TODO
@export_range(0.00001, 0.0003, 0.000001,"or_greater","or_less") var learning_rate: float = 0.0003 
## the clip range to use TODO
@export_range(0, 1, 0.001) var clip_range: float = 0.2
## the number of steps to collect information from the environment before model updates TODO
@export_range(0, 4096) var n_steps: int = 1024
## how often the agent can choose an action TODO
@export var action_repeat: int = 1
## minimum width of the space trained in TODO
@export_range(400, 5000, 1, "or_greater") var minimum_space_width: int = 1000
## maximum width of the space trained in TODO
@export_range(400, 5000, 1, "or_greater") var maximum_space_width: int = 1000
## minimum height of the space trained in TODO
@export_range(400, 5000, 1, "or_greater") var minimum_space_height: int = 1000
## maximum height of the space trained in TODO
@export_range(400, 5000, 1, "or_greater") var maximum_space_height: int = 1000
