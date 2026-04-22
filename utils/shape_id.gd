class_name ShapeId
extends Object

enum EntityType {
	NOTHING	= 0,
	ASTEROID= 1,
	SHIP	= 2,
	SHOT	= 3,
	UNKNOWN	= 99,
}

# TODO add the missing things
static func identify(thing: Node2D) -> EntityType:
	match thing:
		var t when t == null:	return EntityType.NOTHING
		var t when t is Ship:	return EntityType.SHIP
		var t when t is Shot:	return EntityType.SHOT
		var t: 					return EntityType.UNKNOWN
		
