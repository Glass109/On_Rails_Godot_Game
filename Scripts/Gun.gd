extends Node3D

@onready var animationplayer: AnimationPlayer = $AnimationPlayer
@onready var fire_rate_timer: Timer = $Timer

var bullets_left : int = 30
func _on_player_gun_shooted():
	if bullets_left > 0:
		animationplayer.play("Gunshot")
		bullets_left -= 1
		print(bullets_left)
		



func _input(event):
		if Input.is_action_just_pressed("Shoot"):
			_on_player_gun_shooted()
			
		if Input.is_action_just_pressed("Reload"):
			print("Reloading")
			animationplayer.stop()
			animationplayer.play("Reloading")
			bullets_left = 30


