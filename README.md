# Godot 2D Character Controller Script
This is a script I made for a 2D platformer character in Godot (along with two other scripts).

This script is not meant to be used as is, please edit the script to meet your needs.
Add a double jump or a wall jump or a sword slash or anything you can think of, be creative and have fun.

## 2D Character Controller Features

Variable jumping (Hold down jump longer to jump higher)

Coyote jumping (You're still able to jump for a split second after walking off a platform)

Buffer jumping (If you press the jump button before hitting the ground if you land soon after then you still jump)

Corner/Ledge nudging (If you just barely miss a jump then the controller will nudge you up slightly, and if you bonk your head the controller will push you in the 
direction you meant to go instead of just stopping you)

Movement speed-based running animation (If you move faster then the running animation plays faster)

Slope support (The player can move up and down slopes, though you will run off of slopes if you're moving too fast)

## Requirements
- You must have the "Movement2D" script, which is provided in this repository, in your project

- Your player must be the node type "CharacterBody2D"
  
- Your player must have an "AnimatedSprite2D" node as a child to the player, you can get around this by deleting the "Animation" region of the script,
  but they will no longer be animated
    - Your AnimatedSprite2D must have the following animations: "Idle", "Run", "Rise", "Fall"
  
- Your player must have a "CollisionShape2D" node as a child to the player
    - Your collision shape MUST be a Rectangle/Square, you can get around this by deleting the "Set Rays", "Variable Rays", "Vertical corner nudging",
      "Left ledge nudging", and "Right ledge nudging" regions in the code, but your character will no longer have corner or ledge nudging

- Under "Project -> Project Settings -> Input Map" in your project, you must have "up", "down", "left", "right", and "Jump" set up as input actions.
    - This script does have full controller support, just make sure to bind the joystick and jump buttons

## Variables
There are a lot of variables in this script to make sure you can adjust it to fit however you want the player to play, here is what they all do!

### Jumping and gravity:

**JumpPower** - How much force is applied to the player when they jump

**FallingGravityIncrase** - How much extra gravity is added to the player when they are falling downwards,
    You can adjust the general gravity at "Project -> Project Settings -> General -> Physics -> 2D -> Default Gravity" the example project uses a default gravity of 4000

**RisingGravityIncrease** - How much extra gravity is added to the player while they are rising (usually from jumping)

**PeakGravityIncrease** - How much extra gravity is added while the player is at the peak of their jump

**PeakRange** - How low the player's y velocity needs to be for it to count as the peak of their jump

**CoyoteTimeLength** - How long the player has to jump after walking off a ledge

**JumpBufferTimerLength** - How long the player's jump input will be buffered before they touch the ground

### Horizontal movement:

**SoftSpeedCap** - How fast the player can move with just the movement keys

**HardSpeedCap** - The fastest the player can move in general

**NormalAcceleration** - The amount of acceleration the player has when moving normally

**TurningAcceleration** - The amount of acceleration the player has when turning around (this is to make turning around feel snappy)

**AirAcceleration** - The amount of acceleration the player has when in the air

**NormalDeceleration** - The amount of deceleration the player has when stopping normally

**AirDeceleration** - The amount of deceleration the player has when in the air

**HighSpeedDeceleration** - The amount of deceleration the player has while going past the soft speed cap while on the floor

**BreakingSpeed** - How much the player trying to move in the opposite direction affects them when they are over the soft speed cap and are on the floor

**AirBreakingSpeed** - How much the player trying to move in the opposite direction affects them when they are over the soft speed cap and are in the air

**MaxRunningAnimationSpeed** - How fast the running animation can get in terms of percentage (1.5 means the running animation can play at a max of 150% speed)

### Corner/Ledge forgiveness (if you don't get any of these variables, probably just leave them as they are by default):

**VerticalNudge** - How much to nudge the player every frame if they just barely didn't make a jump or if they hit their head on a ceiling while moving quickly

**HorizontalNudge**








