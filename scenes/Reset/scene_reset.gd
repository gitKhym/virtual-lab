extends CanvasLayer

func play_transition(type: String = 'dissolve') -> void:
	if type == 'dissolve':
		await transition_dissolve()
	else:
		await transition_clouds()

func transition_dissolve() -> void:
	$AnimationPlayer.play('dissolve')
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards('dissolve')
	await $AnimationPlayer.animation_finished

func transition_clouds() -> void:
	$AnimationPlayer.play('clouds_in')
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play('clouds_out')
	await $AnimationPlayer.animation_finished
