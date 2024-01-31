#  SuperTux - A 2D, Open-Source Platformer Game licensed under GPL-3.0-or-later
#  Copyright (C) 2022 Alexander Small <alexsmudgy20@gmail.com>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 3
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


extends Area2D
var player = Global.player
var collectable = true
onready var destroy_timer = $DestroyTimer
onready var sfx = $SFX
onready var coinCollision = $CollisionShape2DCoin
onready var animSprite = $AnimatedSpriteCoin
onready var blockTemp = $BonusBlockTemp
onready var blockTempCollision = $BonusBlockTemp/BonusBlock/CollisionShape2D
onready var blockTempHitboxCollision = $BonusBlockTemp/BonusBlock/Hitbox/CollisionShape2D
onready var blockTempAboveCollision = $BonusBlockTemp/BonusBlock/AboveHitbox/CollisionShape2D
func _on_Coin_body_entered(body):
	if body.is_in_group("players"):
		body.hurt(self)
		collect()

func collect():
	if !collectable: return
	if(Scoreboard.coins > 0):
		Scoreboard.coins -= 5
		if(Scoreboard.coins  < 0):
			Scoreboard.coins = 0
	visible = false
	sfx.play("Coin")
	destroy_timer.start()
	collectable = false

func _on_DestroyTimer_timeout():
	call_deferred("queue_free")
	
func _physics_process(delta):
	var player = Global.player
	
	if is_instance_valid(player) and (player.invincible == true) and (player.invincible_type == player.invincible_types.STAR):
		
		#Make coin invisible and intangible
		coinCollision.disabled = true
		animSprite.visible = false
		#Make block visible and tangible
		blockTemp.visible = true
		blockTempCollision.disabled = false
		blockTempHitboxCollision.disabled = false
		blockTempAboveCollision.disabled = false
		if(player.invincible_timer.time_left <= 3.0):
			blockTemp.modulate.a = (player.invincible_timer.time_left/3.0)
			animSprite.visible = true
			animSprite.modulate.a = (1.0 - (blockTemp.modulate.a)/2)
		else:
			blockTemp.modulate.a = 1
			animSprite.modulate.a = 1
	else:
		#Make coin tangible and visible
		coinCollision.disabled = false
		animSprite.visible = true
		animSprite.modulate.a = 1
		#Make block intangible and invisible
		blockTemp.visible = false
		blockTempCollision.disabled = true
		blockTempHitboxCollision.disabled = true
		blockTempAboveCollision.disabled = true
		
