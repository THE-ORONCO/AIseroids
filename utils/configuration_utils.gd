class_name ConfigUtils
extends Object

static func instantiate_then_configure(scene: PackedScene, config_params: Resource) -> Variant:
	var thing := scene.instantiate()
	# TODO find a better solution that just calling this next frame
	#thing.configure.call_deferred(config_params)
	return thing
