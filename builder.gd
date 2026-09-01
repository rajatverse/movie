@tool
extends SceneTree

func _init():
	print("Building improved scenes...")
	
	# --------------------------------------------------------------------------
	# 1. STAFF CHARACTER
	# --------------------------------------------------------------------------
	var staff_root = Node3D.new()
	staff_root.name = "StaffCharacter"
	var staff_script = load("res://scenes/world/characters/staff_character.gd")
	staff_root.set_script(staff_script)
	
	# Material definitions
	var mat_skin = StandardMaterial3D.new()
	mat_skin.albedo_color = Color(0.9, 0.75, 0.65)
	var mat_hair = StandardMaterial3D.new()
	mat_hair.albedo_color = Color(0.2, 0.1, 0.05)
	var mat_shirt = StandardMaterial3D.new()
	mat_shirt.albedo_color = Color(0.2, 0.4, 0.8)
	var mat_pants = StandardMaterial3D.new()
	mat_pants.albedo_color = Color(0.15, 0.15, 0.15)
	var mat_shoes = StandardMaterial3D.new()
	mat_shoes.albedo_color = Color(0.1, 0.1, 0.1)
	
	var csg_char = CSGCombiner3D.new()
	csg_char.name = "Body"
	staff_root.add_child(csg_char)
	csg_char.owner = staff_root
	
	# Torso
	var torso = CSGBox3D.new()
	torso.size = Vector3(0.4, 0.5, 0.25)
	torso.position = Vector3(0, 0.85, 0)
	torso.material = mat_shirt
	csg_char.add_child(torso)
	torso.owner = staff_root
	
	# Head
	var head = CSGBox3D.new()
	head.size = Vector3(0.3, 0.3, 0.3)
	head.position = Vector3(0, 1.3, 0)
	head.material = mat_skin
	csg_char.add_child(head)
	head.owner = staff_root
	
	# Hair
	var hair = CSGBox3D.new()
	hair.size = Vector3(0.32, 0.1, 0.32)
	hair.position = Vector3(0, 1.45, 0)
	hair.material = mat_hair
	csg_char.add_child(hair)
	hair.owner = staff_root
	
	# Arms
	var arm_l = CSGBox3D.new()
	arm_l.size = Vector3(0.15, 0.45, 0.15)
	arm_l.position = Vector3(-0.3, 0.85, 0)
	arm_l.material = mat_skin
	csg_char.add_child(arm_l)
	arm_l.owner = staff_root
	
	var arm_r = CSGBox3D.new()
	arm_r.size = Vector3(0.15, 0.45, 0.15)
	arm_r.position = Vector3(0.3, 0.85, 0)
	arm_r.material = mat_skin
	csg_char.add_child(arm_r)
	arm_r.owner = staff_root
	
	# Legs
	var leg_l = CSGBox3D.new()
	leg_l.size = Vector3(0.18, 0.5, 0.18)
	leg_l.position = Vector3(-0.1, 0.35, 0)
	leg_l.material = mat_pants
	csg_char.add_child(leg_l)
	leg_l.owner = staff_root
	
	var leg_r = CSGBox3D.new()
	leg_r.size = Vector3(0.18, 0.5, 0.18)
	leg_r.position = Vector3(0.1, 0.35, 0)
	leg_r.material = mat_pants
	csg_char.add_child(leg_r)
	leg_r.owner = staff_root
	
	# Shoes
	var shoe_l = CSGBox3D.new()
	shoe_l.size = Vector3(0.18, 0.1, 0.22)
	shoe_l.position = Vector3(-0.1, 0.05, 0.02)
	shoe_l.material = mat_shoes
	csg_char.add_child(shoe_l)
	shoe_l.owner = staff_root
	
	var shoe_r = CSGBox3D.new()
	shoe_r.size = Vector3(0.18, 0.1, 0.22)
	shoe_r.position = Vector3(0.1, 0.05, 0.02)
	shoe_r.material = mat_shoes
	csg_char.add_child(shoe_r)
	shoe_r.owner = staff_root
	
	var staff_pack = PackedScene.new()
	staff_pack.pack(staff_root)
	ResourceSaver.save(staff_pack, "res://scenes/world/characters/staff_character.tscn")
	print("Saved staff_character.tscn")
	
	
	# --------------------------------------------------------------------------
	# 2. STUDIO WORLD
	# --------------------------------------------------------------------------
	var world_root = Node3D.new()
	world_root.name = "StudioWorld"
	world_root.set_script(load("res://scenes/world/studio_world.gd"))
	
	var light = DirectionalLight3D.new()
	light.name = "DirectionalLight3D"
	light.transform.basis = Basis().rotated(Vector3(1,0,0), deg_to_rad(-45)).rotated(Vector3(0,1,0), deg_to_rad(-45))
	light.shadow_enabled = true
	world_root.add_child(light)
	light.owner = world_root
	
	var cam_pivot = Node3D.new()
	cam_pivot.name = "CameraPivot"
	# Isometric angle
	cam_pivot.transform.basis = Basis().rotated(Vector3(1,0,0), deg_to_rad(-35)).rotated(Vector3(0,1,0), deg_to_rad(45))
	world_root.add_child(cam_pivot)
	cam_pivot.owner = world_root
	
	var cam = Camera3D.new()
	cam.name = "Camera3D"
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 12.0
	cam.position = Vector3(0, 0, 15)
	cam_pivot.add_child(cam)
	cam.owner = world_root
	
	# Env
	var env_node = Node3D.new()
	env_node.name = "Environment"
	world_root.add_child(env_node)
	env_node.owner = world_root
	
	var mat_floor = StandardMaterial3D.new()
	mat_floor.albedo_color = Color(0.7, 0.6, 0.5) # Wooden floor
	var floor_csg = CSGBox3D.new()
	floor_csg.name = "Floor"
	floor_csg.size = Vector3(12, 0.2, 12)
	floor_csg.position = Vector3(0, -0.1, 0)
	floor_csg.material = mat_floor
	env_node.add_child(floor_csg)
	floor_csg.owner = world_root
	
	var mat_wall = StandardMaterial3D.new()
	mat_wall.albedo_color = Color(0.85, 0.9, 0.95)
	
	var wall_n = CSGBox3D.new()
	wall_n.name = "WallN"
	wall_n.size = Vector3(12, 4, 0.4)
	wall_n.position = Vector3(0, 2, -5.8)
	wall_n.material = mat_wall
	env_node.add_child(wall_n)
	wall_n.owner = world_root
	
	var wall_w = CSGBox3D.new()
	wall_w.name = "WallW"
	wall_w.size = Vector3(0.4, 4, 12)
	wall_w.position = Vector3(-5.8, 2, 0)
	wall_w.material = mat_wall
	env_node.add_child(wall_w)
	wall_w.owner = world_root
	
	var furn_node = Node3D.new()
	furn_node.name = "Furniture"
	world_root.add_child(furn_node)
	furn_node.owner = world_root
	
	# Helper for Desk
	var desk_combiner = CSGCombiner3D.new()
	desk_combiner.name = "Desk"
	desk_combiner.position = Vector3(-1, 0, -2)
	furn_node.add_child(desk_combiner)
	desk_combiner.owner = world_root
	
	var mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.4, 0.25, 0.15)
	var mat_metal = StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.3, 0.3, 0.3)
	
	var tabletop = CSGBox3D.new()
	tabletop.size = Vector3(2.4, 0.1, 1.2)
	tabletop.position = Vector3(0, 0.9, 0)
	tabletop.material = mat_wood
	desk_combiner.add_child(tabletop)
	tabletop.owner = world_root
	
	for lx in [-1.1, 1.1]:
		for lz in [-0.5, 0.5]:
			var leg = CSGBox3D.new()
			leg.size = Vector3(0.1, 0.9, 0.1)
			leg.position = Vector3(lx, 0.45, lz)
			leg.material = mat_metal
			desk_combiner.add_child(leg)
			leg.owner = world_root
			
	var drawers = CSGBox3D.new()
	drawers.size = Vector3(0.6, 0.8, 1.1)
	drawers.position = Vector3(0.8, 0.4, 0)
	drawers.material = mat_wood
	desk_combiner.add_child(drawers)
	drawers.owner = world_root
	
	# Computer
	var mat_black = StandardMaterial3D.new()
	mat_black.albedo_color = Color(0.1, 0.1, 0.1)
	var mat_screen = StandardMaterial3D.new()
	mat_screen.albedo_color = Color(0.2, 0.5, 0.8)
	
	var monitor = CSGBox3D.new()
	monitor.size = Vector3(0.8, 0.5, 0.05)
	monitor.position = Vector3(-0.4, 1.3, -0.2)
	monitor.material = mat_black
	desk_combiner.add_child(monitor)
	monitor.owner = world_root
	
	var screen = CSGBox3D.new()
	screen.size = Vector3(0.75, 0.45, 0.06)
	screen.position = Vector3(-0.4, 1.3, -0.19)
	screen.material = mat_screen
	desk_combiner.add_child(screen)
	screen.owner = world_root
	
	var stand = CSGBox3D.new()
	stand.size = Vector3(0.2, 0.3, 0.1)
	stand.position = Vector3(-0.4, 1.05, -0.3)
	stand.material = mat_black
	desk_combiner.add_child(stand)
	stand.owner = world_root
	
	var keyboard = CSGBox3D.new()
	keyboard.size = Vector3(0.6, 0.05, 0.2)
	keyboard.position = Vector3(-0.4, 0.97, 0.3)
	keyboard.material = mat_black
	desk_combiner.add_child(keyboard)
	keyboard.owner = world_root
	
	# Chair
	var chair = CSGCombiner3D.new()
	chair.name = "Chair"
	chair.position = Vector3(-0.4, 0, 0.8)
	desk_combiner.add_child(chair)
	chair.owner = world_root
	
	var seat = CSGBox3D.new()
	seat.size = Vector3(0.6, 0.1, 0.6)
	seat.position = Vector3(0, 0.5, 0)
	seat.material = mat_black
	chair.add_child(seat)
	seat.owner = world_root
	
	var back = CSGBox3D.new()
	back.size = Vector3(0.6, 0.6, 0.1)
	back.position = Vector3(0, 0.85, 0.25)
	back.material = mat_black
	chair.add_child(back)
	back.owner = world_root
	
	var cleg = CSGBox3D.new()
	cleg.size = Vector3(0.1, 0.5, 0.1)
	cleg.position = Vector3(0, 0.25, 0)
	cleg.material = mat_metal
	chair.add_child(cleg)
	cleg.owner = world_root
	
	var cbase = CSGBox3D.new()
	cbase.size = Vector3(0.5, 0.05, 0.5)
	cbase.position = Vector3(0, 0.02, 0)
	cbase.material = mat_metal
	chair.add_child(cbase)
	cbase.owner = world_root
	
	# Meeting Table
	var meeting = CSGCombiner3D.new()
	meeting.name = "MeetingTable"
	meeting.position = Vector3(2, 0, 2)
	furn_node.add_child(meeting)
	meeting.owner = world_root
	
	var mtop = CSGCylinder3D.new()
	mtop.radius = 1.2
	mtop.height = 0.1
	mtop.position = Vector3(0, 0.8, 0)
	mtop.material = mat_wood
	meeting.add_child(mtop)
	mtop.owner = world_root
	
	var mleg = CSGCylinder3D.new()
	mleg.radius = 0.2
	mleg.height = 0.8
	mleg.position = Vector3(0, 0.4, 0)
	mleg.material = mat_metal
	meeting.add_child(mleg)
	mleg.owner = world_root
	
	# Reception
	var rec = CSGCombiner3D.new()
	rec.name = "Reception"
	rec.position = Vector3(-3, 0, 4)
	furn_node.add_child(rec)
	rec.owner = world_root
	
	var mat_rec = StandardMaterial3D.new()
	mat_rec.albedo_color = Color(0.8, 0.8, 0.85)
	var rfront = CSGBox3D.new()
	rfront.size = Vector3(2.5, 1.2, 0.3)
	rfront.position = Vector3(0, 0.6, 0)
	rfront.material = mat_rec
	rec.add_child(rfront)
	rfront.owner = world_root
	
	var rside = CSGBox3D.new()
	rside.size = Vector3(0.3, 1.2, 1.5)
	rside.position = Vector3(-1.1, 0.6, -0.6)
	rside.material = mat_rec
	rec.add_child(rside)
	rside.owner = world_root
	
	var rtop = CSGBox3D.new()
	rtop.size = Vector3(2.6, 0.05, 0.4)
	rtop.position = Vector3(0, 1.2, 0)
	rtop.material = mat_wood
	rec.add_child(rtop)
	rtop.owner = world_root
	
	# Plant
	var plant = CSGCombiner3D.new()
	plant.name = "Plant"
	plant.position = Vector3(4, 0, -4)
	furn_node.add_child(plant)
	plant.owner = world_root
	
	var mat_pot = StandardMaterial3D.new()
	mat_pot.albedo_color = Color(0.8, 0.4, 0.2)
	var pot = CSGCylinder3D.new()
	pot.radius = 0.4
	pot.height = 0.6
	pot.position = Vector3(0, 0.3, 0)
	pot.material = mat_pot
	plant.add_child(pot)
	pot.owner = world_root
	
	var mat_leaf = StandardMaterial3D.new()
	mat_leaf.albedo_color = Color(0.2, 0.6, 0.2)
	var leaves1 = CSGBox3D.new()
	leaves1.size = Vector3(0.8, 0.8, 0.8)
	leaves1.position = Vector3(0, 1.0, 0)
	leaves1.material = mat_leaf
	plant.add_child(leaves1)
	leaves1.owner = world_root
	
	var leaves2 = CSGBox3D.new()
	leaves2.size = Vector3(0.6, 0.6, 0.6)
	leaves2.position = Vector3(0.2, 1.4, -0.1)
	leaves2.material = mat_leaf
	plant.add_child(leaves2)
	leaves2.owner = world_root
	
	# Production Board
	var pboard = CSGCombiner3D.new()
	pboard.name = "ProductionBoard"
	pboard.position = Vector3(-5.6, 2, -2)
	furn_node.add_child(pboard)
	pboard.owner = world_root
	
	var mat_board = StandardMaterial3D.new()
	mat_board.albedo_color = Color(0.9, 0.9, 0.9)
	var board_bg = CSGBox3D.new()
	board_bg.size = Vector3(0.1, 1.5, 2.5)
	board_bg.material = mat_board
	pboard.add_child(board_bg)
	board_bg.owner = world_root
	
	var frame = CSGBox3D.new()
	frame.size = Vector3(0.12, 1.6, 2.6)
	frame.material = mat_wood
	pboard.add_child(frame)
	frame.owner = world_root
	
	var hole = CSGBox3D.new()
	hole.size = Vector3(0.15, 1.5, 2.5)
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	pboard.add_child(hole)
	hole.owner = world_root
	
	var mat_note1 = StandardMaterial3D.new()
	mat_note1.albedo_color = Color(1, 1, 0.5)
	var note1 = CSGBox3D.new()
	note1.size = Vector3(0.02, 0.2, 0.2)
	note1.position = Vector3(0.05, 0.4, 0.8)
	note1.material = mat_note1
	pboard.add_child(note1)
	note1.owner = world_root
	
	# Movie Poster
	var poster = CSGBox3D.new()
	poster.name = "MoviePoster"
	poster.size = Vector3(1.5, 2, 0.05)
	poster.position = Vector3(2, 2, -5.75)
	poster.material = mat_screen
	furn_node.add_child(poster)
	poster.owner = world_root
	
	# Lightstand (Film Equipment)
	var lequip = CSGCombiner3D.new()
	lequip.name = "Lightstand"
	lequip.position = Vector3(4.5, 0, 1)
	furn_node.add_child(lequip)
	lequip.owner = world_root
	
	var lbase = CSGCylinder3D.new()
	lbase.radius = 0.05
	lbase.height = 2.0
	lbase.position = Vector3(0, 1.0, 0)
	lbase.material = mat_metal
	lequip.add_child(lbase)
	lbase.owner = world_root
	
	var lhead = CSGBox3D.new()
	lhead.size = Vector3(0.5, 0.4, 0.2)
	lhead.position = Vector3(0, 2.0, 0)
	lhead.material = mat_black
	lequip.add_child(lhead)
	lhead.owner = world_root
	
	# Studio Sign
	var sign = CSGBox3D.new()
	sign.name = "StudioSign"
	sign.size = Vector3(3, 0.8, 0.2)
	sign.position = Vector3(0, 3, -5.7)
	var mat_sign = StandardMaterial3D.new()
	mat_sign.albedo_color = Color(0.9, 0.2, 0.2)
	sign.material = mat_sign
	furn_node.add_child(sign)
	sign.owner = world_root
	
	# Characters
	var char_node = Node3D.new()
	char_node.name = "Characters"
	world_root.add_child(char_node)
	char_node.owner = world_root
	
	var int_layer = Node3D.new()
	int_layer.name = "InteractionLayer"
	world_root.add_child(int_layer)
	int_layer.owner = world_root
	
	var hud_pack = load("res://scenes/ui/hud.tscn")
	var hud = hud_pack.instantiate()
	hud.name = "HUD"
	world_root.add_child(hud)
	hud.owner = world_root
	
	var world_pack = PackedScene.new()
	world_pack.pack(world_root)
	ResourceSaver.save(world_pack, "res://scenes/world/studio_world.tscn")
	print("Saved studio_world.tscn")
	
	quit()

