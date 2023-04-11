extends Node2D

onready var grumbel = $Grumbel
onready var anim_player = $AnimationPlayer
onready var statue = $Statue
onready var sfx = $SFX
onready var ambience = $Ambience
onready var evil_text = $EvilText/Control
onready var evil_text_label = $EvilText/Control/Label
onready var evil_text_static = $EvilText/Control/Static
onready var rng = RandomNumberGenerator.new()

var evil_messages = [
	"USELESS",
	"REDUNDANT",
	"DEFECTIVE",
	"NEEDS DEPRECATING",
	"UNNECESSARY",
	"TRASH",
	"KILL",
	"MESS",
	"UGLY",
	"WORTHLESS",
	"LIFELESS",
	"STALE",
	"DULL",
	"Tux.kill(true)",
]

func _ready():
	grumbel.connect("fake_death", self, "phase_two_transition")
	grumbel.connect("phase_two", self, "phase_two")
	grumbel.connect("defeated", self, "defeated")
	grumbel.connect("dying", self, "dying")
	grumbel.connect("hurt", self, "hurt")
	
	yield(Global, "level_ready")
	
	if Scoreboard.number_of_deaths > 0 or grumbel.phase == 2 or grumbel.enabled:
		spawn_grumbel(0.1)
	else:
		statue_intro()

func spawn_grumbel(wait_time = 1):
	grumbel.enable(true, wait_time)
	statue.hide()
	yield(get_tree().create_timer(wait_time, false), "timeout")
	if grumbel.phase == 2:
		anim_player.play("phase_two")
	else: Music.play("Prophecy")

func statue_intro():
	yield(get_tree().create_timer(1, false), "timeout")
	
	sfx.play("Static")
	sfx.play("Glitch2")
	yield(call("evil_text_message", "UNNECESSARY", 0.6), "completed")
	sfx.stop("Glitch2")
	sfx.stop("Static")
	
	yield(get_tree().create_timer(0.3, false), "timeout")
	
	sfx.play("Static")
	sfx.play("Glitch4")
	yield(call("evil_text_message", "USELESS", 0.05), "completed")
	sfx.stop("Glitch4")
	sfx.stop("Static")
	
	yield(get_tree().create_timer(0.3, false), "timeout")
	
	sfx.play("Static")
	sfx.play("Glitch3")
	yield(call("evil_text_message", "REDUNDANT", 0.05, Color(1,0.5,0), Color(1,0.5,0.5,0.2)), "completed")
	sfx.stop("Static")
	sfx.stop("Glitch3")
	yield(get_tree().create_timer(0.3, false), "timeout")
	
	sfx.play("Static")
	sfx.play("Glitch1")
	yield(call("evil_text_message", "WORTHLESS", 0.05, Color(1,1,1), Color(1,0,0,0.2)), "completed")
	sfx.stop("Static")
	sfx.stop("Glitch1")
	
	yield(get_tree().create_timer(0.6, false), "timeout")
	
	var timer = get_tree().create_timer(2, false)
	var shake = 0.05
	sfx.play("Rumbling")
	sfx.play("Rumbling2")
	while timer.time_left > 0:
		Global.camera_shake(shake * 2, 0.5)
		shake += 0.1
		statue.offset.x = sin(shake * shake) * shake
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
	
	statue.offset.x = 0
	anim_player.play("flash_in")
	
	while anim_player.is_playing():
		Global.camera_shake(shake * 2, 0.5)
		shake += 1
		statue.offset.x = sin(shake * shake) * shake
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
	
	sfx.play("Explosion")
	sfx.play("Explosion2")
	sfx.play("Explosion3")
	
	sfx.stop("Rumbling")
	sfx.stop("Rumbling2")
	
	yield(get_tree().create_timer(2, false), "timeout")
	
	spawn_grumbel(3)
	anim_player.play("flash_out")
	yield(anim_player, "animation_finished")
	
	yield(get_tree().create_timer(1, false), "timeout")
	
	sfx.play("Glitch1")
	sfx.play("Static")
	yield(call("evil_text_message", "I WILL DEPRECATE YOU", 1, Color(1,0,0), Color(1,0,0,0.2)), "completed")
	sfx.stop("Glitch1")
	sfx.stop("Static")

func phase_two_transition():
	ambience.stop()
	anim_player.play("phase_two_transition")
	Music.pitch_slide_down()

func phase_two():
	anim_player.play("phase_two")
	Music.play("Prophecy", false, 30.74)

func defeated():
	ambience.stop()
	pause_mode = Node.PAUSE_MODE_PROCESS
	anim_player.play("defeated")

func hurt():
	if grumbel.phase == 2:
		rng.randomize()
		
		# Get a random evil message from the evil message array
		var message = rng.randi_range(0, evil_messages.size() - 1)
		message = evil_messages[message]
		
		var sound = "Glitch" + str(rng.randi_range(1,3))
		
		sfx.play("Static")
		sfx.play(sound)
		yield(call("evil_text_message", message, 0.1, Color(1,1,1), Color(1,0,0,0.25)), "completed")
		sfx.stop(sound)
		sfx.stop("Static")

func dying():
	anim_player.play("dying")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dying":
		Global.level_completed()

func evil_text_message(message_text : String, message_time : float, text_colour : Color = Color(1,1,0), static_color : Color = Color(1,1,1,0.2)):
	if get_tree().paused: return
	
	AudioServer.set_bus_mute(3, true)
	
	var p = pause_mode
	var can_pause = Global.can_pause
	
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	Global.can_pause = false
	
	evil_text_label.modulate = text_colour
	evil_text_static.modulate = static_color
	evil_text_label.text = message_text
	evil_text.show()
	
	yield(get_tree().create_timer(message_time), "timeout")
	
	evil_text.hide()
	
	pause_mode = p
	
	AudioServer.set_bus_mute(3, false)
	
	get_tree().paused = false
	Global.can_pause = can_pause
