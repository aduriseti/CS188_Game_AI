# CS188_Game_AI
Github repository for quarter  project of UCLA CS188 Game AI course


##TODO

###General

###Movement (Anal)
 - [x] "Greedy" DFS
 - [x] DFS
 - [ ] BFS/A* for pathfinding in already explored regions
 - [ ] make faceAT not shitty
 - [ ] change scale and make persist
 - [ ] move based on physics - use impulse functions in API
 - [ ] make chase function more like run from function
 - [ ] make chase and run from functions update direction immediately on sight as opposed to on grid position change

###Player (Amal)
 - [ ] change camera view to switch between overseer and mouse mode
 - [ ] get kepresses and use to control camera position
 - [ ] get user view direction and use to control camera position
 - [ ] get mouse clicks and location of clicks - correspond to some action in game world
 - [ ] combine user input functionality to take over a mouse
 - [ ] log user input while controlling a mouse as data for machine learning

###Mouse (Amal)
 - [x] Mouse/Mice freely roam maze, pick random direction at intersection, limited memory
 - [x] Mice detect food -> Eat state
 - [x] Mice detect state -> Run state
 - [ ] Mice Power state -> Can get Snakes (Replace wildcard food or maybe Snakes drop food like RPGs...?)
 - [ ] Ability to move blocks

###Snake (Gil)
  - [x] Roam Maze (On Leash from spawned start)
  - [x] Detect Mice -> chase -> kill 

###Maze (Mitchell)
 - [ ] Make Fancy Walls
 - [x] Make Food Entity(s)
 - [ ] Make Trap Entities
 - [x] Spawn Food
 - [x] Spawn Mice
 - [x] Spawn Snakes
 - [ ] Spawn Traps

###Misc (Erick, Everyone)
 - [ ] Design Trap Entities
 - [ ] Mouse assets
 - [ ] Snake assets
 - [ ] Player MadScientist/Mouse Management System
 - [ ] User Interface (Start Screen, etc...)
 - [ ] Further Game Logic
 

##Description
Mouse Maze

Mouse Maze / Rat Race / Racin' Rats

Started as Mice in a maze, first to finish wins, but what one learns from one maze doesn't carry over to a new maze.... so...

Mice in maze aim to eat a complete breakfast (the "complete breakfast" can vary among mice) and there is limited food hidden in the maze

Mazes are procedurally generated and follow certain rules/conventions (For example Berry type food is always in the NorthWest, thus there is carry over knowledge for new mazes that the mice/rats can use)

Player could be another mouse among AI mice competing for its breakfast, or player could be a mad scientist who conducts these tests and could give feedback learning to mice

Mice in maze obey exaggerated physics (Run to fast before a turn and can't slow down -> Splat on the wall) (Like a racing game)

  Need to learn how to move quickly w/o dying to complete breakfast while food is still left

Snakes in maze that serve function of sentries (Mice must avoid or defeat these snakes) (like pacman ghosts)

Individual Mice could have characteristics like shyness/boldness that factor in when confronting snakes and could be influenced by player (scientist) feedback

Potential group dynamic among mice

Mice could form synergistic relationships by exchanging info (general food locations, i.e. Berries in NW) in order to increase each others survival

Choosing allies... not all can survive, but more than 1 could....

Mice would have to learn to navigate different structures like loops in mazes and avoiding running into walls.

Could be mouse traps loaded with cheese, maybe some already sprung (could learn to recognize)

.
