extends Movement2D

#############################################
### This script requires a rectangular    ###
### CollisionShake2D.                     ###
### If you want to use another shape then ###
### you can delete the ledge/corner       ###
### section and it should work fine       ###
#############################################

#region Exported variables
@export_category("Jumping and gravity")
## How much vertical force is applied to the player when they jump
@export var JumpPower = 2000

	# Variables dealing with player gravity
## Player gravity added while falling
@export var FallingGravityIncrease = 800

## Player gravity added while rising (usually from jumping)
@export var RisingGravityIncrease = 0

## Player gravity added while at the peak of a jump
@export var PeakGravityIncrease = -600

## How low the player's y velocity needs to be to count as the Peak of a jump
@export var PeakRange = 250

## How long the player has to jump after walking off a ledge
@export var CoyoteTimeLength = .1

## How long the player's jump input will be buffered before they
## touch the ground
@export var JumpBufferTimerLength = .2

@export_category("Horizontal movement")
## The fastest the player can move with just the movement keys
@export var SoftSpeedCap = 1200
## The fastest the player can move in general
@export var HardSpeedCap = 6000

## The amount of acceleration the player has when moving normally
@export var NormalAcceleration = 350

## The amount of acceleration the player has when turning around
@export var TuringAcceleration = 400

## The amount of acceleration the player has when in the air
@export var AirAcceleration = 120

## The amount of deceleration the player has when stopping normally
@export var NormalDeceleration = 290

## The amount of deceleration the player has when in the air
@export var AirDeceleration = 10

## The amount of deceleration the player going past the soft speed cap and is on the floor
@export var HighSpeedDeceleration = 40

## How much the player trying to move in the opposite direction affect them when
## they are over the soft speed cap and are grounded
@export var BreakingSpeed = 60

## How much the player trying to move in the opposite direction affect them when
## they are over the soft speed cap and are in the air
@export var AirBreakingSpeed = 20

## How fast the running animation can get in terms of percentage (1.5 means the running animation can't go over 150% animation speed)
@export var MaxRunningAnimationSpeed = 1.5

@export_category("Corner/Ledge forgiveness")
## How much to nudge the player every frame if they just barely didn't make a 
## jump or hit their head on a ceiling while moving fast
@export var VerticalNudge = 7

## How much to nudge the player every frame if they hit their head on the corner of a ceiling
@export var HorizontalNudge = 7

## How lenient to be when deciding if the player will be nudged or not
## while they are hitting a corner while moving up.
## Enter a decimal as in a percent, .4 means that if the corner
## is only covering 40% of the character's collision box starting from the
## center then they will be nudged. 
@export var CornerUpNudgeLeanancy = .6

## How lenient to be when deciding if the player will be nudged or not
## while they are hitting a corner while moving Horizontally.
## Enter a decimal as in a percent, .4 means that if the corner
## is only covering 40% of the character's collision box starting from the
## center then they will be nudged. 
@export var CornerHorizontalNudgeLeanancy = .6

## How lenient to be when deciding if the player will be nudged or not
## while they are hitting a ledge while.
## Enter a decimal as in a percent, .4 means that if the ledge
## is only covering 40% of the character's collision box starting from the
## center then they will be nudged. 
@export var LedgeNudgeLeanancy = .45

#endregion

#region Non-exported variables
# If the player is currently trying to jump
var JumpInput = false

# If the player can activate coyote time, resets when landing
# This is to prevent the timer from resetting when in the air and not just leaving the ground
var CanCoyoteTime

# If the player character is in Coyote time
var CoyoteTime = false

# The current time on the coyote timer
var CurrCoyoteTimer = 0

# The current time on the jump buffer timer
var CurrJumpBufferTimer = 0

# If the player is still holding the jump button after a jump has started
# Variable automatically goes back to false when the player starts falling
var HoldingJumpInput = false

# What direction the player is pressing
var direction = 0

# Set to true if the player is at the Peak of their jump, used when calculating air momentum
var PeakOfJump : bool

# Something to do with ray casts, I genuinely do not know
var space_state

# The size of the player's CollisionShape2D (as is, will not update if
# player changes size)
var ColliderSize
#endregion

func _ready():
	# Gets the size of the player's collider, if your collider changes
	# shape mid gameplay then you need to copy this line to wherever it updates
	# its size
	ColliderSize = get_node("CollisionShape2D").shape.extents * get_node("CollisionShape2D").transform.get_scale()
	# does... something to do with rays?
	space_state = get_world_2d().direct_space_state
	pass

func _physics_process(delta):
	
	#region Timers
	# Check to see if the player is currently in coyote time
	if (CoyoteTime and CurrCoyoteTimer >= 0):
		# reduce the current coyote timer value
		CurrCoyoteTimer -= delta
		# check if the timer went to
		if(CurrCoyoteTimer < 0):
			# set coyote time to false
			CoyoteTime = false
	
	if (CurrJumpBufferTimer > 0):
		CurrJumpBufferTimer -= delta
		if(CurrJumpBufferTimer <= 0):
			JumpInput = false
#endregion
	
	#region Grounded/Ungrounded code
	
		#region Grounded code
	# Detect if player is on the ground to reset the coyote timer and vertical velocity
	if is_on_floor():
		# Resets coyote timer
		CoyoteTime = false
		CanCoyoteTime = true
		CurrCoyoteTimer = 0
		# Resets the flat gravity increase
		FlatGravIncrease = 0
		# Re-enables platform collision
		set_collision_mask_value(2, true)
#endregion

		#region Ungrounded code
	else:
		# Set coyote timer
		if (CanCoyoteTime):
			CoyoteTime = true
			CanCoyoteTime = false
			CurrCoyoteTimer = CoyoteTimeLength
			
		# check if the player is at the Peak of a jump
		if (CurrentVelocity.y < PeakRange and CurrentVelocity.y > -PeakRange):
			# apply Peak jump gravity
			FlatGravIncrease = PeakGravityIncrease
			PeakOfJump = true
		else:
			PeakOfJump = false
			if (CurrentVelocity.y < 0):
				# apply rising gravity
				FlatGravIncrease = RisingGravityIncrease
			else:
				HoldingJumpInput = false
#endregion
#endregion

	#region Jump Input
	# Detect if the player is trying to jump and enable the jump buffer timer
	if Input.is_action_just_pressed("jump"):
		JumpInput = true
		CurrJumpBufferTimer = JumpBufferTimerLength
	
	# Detect if the player has let go of the jump button while rising up
	if Input.is_action_just_released("jump"):
		if (HoldingJumpInput):
			CurrentVelocity.y = CurrentVelocity.y / 2
		HoldingJumpInput = false
#endregion

	#region Jumping
	# Start jump
	if (JumpInput and (is_on_floor() or CoyoteTime)):
		# Check if trying to pass through a platform
		if (is_on_floor() and Input.is_action_pressed("down") and Input.get_action_strength("down") > .5 and get_last_slide_collision() and get_last_slide_collision().get_collider().get_collision_layer() == 2):
			set_collision_mask_value(2, false)
		else:
			# Apply jump forace
			CurrentVelocity.y = -JumpPower
			JumpInput = false
			CurrJumpBufferTimer = 0
			HoldingJumpInput = true
			
			# Make sure the player is still actually holding the jump button
			# (this makes it where if you tap the jump button to buffer a jump then
			# it will be a minimum height jump instead of a max height jump)
			if !Input.is_action_pressed("jump"):
				CurrentVelocity.y = CurrentVelocity.y / 2
				HoldingJumpInput = false
		
		# Stop the coyote timer
		CoyoteTime = false
		CanCoyoteTime = false
		CurrCoyoteTimer = 0
#endregion

	# re-enable one way platform collision if the player
	# has let go of the "down" key
	if(Input.is_action_pressed("down") == false):
		set_collision_mask_value(2, true)

	#region Horizontal Input
	# Get player's horizontal input
	direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	# If the player is moving, add .31 to their input strength and then clamp
	# (this makes it so controlers don't need to hold a direction perfectly to go full speed)
	if (direction != 0):
		direction += sign(direction) * .31
		direction = clamp(direction, -1, 1)
#endregion
		
	# Makes sure that the player is both inputing a direction and is not over the soft speed cap
	# before applying acceleration of decceleration acordingly
	if (abs(CurrentVelocity.x) <= (SoftSpeedCap * abs(direction)) and direction):
		if(is_on_floor()):
			#region Normal Ground Movement
		# Checks if the player is trying to turn around and if the turing acceleration would be more
		# than the normal acceleration or not
			if (direction != sign(CurrentVelocity.x) and TuringAcceleration * (abs(CurrentVelocity.x) / SoftSpeedCap) > NormalAcceleration):
				# Applies Truning Acceleration
				CurrentVelocity.x += (TuringAcceleration * (abs(CurrentVelocity.x) / SoftSpeedCap)) * direction
			else:
				# Cecks if the player is near the soft cap or not
				if (sign(CurrentVelocity.x) == direction and (abs(CurrentVelocity.x) / SoftSpeedCap) >.75 and (abs(CurrentVelocity.x) / SoftSpeedCap) < 1.1):
					# If the player is near the soft speed cap then set the player's current velocity equal to the
					# soft speed cap
					CurrentVelocity.x = SoftSpeedCap * direction
				else:
					# Apply normal acceleration
					CurrentVelocity.x += NormalAcceleration * direction
#endregion
		else:
			#region Normal Air Movement
			# Cecks if the player is near the soft cap or not
				if (sign(CurrentVelocity.x) == direction and(abs(CurrentVelocity.x) / SoftSpeedCap) >.75 and (abs(CurrentVelocity.x) / SoftSpeedCap) < 1.1):
					# If the player is near the soft speed cap then set the player's current velocity equal to the
					# soft speed cap
					CurrentVelocity.x = SoftSpeedCap * direction
				else:
					# Checks if the player is at the Peak of a jump
					if(PeakOfJump):
						# apply 200% of the air acceleration to give more controle at the Peak
						CurrentVelocity.x += (AirAcceleration * 2) * direction
					else:
						# Apply air acceleration
						CurrentVelocity.x += AirAcceleration * direction
#endregion

	# Branch for if the player is over soft speed cap or is not imputing anything
	else:
		# Check to see if the player is close to stopping or not
		if (CurrentVelocity.x < 10 and CurrentVelocity.x > -10):
			# Set player's velocity to 0 if they are close to stopping
			CurrentVelocity.x = 0
		else:
			# Check if the player is moving below or slightly above the Soft speed cap
			if (abs(CurrentVelocity.x) / SoftSpeedCap >= 1.1):
				# Check and see if the player is over the hard speed cap or not
				if (abs(CurrentVelocity.x) > HardSpeedCap):
					#region Prevent player from going over hard speed cap
					# Set the velocity equal to the hard speed cap
					CurrentVelocity.x = HardSpeedCap * sign(CurrentVelocity.x)
					# Apply High Speed Deceleration
					CurrentVelocity.x -= HighSpeedDeceleration * sign(CurrentVelocity.x)
#endregion
				else:
					#region Calculate high speed deceleration
					# Check to see if the player is in the air or not
					if(is_on_floor()):
						# Apply Sigh Speed deceleration
						CurrentVelocity.x -= HighSpeedDeceleration * sign(CurrentVelocity.x) 
					else:
						# Apply air deceleration
						CurrentVelocity.x -= AirDeceleration * sign(CurrentVelocity.x)
					# if the player is holding the opposite direction of their x velocity then
					# apply the normal movement speed againt their current x velocity
				# Check to see if the player is holding the opposite direction
				if (sign(-direction) == sign(CurrentVelocity.x)):
					# Check to see if the player is grounded or not
					if(is_on_floor()):
						# Apply breaking speed
						CurrentVelocity.x += BreakingSpeed * direction
					else:
						# Apply air breaking speed
						CurrentVelocity.x += AirBreakingSpeed * direction
#endregion
			else:
				# Check to see if the player is in the air or not
				if (is_on_floor()):
					# Apply normal Deceleration while within soft speed cap
					CurrentVelocity.x -= (NormalDeceleration * sign(CurrentVelocity.x)) * (abs(CurrentVelocity.x) / SoftSpeedCap)
				else:
					# Apply air Deceleration while within soft speed cap
					CurrentVelocity.x -= (AirAcceleration * sign(CurrentVelocity.x)) * (abs(CurrentVelocity.x) / SoftSpeedCap)
			
	
	var EnableCollision = true
	
	var Center = transform.origin + $CollisionShape2D.transform.origin
#region Set Rays
	# set up left wall raycast
	var LeftWallRay = PhysicsRayQueryParameters2D.create(Center + Vector2(-ColliderSize.x - 2, -ColliderSize.y + 3), Center + Vector2(-ColliderSize.x - 2, ColliderSize.y - 3), get_collision_mask_value(1))
	LeftWallRay.hit_from_inside = true
	var LeftWallRayResult = space_state.intersect_ray(LeftWallRay)
	
	# set up right wall raycast
	var RightWallRay = PhysicsRayQueryParameters2D.create(Center + Vector2(ColliderSize.x + 2, -ColliderSize.y + 3), Center + Vector2(ColliderSize.x + 2, ColliderSize.y - 3), get_collision_mask_value(1))
	RightWallRay.hit_from_inside = true
	var RightWallRayResult = space_state.intersect_ray(RightWallRay)
	
	# set up Far Left Ceiling raycast
	var FarLeftCeilingRay = PhysicsRayQueryParameters2D.create(Center + Vector2(-ColliderSize.x - 2, -ColliderSize.y + 3), Center + Vector2(-ColliderSize.x - 2, -ColliderSize.y - 30), get_collision_mask_value(1))
	FarLeftCeilingRay.hit_from_inside = true
	var FarLeftCeilingRayResult = space_state.intersect_ray(FarLeftCeilingRay)
	
	# set up Far Right Ceiling raycast
	var FarRightCeilingRay = PhysicsRayQueryParameters2D.create(Center + Vector2(ColliderSize.x + 2, -ColliderSize.y + 3), Center + Vector2(ColliderSize.x + 2, -ColliderSize.y - 30), get_collision_mask_value(1))
	FarRightCeilingRay.hit_from_inside = true
	var FarRightCeilingResult = space_state.intersect_ray(FarRightCeilingRay)
	
	# set up Far Left Ceiling raycast
	var TopCornerForgivenessRay = PhysicsRayQueryParameters2D.create(Center + Vector2(-ColliderSize.x - 30, -ColliderSize.y - 3), Center + Vector2(ColliderSize.x + 30, -ColliderSize.y - 3), get_collision_mask_value(1))
	TopCornerForgivenessRay.hit_from_inside = true
	var TopCornerForgivenessRayResult = space_state.intersect_ray(TopCornerForgivenessRay)
	
	# set up Bottom
	var BottomLedgeForgivenessRay = PhysicsRayQueryParameters2D.create(Center + Vector2(-ColliderSize.x - 30, ColliderSize.y + 3), Center + Vector2(ColliderSize.x + 30, ColliderSize.y + 3), get_collision_mask_value(1))
	BottomLedgeForgivenessRay.hit_from_inside = true
	var BottomLedgeForgivenessRayResult = space_state.intersect_ray(BottomLedgeForgivenessRay)
	
#endregion
	
#region Variable Rays
	# set up left wall raycast
	var LeftCeilingRay = PhysicsRayQueryParameters2D.create(Center + Vector2(-ColliderSize.x * (1 - CornerUpNudgeLeanancy), -ColliderSize.y), Center + Vector2(-ColliderSize.x * (1 - CornerUpNudgeLeanancy ), -ColliderSize.y - 30), get_collision_mask_value(1))
	# I have no idea why this one needs to be false but it do
	LeftCeilingRay.hit_from_inside = false
	var LeftCeilingRayResult = space_state.intersect_ray(LeftCeilingRay)
	
	# set up right wall raycast
	var RightCeilingRay = PhysicsRayQueryParameters2D.create(Center + Vector2(ColliderSize.x * (1 - CornerUpNudgeLeanancy), -ColliderSize.y), Center + Vector2(ColliderSize.x * (1 - CornerUpNudgeLeanancy ), -ColliderSize.y - 30), get_collision_mask_value(1))
	# again, I have no idea why this one needs to be false but it do
	RightCeilingRay.hit_from_inside = false
	var RightCeilingRayResult = space_state.intersect_ray(RightCeilingRay)
	
	# set up corner rays
	var CornerRayLeft = PhysicsRayQueryParameters2D.create(Center + Vector2(-ColliderSize.x - 1, -ColliderSize.y * (1 - CornerHorizontalNudgeLeanancy)), Center + Vector2(-ColliderSize.x - 30, -ColliderSize.y * (1 - CornerHorizontalNudgeLeanancy)), get_collision_mask_value(1))
	var CornerRayRight = PhysicsRayQueryParameters2D.create(Center + Vector2(ColliderSize.x + 1, -ColliderSize.y * (1 - CornerHorizontalNudgeLeanancy)), Center + Vector2(ColliderSize.x + 30, -ColliderSize.y * (1 - CornerHorizontalNudgeLeanancy)), get_collision_mask_value(1))
	CornerRayLeft.hit_from_inside = true
	CornerRayRight.hit_from_inside = true
	var CornerRayResult = space_state.intersect_ray(CornerRayLeft) or space_state.intersect_ray(CornerRayRight)
	
	var LedgeRayLeft = PhysicsRayQueryParameters2D.create(Center + Vector2(-ColliderSize.x - 1, ColliderSize.y * (1 - LedgeNudgeLeanancy)), Center + Vector2(-ColliderSize.x - 30, ColliderSize.y * (1 - LedgeNudgeLeanancy)), get_collision_mask_value(1))
	var LedgeRayRight = PhysicsRayQueryParameters2D.create(Center + Vector2(ColliderSize.x + 1, ColliderSize.y * (1 - LedgeNudgeLeanancy)), Center + Vector2(ColliderSize.x + 30, ColliderSize.y * (1 - LedgeNudgeLeanancy)), get_collision_mask_value(1))
	LedgeRayLeft.hit_from_inside = true
	LedgeRayRight.hit_from_inside = true
	var LedgeRayResult = space_state.intersect_ray(LedgeRayLeft) or space_state.intersect_ray(LedgeRayRight)
	
#endregion

	#region Vertical corner nudging
	# checks to see if the player and against a Ceiling is in the air
	if (!is_on_floor() and is_on_ceiling()):
		# Checks if the player is going at lest 25% of your jumpforce worth of velocity up
		if(CurrentVelocity.y <= JumpPower * .75 and !LeftWallRayResult):
			# Check to see if the player is rubbing against a ledge
			if (FarLeftCeilingRayResult and !LeftCeilingRayResult):
				# Disable the player's collsion
				set_collision_mask_value(1, false)
				EnableCollision = false
				# Nudge the player right by "HorizontalNudge" ammount of units
				Center += Vector2(HorizontalNudge, 0) 
			else:if (!RightCeilingRayResult and FarRightCeilingResult):
				# Disable the player's collsion
				set_collision_mask_value(1, false)
				EnableCollision = false
				# Nudge the player left by "HorizontalNudge" ammount of units
				Center -= Vector2(HorizontalNudge, 0) 
			else: if (CurrentVelocity.y < 0):
				CurrentVelocity.y = 0
#endregion
	
	#region Left ledge nudging
	# varable to tell the game if the player is currently getting nudged
	var Nudging = false
	# checks to see if the player is in the air, over 30% of their soft speed cap, 
	# and against a left wall 
	if(LeftWallRayResult and sign(CurrentVelocity.x) == -1 and abs(CurrentVelocity.x) * (abs(CurrentVelocity.x) / SoftSpeedCap) >= .3):
		if(!is_on_floor()):
			# Check to see if the player is rubbing against a ledge
			if (BottomLedgeForgivenessRayResult and !LedgeRayResult):
				Nudging = true
				# Disable the player's collsion
				set_collision_mask_value(1, false)
				EnableCollision = false
				# Nudge the player up by "VerticalNudge" ammount of units
				Center -= Vector2(0, VerticalNudge) 
			# If the player is not on a ledge check to see if the player is rubbing against a corner
			else: if (TopCornerForgivenessRayResult and !CornerRayResult):
				Nudging = true
				# Disable the player's collsion
				set_collision_mask_value(1, false)
				EnableCollision = false
				# Set the player's vertical velocity to 0 so they don't get stuck to the ceiling
				if(CurrentVelocity.y < 0):
					CurrentVelocity.y = 0
				# Nudge the player down by "VerticalNudge" ammount of units
				Center += Vector2(0, VerticalNudge) 
		
		# If the player is not on a corner or lege stop their horizontal velocity because
		# they hit a wall
		if (!Nudging):
			CurrentVelocity.x = 0
#endregion
	
	#region Right ledge nudging

	# checks to see if the player is in the air, over 30% of their soft speed cap, 
	# and against a right wall 
	else:if(RightWallRayResult and sign(CurrentVelocity.x) == 1 and abs(CurrentVelocity.x) * (abs(CurrentVelocity.x) / SoftSpeedCap) > .3):
		if (!is_on_floor()):
				# Check to see if the player is rubbing against a ledge
			if (BottomLedgeForgivenessRayResult and !LedgeRayResult):
				Nudging = true
				# Disable the player's collsion
				set_collision_mask_value(1, false)
				EnableCollision = false
				# Nudge the player up by "VerticalNudge" ammount of units
				Center -= Vector2(0, VerticalNudge) 
			# If the player is not on a ledge check to see if the player is rubbing against a corner
			else: if (TopCornerForgivenessRayResult and !CornerRayResult):
				Nudging = true
				# Disable the player's collsion
				set_collision_mask_value(1, false)
				EnableCollision = false
				# Set the player's vertical velocity to 0 so they don't get stuck to the ceiling
				if(CurrentVelocity.y < 0):
					CurrentVelocity.y = 0
				# Nudge the player down by "VerticalNudge" * 2 ammount of units
				Center += Vector2(0, VerticalNudge * 2) 
		# If the player is not on a corner or lege stop their horizontal velocity because
		# they hit a wall
		if (!Nudging):
			CurrentVelocity.x = 0
#endregion
	
	if(EnableCollision):
		# Enables the player's collision again
		set_collision_mask_value(1, true)
	
	super._physics_process(delta)
	
#region Animation
	# check to see if the player is grounded
	if(is_on_floor()):
		# check to see if the player is moving or not
		# (we check for 25% of the player's movment speed, aka soft speed cap
		# because if we were to check for zero then the walking animation
		# would continue even though the player has pretty much stopped
		if (abs(CurrentVelocity.x) < SoftSpeedCap * .25):
			# Play idle animation
			$AnimatedSprite2D.play("Idle")
		else:
			# Play running animation using player movement speed
			# to determin play speed
			$AnimatedSprite2D.play("Run", clamp(abs(CurrentVelocity.x / SoftSpeedCap), .2 ,MaxRunningAnimationSpeed))
	else:
		# check if the player is going up or not
		# (reminder that -y is up and positve y is down)
		if (CurrentVelocity.y < 0):
			# Play rising animation
			$AnimatedSprite2D.play("Rise")
		else:
			# Play falling animation
			$AnimatedSprite2D.play("Fall")
		
	# Check if the player is moving at all then if they are flip their
	# sprite accordingly
	if (CurrentVelocity.x != 0):
		$AnimatedSprite2D.flip_h = (sign(CurrentVelocity.x) == -1)
#endregion
	
func remove_jump():
	CoyoteTime = false
	CurrCoyoteTimer = 0
	HoldingJumpInput = false
