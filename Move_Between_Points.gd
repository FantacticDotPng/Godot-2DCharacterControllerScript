extends StaticBody2D
# If making a platform, make sure it is of time "AnimateableBody2D"

## List of points where the object moves relative to the object's starting postion
@export
var MovePoints : Array[Vector2] = []

## How fast the object moves
@export
var TweenSpeed : float = 1

## If set to true then the object will go backwards through the
## points rather than going back to the start
@export
var Backtrack = false

# If true, loop to next point in the array
var GoToNext = true

# What point is going to me moved to next
var n = 0

# The object's start position
var StartPos 

# If enabled then the script loops backwards through the points instead
var FlipLoop = false

func _ready():
	StartPos = transform.get_origin()
	pass

func _process(_delta):
	# Checks if the object is ready to go to the next point or not
	
	if(GoToNext):
		# Create tween
		var tween = create_tween()
		# Check to see if the selected n is outside of the range of
		# the MovePoints array or not
		if (n >= MovePoints.size()):
			# Checks to see if the object backtracks instead of looping
			# back to the begining
			if (Backtrack == false):
				# Rest n value
				n = 0
				GoToNext = false
				# Tween to the origonal point
				tween.tween_property(self, "position", StartPos, get_time(true)).from_current()
				tween.connect("finished", on_tween_finished)
			else:
				# Start going backwards through the points
				FlipLoop = true
				n = MovePoints.size() - 2
				
				# Godot gives me an error if this isn't here
				# I deadass have no idea why
				# something about reusing the tween I think? idk
				tween.kill()
				return
			
		# Check to see if the selected n is outside of the range of
		# the MovePoints array or not
		else: if (FlipLoop and n < 0):
			# Stop going backwards through points
			FlipLoop = false
			GoToNext = false
			# Reset n value
			n = 0
			# Tween back to origan point
			tween.tween_property(self, "position", StartPos, get_time(true)).from_current()
			tween.connect("finished", on_tween_finished)
		else:
			GoToNext = false
			# Tween to nth point
			tween.tween_property(self, "position", StartPos + MovePoints[n], get_time(0)).from_current()
			# Check if we're currently going backwards
			# through the points or not
			if (FlipLoop):
				n -= 1
			else:
				n += 1
			tween.connect("finished", on_tween_finished)
	pass

func on_tween_finished():
	#print(n)
	#print(MovePoints[n-1])
	GoToNext = true
	pass

func get_time(returing_to_origin : bool):
	# Get the distance between the object's current possition and where it is going
	var distance
	if (returing_to_origin):
		distance = sqrt(pow(transform.origin.x - StartPos.x, 2) + pow(transform.origin.y - StartPos.y, 2))
	else:
		distance = sqrt(pow(transform.origin.x - (StartPos.x + MovePoints[n].x), 2) + pow(transform.origin.y - (StartPos.y + MovePoints[n].y), 2))
	return distance / TweenSpeed
