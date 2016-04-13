----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Maze = {
  type = "Maze",                                   -- can be useful for scripting

  -- Directions in maze (For example: Going north from current position means going up 1 in y axis)
    directions = {
        north = {x = 0, y = -1},
        east = {x = 1, y = 0},
        south = {x = 0, y = 1},
        west = {x = -1, y = 0},
    },

  -- Copied from BasicEntity.lua
  Properties = {
     bUsable = 0,
	 iWidth = 3,
     iHeight = 3,
	 object_Model = "objects/default/primitive_cube.cgf",
     
     --Copied from BasicEntity.lua
     Physics = {
        bPhysicalize = 1, -- True if object should be physicalized at all.
        bRigidBody = 1, -- True if rigid body, False if static.
        bPushableByPlayers = 1,
    
        Density = -1,
        Mass = -1,
     },
  },
  
 

  -- optional editor information taken from BasicEntity.lua
  Editor = {
	 	Icon = "physicsobject.bmp",
		IconOnTop=1,
  },
};

-- I DUNNO WTF THIS IS I COPIED FROM BasicEntity.lua
local Physics_DX9MP_Simple = {
	bPhysicalize = 1, -- True if object should be physicalized at all.
	bPushableByPlayers = 0,
		
	Density = 0,
	Mass = 0,
		
}

-- I dunno, make it usable?
MakeUsable(Maze);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Entity State Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
function Maze:OnInit()
    self:OnReset();
end

function Maze:OnSpawn()
    self:OnReset();
end

function Maze:OnPropertyChange()
    self:OnReset();
end

function Maze:OnReset()

    self:Activate(1); -- I dunno what? Activate?
    
	local Properties = self.Properties;
    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity

        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
        self:New();  -- OOOO YEAH, MAKE THAT MAZE BITCHES
    end
	
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Maze:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		Physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end


----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze Helper  Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

--Fills in border of maze with blocks
function Maze:Border()

    -- Get Height and Width
    local height = self:height()*2+1;       
    local width = self:width()*2+1;
        
    --[[
        The reason its multiplied by 2 and 1 is added is to 
            1) Account for basic graph like version... meaning the lines become solid and take up non-infitesimal width 
            2) Keep size always OddxOdd (needed to ensure there is a border wall surrounding entire graph ...)
            
            Ex Graph: Three 3x3 grid, 9 rooms/cells, Each cell is separated by a wall ( wall is | or __ )
                Room 1 is at coordinates (1,1)
                Room 2 is at coordinates (2,1)
                Room 4 is at coordinates (1,2)
        y-axis _____________
             3 |_7_|_8_|_9_|
             2 |_4_|_5_|_6_|
             1 |_1_|_2_|_3_|
                 1   2   3   x-axis
                 
              Which is great on paper with lines to only be walls....
              But in a 3D env, the walls have thickness, they become blocks
              So to really make a 3room/cell x 3room/cell grid, the size actually has to be 3*2+1 by 3*2+1 => 7 by 7
              
              Ex: #'s are Walls, Open Cells/Rooms are numbered 1-9 like before
                  Room 1 is at coordinates (2,2)
                  Room 2 is at coordinates (4,2)
                  Room 4 is at coordinates (2,4)
          y-axis _____________________________
               7 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
               6 |_#_|_7_|_#_|_8_|_#_|_9_|_#_|
               5 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
               4 |_#_|_4_|_#_|_5_|_#_|_6_|_#_|
               3 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
               2 |_#_|_1_|_#_|_2_|_#_|_3_|_#_|
               1 |_#_|_#_|_#_|_#_|_#_|_#_|_#_|
                   1   2   3   4   5   6   7    x-axis
                   
               Overall this is a translation of (2x,2y) from orig (Room 1 used to be at (1,1) now it is at (2*1, 2*1) )
               
               Further each position in this graph will be referred to as a slot, the slot at coordinates (1,1) will be slot 1
               The slot at (2,1) will be slot 2 ... (7,1) will be slot 7. The slot at (1,2) will be 8...
               One can calculate the slot from the coordinates (x,y) with the formula: 
                    (y-1)*Width + x 
                        Ex: 
                            (1,1) -> (1-1)*7 + 1 = 1
                            (1,2) -> (2-1)*7 + 1 = 8
              
              Here is a graph with each slot labelled:
                    Keep in mind that the majority of these slots are walls
                        In fact, the only slots that are actually open rooms/cell are 
                            (2,2) is Room 1 -> Slot 9 -> this is open cell/room 1 in graph above 
                            (4,2) is Room 2 -> slot 11                        
                        
                   y-axis ____________________________________
                        7 |_43_|_44_|_45_|_46_|_47_|_48_|_49_|
                        6 |_36_|_37_|_38_|_39_|_40_|_41_|_42_|
                        5 |_29_|_30_|_31_|_32_|_33_|_34_|_35_|
                        4 |_22_|_23_|_24_|_25_|_26_|_27_|_28_|
                        3 |_15_|_16_|_17_|_18_|_19_|_20_|_21_|
                        2 |_8 _|_9 _|_10_|_11_|_12_|_13_|_14_|
                        1 |_1 _|_2 _|_3 _|_4 _|_5 _|_6 _|_7 _|
                            1     2   3    4    5    6    7    x-axis
              
              To Further specify the walls into categories, there are some that are a border (i.e. never broken down to create a path) and 
              others that can be broken down to create a path (Doors). 
              For the sake of simplicity, consider doors to be the walls North, East, South, and West of a room
              For example cells (2,7), (3,6), (2,5), and (1,6) will be considered doors (despite the fact that (1,6) and (2,7) cannot be opened)
                because they are North, East, South, and West of a Room 7
              The walls that are not adjacent to a room will be considered a border 
              This distinction doesn't really matter, it just explains that the for loop below that "create border" just fills in these border walls  
              
              Thus Create Border on the graph:
          y-axis _____________________________
               7 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
               6 |_#_|_7_|_#_|_8_|_#_|_9_|_#_|
               5 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
               4 |_#_|_4_|_#_|_5_|_#_|_6_|_#_|
               3 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
               2 |_#_|_1_|_#_|_2_|_#_|_3_|_#_|
               1 |_B_|_#_|_B_|_#_|_B_|_#_|_B_|
                   1   2   3   4   5   6   7    x-axis
               
               where B is what has been filled in with walls so far
    ]]
        
    -- Create Border
    for y=1, height, 2 do 
        for x=1, width, 2 do
            
            self:Wall(x,y); -- This function takes an x and y coord on the graph and fills in a wall
            
        end
    end
end

-- fills in "doors" of maze with blocks
    --Never actually used, made for testing purposes
function Maze:DoorSpawn()
    
    local height = self:height()*2+1;
    local width = self:width()*2+1;
    
    --[[ 
        Same as the comment block in CreateBorder
        This time we fill in the walls for "Door"
        Effectively Making:
        
         y-axis  _____________________________
               7 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               6 |_D_|_7_|_D_|_8_|_D_|_9_|_D_|
               5 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               4 |_D_|_4_|_D_|_5_|_D_|_6_|_D_|
               3 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               2 |_D_|_1_|_D_|_2_|_D_|_3_|_D_|
               1 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
                   1   2   3   4   5   6   7    x-axis
               
               Where all the every non room cell is now a wall 
               (B and D are both walls and are essentially the same. 
               B is what was filled in in the createBorder function, D is what was filled in here)
               
    ]]
    
    -- Create doors
    for y=1, height do
        for x=1, width do
        
            -- Odd row (y is odd (1, 3, 5, 7...) ) then D is only on even X's ( (2,1), (4,1), (2,3)... )
            if (y%2 ~=0 and x*2 <= width) then 
                x = 2*x;
                self:Wall(x,y);
            elseif (y%2 ==0) then -- Even Row (y is even (2, 4, 6, ...)) then D is only on odd X's ( (1,2), (3,2), (1,4)...)
                x = (2*x)-1;
                self:Wall(x,y);
            else 
                --Otherwise do nothing...
            end

        end

    end
end

-- Fills a block ( a wall) in at coordinates (w,h)
function Maze:Wall(w, h)

        local Properties = self.Properties;
        local width = self:width()*2+1
        local nSlot = (h-1)*width + w;
        
        self:LoadObject(nSlot, Properties.object_Model);
        -- So guess what, actual world coordinates requires further manipulation
        self:SetSlotPos(nSlot, {x=2*(w-1),y=2*(h-1),z=0});
        --[[
            This is because the block object model we use is actually 2x2
            thus, we have to multiply by 2 so the blocks don't overlap
            I subtract 1, because the position actually starts at (0,0), and our graph/(lua tables) starts at 1
            Hence what we actually have for reals looks something like:
                Ex:
                
           y-axis ___________________________________________
            12,13 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
            10,11 |_ # _|_ 7 _|_ # _|_ 8 _|_ # _|_ 9 _|_ # _|
              8,9 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
              6,7 |_ # _|_ 4 _|_ # _|_ 5 _|_ # _|_ 6 _|_ # _|
              4,5 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
              2,3 |_ # _|_ 1 _|_ # _|_ 2 _|_ # _|_ 3 _|_ # _|
              0,1 |_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|_ # _|
                    0,1   2,3   4,5   6,7   8,9  10,11 12,13   x-axis                
        ]]
        self:DrawSlot(nSlot,1);
end

-- Alright, main maze gen code that calls other helper function
function Maze:New()
    obj = obj or {}         -- Our 2d array that is the graph version of the maze with infinitesimally thin walls... so (1,1) is actually Room 1, which is really at (2,2) in the world
    setmetatable(obj, self)
    self.__index = self
    
    local width = self:width()   -- Returns width of graph with infinitesimally thin walls, so essentially its #rooms wide, not actual width which would be width*2+1
    local height = self:height() -- #rooms tall
    
    self:Border(); -- Fill in border cells with walls
    
    -- Setup Maze
        -- For each room in 2d array, record that there is a closed door (i.e. wall) in each direction
        -- Effectively doing what DoorSpawn() does, filling in remaining walls
    for y = 1, height do
        obj[y] = {}
        for x = 1, width do
            obj[y][x] = { east = obj:CreateDoor(closed,2*y, 2*x+1 ), south = obj:CreateDoor(closed,2*y+1,2*x)}
            --CreateDoor records that there is a wall there via bool value in 2d array that is obj[y][x], and fills wall in in actual 3D real world graph
                                        
        -- Doors are shared beetween the cells to avoid out of sync conditions and data dublication
        if x ~= 1 then obj[y][x].west = obj[y][x - 1].east
        else obj[y][x].west = obj:CreateDoor(closed,2*y,2*x-1) end
        
        if y ~= 1 then obj[y][x].north = obj[y - 1][x].south
        else obj[y][x].north = obj:CreateDoor(closed,2*y-1,2*x) end
        end
    end
    
    --[[
        At this point we have setup the following in the world:

         y-axis  _____________________________
               7 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               6 |_D_|_7_|_D_|_8_|_D_|_9_|_D_|
               5 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               4 |_D_|_4_|_D_|_5_|_D_|_6_|_D_|
               3 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
               2 |_D_|_1_|_D_|_2_|_D_|_3_|_D_|
               1 |_B_|_D_|_B_|_D_|_B_|_D_|_B_|
                   1   2   3   4   5   6   7    x-axis
               
               Where all the every non room cell is now a wall 
               (B and D are both walls and are essentially the same. 
               B is what was filled in in the createBorder function, D is what was filled in here)
        
        The obj 2d array representation we are using in the code actually would look someting like:
                c stands for a closed door
                # are implicit walls, not actually stated anywhere, just to make illustration more understandable...
                
           y-axis   # c # c # c #
                3   c 7 c 8 c 9 c
                2   c 4 c 5 c 6 c
                1   c 1 c 2 c 3 c
                    # c # c # c #
                      1   2   3   x-axis
    ]]
     
    obj:GrowingTree(); -- This function calls the growing tree algorithm to start opening doors to create a maze 

    obj:PhysicalizeWallSlots(); -- The maze has been complete, make the walls of the maze actually physical (i.e. cant go walk them)
end

--Door class/ called to create doors
    -- Records there is a door adjacent to room in obj (The 2d graph with infinitesimally small walls)
    -- Fills in the real world coordinates with a wall
function Maze:CreateDoor(closed, h, w)

    local door = {}
    door.closed = closed and true or false -- records that door is closed  (e.g. door=true)
    
    self:Wall(w,h)  -- Fills in block object in world at real world coordinates (w,h)
    
    -- Never used
    function door:IsClosed()
        return self.closed
    end

    -- Never used
    function door:IsOpened()
        return not self.closed
    end

    -- Never used
    function door:Close()
        self.closed = true
    end

    -- Mark that the door is open, to avoid opening repeatedly
    function door:Open()
        self.closed = false

    end

    -- Never used
    function door:SetOpened(opened)
        if opened then
            self:Open()
        else
            self:Close()
        end
    end

    -- Never used
    function door:SetClosed(closed)
        self:SetOpened(not closed)
    end

    return door -- Returns door object
end

-- Removes the wall at the slot number s
function Maze:OpenDoor(s)
    --Log("Freeing Slot: %d", s)
    self:FreeSlot(s);
    --Log("Freed")
end

-- Returns a list of adjacent rooms to the room at coordinates (x,y) that have not yet been visited
-- Validator is a function that can be passed in to determine if room has been visited
    -- different validator functions could produce interesting effects...
function Maze:DirectionsFrom(x, y, validator)
    local directions = {} -- List of unvisted adjacent rooms to (x,y)
    validator = validator or function() return true end
    
    --  calculate the coordinates to the adjacent room in each direction (North, East, South, West)
        -- Name is thus either North, East, South, or West
        -- Shift becomes the coordinate adj to get there
            -- E.g. name = North, Shift = {x=0, y=-1}
    for name, shift in pairs(self.directions) do
        local x,y = x + shift.x, y + shift.y    -- x = x+ ajustX,   y = y+ adjstY (Ex: north -> x= x+0, y= y-1)
        
        -- If its a valid coordinate (within graph bounds) and not visited (validator function)
        if self[y] and self[y][x] and validator(self[y][x], x, y) then
            -- add coordinates to that adjacent room to list of unvisted adjacent rooms
            directions[#directions+1] = {name = name, x = x, y = y}
        end
    end
    
    return directions  -- Return list of coordinates for unvisted adjacent rooms.
end



-- Returns number of open room (no walls/walls inf thin) wide
function Maze:width()
    local Properties = Maze.Properties;
    local width = Properties.iWidth
    return width
end

-- Returns number of open room high
function Maze:height()
    local Properties = Maze.Properties;
    local height = Properties.iHeight
    return height
end

-- OOO Buddy, the fun part, picking the doors to unlock to make a maze
    -- This is the growing tree algorithm...
        --[[
            "
            1) Let C be a list of cells, initially empty. Add one cell to C, at random.
            2) Choose a cell from C, and open door to any unvisited adjacent room of that cell, adding that neighbor to C as well. If there are no unvisited neighbors, remove the cell from C.
            3) Repeat #2 until C is empty.
            
            fun lies in how you choose the cells from C, in step #2. If you always choose the newest cell (the one most recently added), you’ll get the recursive backtracker. 
            If you always choose a cell at random, you get Prim’s. It’s remarkably fun to experiment with other ways to choose cells from C.
            " 
                - The Buck Blog
                
             Thus in this implementation, you can change, how C is selected in step 2 by specifying a selector function
             The default is a random Cell, which gives us Prim's algorithm
        ]]
function Maze:GrowingTree(selector)

    selector = selector or function (list) return random(#list) end
    local cell = { x = random(self.width()), y = random(self.height()) } -- Select a random cell (Step 1)
    self[cell.y][cell.x].visited = true -- Mark as visited
    local list = { cell } -- Add random cell to list (also step 1)
    
    local width = self:width()

    -- Until all neighboring cells have been visited
    while #list ~= 0 do
        local rnd_i = selector(list)
        cell = list[rnd_i]  -- Step 2, choose random cell from list (Prim's alg)

        -- Step 2, Get list of unvisted adjacent cells.
        local directions = self:DirectionsFrom(cell.x, cell.y, function (cell) return not cell.visited end)

        -- If only 1 way left to go
        if #directions < 2 then
            list[rnd_i] = list[#list]
            list[#list] = nil
        end
        
        -- If multiple ways to go
        if #directions ~= 0 then 
        
            --Log("Visiting (%d, %d)", 2*cell.x, 2*cell.y);
            --Log("This is slot: %d", (2*cell.y-1)*(2*width+1) + 2*cell.x);
            
            -- local var that tells us which direction we went (North, East, South, or West)
            local dirn = directions[random(#directions)]
                       
            --Log("Going direction " .. dirn.name .. "To the cell (%d, %d), which is slot: %d", dx*2, dy*2, (2*dy-1)*(2*width+1) + 2*dx);
            
            local incX = self.directions[dirn.name].x;
            local incY = self.directions[dirn.name].y;
             
            --Log("Need to open (%d, %d)", cell.x*2 + incX, cell.y*2 + incY);
            local s = (cell.y*2+incY-1)*(2*width+1) + 2*cell.x+incX;  -- Find the slot number of the closed door in the way to get to the chosen adjacent cell.
            --Log("Which is Slot: %d", s);
            
            self[cell.y][cell.x][dirn.name]:Open()  -- Mark door as opened
            self[dirn.y][dirn.x].visited = true     -- Mark cell as visited
            
            self:OpenDoor(s);                       -- Remove wall in world that represented the door
            
            list[#list + 1] = { x = dirn.x, y = dirn.y }  -- Add the new room just visted to list of cells that we can start branching out from
        end

    end
    
   
end

function Maze:PhysicalizeWallSlots()  
    local width, height = self:width()*2 + 1, self:height()*2+1
 
    for i = 1, width*height do 
            if(self:IsSlotValid(i)) then
                self:PhysicalizeSlot(i,  {mass=0});
            end
    end 
 
end