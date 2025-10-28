extends Node3D
class_name MazeGenerator3D

@export var maze_width: int = 10
@export var maze_depth: int = 10
@export var cell_size: float = 4.0
@export var wall_scene: PackedScene = preload("res://scenes/wall.tscn")
@export var player_scene: PackedScene = preload("res://scenes/player.tscn")

var maze: Array = []


func _ready() -> void:
	randomize()
	generate_maze()
	build_floor()
	build_maze()
	spawn_player()


func generate_maze() -> void:
	maze.clear()
	for z in range(maze_depth):
		var row := []
		for x in range(maze_width):
			row.append({"visited": false, "walls": {"N": true, "S": true, "E": true, "W": true}})
		maze.append(row)
	
	_carve_passages_from(0, 0)


func _carve_passages_from(cx: int, cz: int) -> void:
	maze[cz][cx]["visited"] = true
	var dirs := ["N", "S", "E", "W"]
	dirs.shuffle()
	
	for dir in dirs:
		var nx := cx
		var nz := cz
		
		match dir:
			"N": nz -= 1
			"S": nz += 1
			"E": nx += 1
			"W": nx -= 1
		
		if nx < 0 or nz < 0 or nx >= maze_width or nz >= maze_depth:
			continue
		
		if maze[nz][nx]["visited"]:
			continue
		
		match dir:
			"N":
				maze[cz][cx]["walls"]["N"] = false
				maze[nz][nx]["walls"]["S"] = false
			"S":
				maze[cz][cx]["walls"]["S"] = false
				maze[nz][nx]["walls"]["N"] = false
			"E":
				maze[cz][cx]["walls"]["E"] = false
				maze[nz][nx]["walls"]["W"] = false
			"W":
				maze[cz][cx]["walls"]["W"] = false
				maze[nz][nx]["walls"]["E"] = false
		
		_carve_passages_from(nx, nz)


func build_floor() -> void:
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(maze_width * cell_size, maze_depth * cell_size)

	var floor_instance := MeshInstance3D.new()
	floor_instance.mesh = floor_mesh
	floor_instance.position = Vector3(
		(maze_width * cell_size) / 2.0 - (cell_size / 2.0),
		0.0,
		(maze_depth * cell_size) / 2.0 - (cell_size / 2.0)
	)

	add_child(floor_instance)
	floor_instance.create_trimesh_collision()


func build_maze() -> void:
	for z in range(maze_depth):
		for x in range(maze_width):
			var cell = maze[z][x]
			var world_x := float(x) * cell_size
			var world_z := float(z) * cell_size
			var base_y := 0.0
			
			if cell["walls"]["N"]:
				_spawn_wall(Vector3(world_x, base_y, world_z - cell_size / 2), 0)
			if cell["walls"]["S"]:
				_spawn_wall(Vector3(world_x, base_y, world_z + cell_size / 2), 0)
			if cell["walls"]["E"]:
				_spawn_wall(Vector3(world_x + cell_size / 2, base_y, world_z), 90)
			if cell["walls"]["W"]:
				_spawn_wall(Vector3(world_x - cell_size / 2, base_y, world_z), 90)


func _spawn_wall(position1: Vector3, rotation_y: float) -> void:
	if wall_scene == null:
		push_error("Wall scene not assigned!")
		return
	var wall := wall_scene.instantiate()
	wall.position = position1
	wall.rotation_degrees = Vector3(0, rotation_y, 0)
	add_child(wall)



func spawn_player() -> void:
	if player_scene == null:
		push_error("Player scene not assigned!")
		return

	var player := player_scene.instantiate()


	var center_x := (maze_width * cell_size) / 2.0 - (cell_size / 2.0)
	var center_z := (maze_depth * cell_size) / 2.0 - (cell_size / 2.0)

	
	player.position = Vector3(center_x, 1.0, center_z)

	add_child(player)
