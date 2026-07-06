class_name ShapeId
extends Object

enum EntityType {
	NOTHING	= 0,
	ASTEROID= 1,
	SHOT	= 5,
	SHIP	= 10,
	SELF	= 15,
	UNKNOWN	= 20,
}

# TODO add the missing things
static func identify(thing: Node2D, self_rid: RID) -> EntityType:
	match thing:
		var t when t == null:								return EntityType.NOTHING
		var t when t is Asteroid: 							return EntityType.ASTEROID
		var t when t is Shot:								return EntityType.SHOT
		var t when t is Ship && t.get_rid() == self_rid:	return EntityType.SELF
		var t when t is Ship:								return EntityType.SHIP
		var _t: 											return EntityType.UNKNOWN
		
