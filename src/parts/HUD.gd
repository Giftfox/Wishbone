class_name HUD
extends Node2D

signal fade_finished(out)

var fade := 0

func _init():
	Global.gui = self

func _ready():
	#Stats.connect("screen_set",Callable(self,"on_screen_set"))
	$ScreenFade.visible = true
	$ScreenFade/AnimationPlayer.play("unfade")

func _process(delta):
	reposition()
	
	if !$ScreenFade/AnimationPlayer.is_playing():
		if fade == -1:
			emit_signal("fade_finished", true)
		if fade == 1:
			emit_signal("fade_finished", false)
		fade = 0
	
	if Stats.game_settings.size() > 0:
		$HUD/FPS.visible = true if Stats.game_settings[Stats.Settings.show_fps] == 1 else false
		$HUD/FPS.text = str(round(Engine.get_frames_per_second()))
		
	# debug
	#$HUD/FPS.visible = true
		
	#if Stats.game_settings.size() > 0:
	#	$FPS.visible = true if Stats.game_settings[Stats.Settings.show_fps] == 1 else false
	#	$FPS.text = str(round(Engine.get_frames_per_second()))
	#	$FPSBack.visible = $FPS.visible
	#	$FPSBack.text = $FPS.text

func reposition():
	var view = get_viewport()
	global_position = -view.canvas_transform.origin

func fade_screen(out = true):
	var fadenode = $ScreenFade/AnimationPlayer
	var current_pos = -1
	
	#if ($ScreenFade.modulate.a == 1.0 and out) or ($ScreenFade.modulate.a == 0.0 and !out):
	if ($ScreenFade.frame == 5 and out) or ($ScreenFade.frame == 0 and !out):
		emit_signal("fade_finished", out)
		fadenode.stop()
	else:
			
		if fadenode.is_playing():
			current_pos = fadenode.current_animation_position
		
		if out:
			fadenode.play("unfade", -1, -1, true)
			#fadenode.play("fade")
		else:
			fadenode.play("unfade")
			
		if current_pos >= 0:
			fadenode.seek(current_pos, true)
			
		if out:
			fade = -1
		else:
			fade = 1
