class_name HyperParams
extends Resource

## Seed of the experiment TODO
@export var start_seed: int = randi()
## history size TODO 
@export_range(0, 10, 1) var history_size: int = 5
## the number of ticks between history states TODO
@export_range(1, 10, 1) var history_skip: int = 1
## architecture of the hidden model layers TODO
@export var arch: Array[int] = [64,64]
