class_name S_Ship
extends Resource


## a cool name for the ship
@export var name: String

## the thing that controls the ship
@export var mode: ControlMode

## the team the Ship is in
@export var team: S_Team

## if the SFX should be muted
@export var mute := false

## if to show debug graphics
@export var show_debug := false

@export_group("stats")
## max health of the ship
@export_range(0, 20) var max_health: int = 5
@export_range(0.01, 10.) var mass: float = 1.
@export var muzzle: S_Muzzle = S_Muzzle.new()


@export_subgroup("movement")
@export_range(1., 3000., 1., "or_greater") 	var thruster_power: float 	= 500.
@export_range(1., 3000., 1., "or_greater") 	var strafe_power: float 	= 500.
@export_range(.1, 10., 1., "or_greater") 	var rotation_speed: float 	= 6.
@export_range(1., 5000., 1., "or_greater") 	var max_velocity: float		= 1000.
@export_range(1., 5000., 1., "or_greater") 	var max_force: float 		= 1000.
