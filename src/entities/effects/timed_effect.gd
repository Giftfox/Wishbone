extends CPUParticles2D

var prepped := false

func prep():
	emitting = true
	prepped = true

func _process(delta):
	if prepped and !emitting:
		queue_free()
