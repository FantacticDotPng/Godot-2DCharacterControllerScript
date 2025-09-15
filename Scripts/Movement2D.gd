extends CharacterBody2D
class_name Movement2D

# The player's current velocity
var CurrentVelocity : Vector2

# The gravity set on the project
var Gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# A flat number that is added to gravity as it is applied
@export var FlatGravIncrease : float = 0

# A multiplier that is added to the gravity as it is applied
# It is also applied to the Flat Gravity Increase variable
@export var GravMultiplier : float = 1

## The max speed the character can fall
var MaxFallSpeed = 2500


func Apply_Force(AppliedForce : Vector2, RemoveJump : bool):
	# Add the applied force variable to the player's current velocity
	CurrentVelocity.x += AppliedForce.x
	CurrentVelocity.y += AppliedForce.y
	if RemoveJump:
		remove_jump()

func Set_Velocity(VelocitySet : Vector2, RemoveJump : bool):
	# Add the applied force variable to the player's current velocity
	CurrentVelocity.x = VelocitySet.x
	CurrentVelocity.y = VelocitySet.y
	if RemoveJump:
		remove_jump()

# Function to remove the jump from the 2D character controler script
# Function replaced in the 2D character controler
func remove_jump():
	return

func Get_Velocity():
	return CurrentVelocity

func Set_FlatGravityIncrease(GravityIncrease : float):
	FlatGravIncrease = GravityIncrease

func Set_GravityMultiplier(GravityMiltiplier : float):
	GravMultiplier = GravityMiltiplier

func Get_FlatGravity():
	return FlatGravIncrease

func Get_GravityMultiplier():
	return GravMultiplier

func _physics_process(delta):
	# Apply gravity
	CurrentVelocity.y += ((Gravity + FlatGravIncrease) * GravMultiplier) * delta
	
	# check if the player is rising or falling
	if (CurrentVelocity.y > 0):
		# Check to see if the player is over the max fall speed or not
		if (CurrentVelocity.y > MaxFallSpeed):
			# Set the player's y velocity equal to their max fall speed
			CurrentVelocity.y = MaxFallSpeed
	
	# Reset velocity if on floor
	if(is_on_floor() and CurrentVelocity.y > 0):
		CurrentVelocity.y = 0
	velocity = CurrentVelocity
	# Stuff to make slopes work (I have no idea what these actually do, I
	# just know they work)
	floor_constant_speed = true
	floor_max_angle = .5
	floor_snap_length = 15
	# Apply movement
	move_and_slide()
	pass
