extends Control


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_info_pressed():
	$OptionsMenu.show()
	$MarginContainer.hide()
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		$OptionsMenu.hide()
		$MarginContainer.show()
