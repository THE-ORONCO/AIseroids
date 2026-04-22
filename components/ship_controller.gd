@abstract
class_name ShipController 
extends Node


## Thrust power to apply to the ship. 
## Returns the current thrust input as float normalized between [0-1]
@abstract func thrust() -> float

## Turn thrust to apply to the ship. 
## Returns the current turn input as float normalized between [-1,-1]
@abstract func turn() -> float

## If the ship should shoot.
@abstract func shoot() -> bool
