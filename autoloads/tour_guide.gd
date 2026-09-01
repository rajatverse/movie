extends Node

var step = 0
var timer = 0.0

func _process(delta: float) -> void:
	timer += delta
	
	if step == 0 and timer > 2.0:
		if get_tree().current_scene.name == "MainMenu":
			take_screenshot("01_main_menu.png")
			get_tree().change_scene_to_file("res://scenes/menu/studio_setup.tscn")
			step += 1
			timer = 0.0
			
	elif step == 1 and timer > 2.0:
		if get_tree().current_scene.name == "StudioSetup":
			var setup = get_tree().current_scene
			GameData.studio_name = "Rajat Studios"
			GameData.founder_name = "Rajat"
			GameData.city = "Mumbai"
			take_screenshot("02_studio_setup.png")
			get_tree().change_scene_to_file("res://scenes/menu/studio_confirmation.tscn")
			step += 1
			timer = 0.0
			
	elif step == 2 and timer > 2.0:
		if get_tree().current_scene.name == "StudioConfirmation":
			take_screenshot("03_confirmation.png")
			SaveManager.save_game()
			get_tree().change_scene_to_file("res://scenes/menu/intro.tscn")
			step += 1
			timer = 0.0
			
	elif step == 3 and timer > 2.0:
		if get_tree().current_scene.name == "Intro":
			get_tree().change_scene_to_file("res://scenes/world/studio_world.tscn")
			step += 1
			timer = 0.0
			
	elif step == 4 and timer > 2.0:
		if get_tree().current_scene.name == "StudioWorld":
			take_screenshot("04_initial_studio.png")
			# Hire a staff to show them
			var s = StaffData.new()
			s.staff_name = "Alex Mercer"
			s.primary_skill = "graphics"
			s.skill_level = 15.0
			StaffManager.hire_staff(s)
			step += 1
			timer = 0.0
			
	elif step == 5 and timer > 2.0:
		take_screenshot("05_studio_with_staff.png")
		var hud = get_tree().current_scene.hud
		hud._on_movies_pressed()
		step += 1
		timer = 0.0
		
	elif step == 6 and timer > 2.0:
		take_screenshot("06_movies_overlay.png")
		var hud = get_tree().current_scene.hud
		hud.overlay_container.get_child(0).queue_free()
		hud._on_staff_pressed()
		step += 1
		timer = 0.0
		
	elif step == 7 and timer > 2.0:
		take_screenshot("07_staff_overlay.png")
		print("TOUR COMPLETE")
		get_tree().quit(0)

func take_screenshot(filename: String) -> void:
	var img = get_viewport().get_texture().get_image()
	var path = "C:/Users/praja/.gemini/antigravity-ide/brain/438d2a8f-602d-4256-865d-e595cdf0f9b7/" + filename
	img.save_png(path)
	print("Saved screenshot: " + path)
