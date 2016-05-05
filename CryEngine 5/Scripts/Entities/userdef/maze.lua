----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Maze = {
  type = "Maze",                                   -- can be useful for scripting

  -- Directions in maze (For example: Going north from current position means going up 1 in y axis)
    directions = {
        north = {x = 0, y = 1},
        east = {x = 1, y = 0},
        south = {x = 0, y = -1},
        west = {x = -1, y = 0},
    },
    
  -- Instance vars
  Width = 0,
  Height = 0,
  Map = "",
  Model_Width = 0,
  Model_Height = 0,
  Model = "",
  CorridorSize = 0,
  
  --[[Mitchels stuff copied from basic entity in Lumberyard
	-- Copied from BasicEntity.lua
  Properties = {
     bUsable = 0,
	 iM_Width = 20,
     iM_Height = 20,
	 --object_Model = "objects/default/primitive_cube.cgf",
	 
	 object_Model = "objects/default/primitive_sphere.cgf",
     
     file_map_txt = "Scripts\\Entities\\maps\\map_default.txt",
     bMap_Save_TXT = 0,
     iM_CorridorSize = 1,
     
     --Copied from BasicEntity.lua
     Physics = {
        bPhysicalize = 1, -- True if object should be physicalized at all.
        bRigidBody = 1, -- True if rigid body, False if static.
        bPushableByPlayers = 1,
    
        Density = -1,
        Mass = -1,
     },
  }, 
  
  ]]
  
  --copied from cryengine 5 basic entitiy
  -- Copied from BasicEntity.lua 
  Properties = {
  
		bUsable = 0,
		iM_Width = 5,
		iM_Height = 5,
		
		iM_CorridorSize = 1,
		
		--soclasses_SmartObjectClass = "",
		--bAutoGenAIHidePts = 0,
		--bMissionCritical = 0,
		--bCanTriggerAreas = 0,
		--DmgFactorWhenCollidingAI = 1,
				
		--object_Model = "objects/default/primitive_sphere.cgf",
		
		object_Model = "objects/default/primitive_cube.cgf",
		
		--copied from basic entity
		Physics = {
			bPhysicalize = 1, -- True if object should be physicalized at all.
			bRigidBody = 1, -- True if rigid body, False if static.
			bPushableByPlayers = 1,
		
			Density = -1,
			Mass = -1,
		},
		MultiplayerOptions = {
			bNetworked		= 0,
		},
		
		bExcludeCover=0,
	},
  
  

  -- optional editor information taken from BasicEntity.lua
  Editor = {
	 	--Icon = "physicsobject.bmp",
		IconOnTop=1,
  },
  
    -- Read in Maze File to lines:
  Lines = {},
};

-- I DUNNO WTF THIS IS I COPIED FROM BasicEntity.lua
local Physics_DX9MP_Simple = {
	bPhysicalize = 1, -- True if object should be physicalized at all.
	bPushableByPlayers = 0,
		
	Density = 0,
	Mass = 0,
		
}

-- I dunno, make it usable?
--MakeUsable(Maze);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Entity State Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- Order of Events: (Spawn) -> (Init)

--[[
function Maze:OnSpawn()
    Log("OnSpawn is running");
    --self:OnReset();
end
]]

function Maze:OnInit()
    Log("OnInit is running");
    self.Width = self.Properties.iM_Width
    self.Height = self.Properties.iM_Height
	
	local width = 0;
	
	Log("number of cells: %d", self.Width * self.Width);
	
    self.Map = self.Properties.file_map_txt
    self.Model = self.Properties.object_Model
    self.CorridorSize = self.Properties.iM_CorridorSize
    --self:OnReset()
    
    self:SetupModel()
    self:New()    
    
end

function Maze:OnPropertyChange()
    Log("OnPropertyChange is running");
    
    self:SetFromProperties();
    --self:OnReset();
   -- self:SetupModel()
    self:New()
end

function Maze:OnReset()
    Log("OnReset is running");
    --self:SetupModel()
    --self:New()
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Maze:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity
        
            local v1, v2 = self:GetLocalBBox()
            self:GetModelDimensions(v1,v2);
        
        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
    end
    
        --Log("Width = %d, Height = %d", Properties.iM_Width, Properties.iM_Height)
end

function Maze:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		Physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function Maze:SetFromProperties()
    Log("In SetFromProperties")
    
	local Properties = self.Properties;
	
	if (Properties.object_Model == "") then
		do return end;
	end
    
    -- Free Slots no longer in use
    local width, height, map, model, corSize = Properties.iM_Width, Properties.iM_Height, Properties.file_map_txt, Properties.object_Model, Properties.iM_CorridorSize
    Log("local width = %d, local height = %d", width, height)
    Log("Old Width = %d, Old Height = %d", self.Width, self.Height)
    Log("Old Map: "..self.Map..", New Map: "..map);
   
    if (corSize ~= 1) then
        self.Properties.iM_Height = width;
        height = width;
    end
   
    if (width < self.Width) or (height < self.Height) or (self.Map ~= map) or (model ~= self.Model) or (corSize ~= self.CorridorSize) then 
	   --self:FreeAllSlots();
       local totalSlots = (self.Width*2+1)*(self.Height*2+1)
       for i=1, totalSlots do
           self:FreeSlot(i)
       end
       Log("Freed all slots")
    end
    
	
    self.Width = width
    self.Height = height
    self.Map = map
    self.Model = model
    self.CorridorSize = corSize
    
    self:SetupModel();

end


----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze Helper  Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

--Fills in border of maze with blocks
function Maze:Border()

	Log("In border");

    -- Get Height and Width
    local corridorSize = self:corridorSize();
    local height = 1+ (self:height()*(corridorSize+1));       
    local width = 1+ (self:width()*(corridorSize+1));
	
	Log("height: %d, width %d", height, width);
        
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
    
    local bGap = corridorSize+1
    -- Create Border
    for y=1, height, bGap do 
        for x=1, width, bGap do
            
            self:Wall(x,y); -- This function takes an x and y coord on the graph and fills in a wall
            
        end
    end
end

-- fills in "doors" of maze with blocks
    --Never actually used, made for testing purposes
function Maze:DoorSpawn()
    
    local corridorSize = self:corridorSize();
    local height = 1+ (self:height()*(corridorSize+1));       
    local width = 1+ (self:width()*(corridorSize+1));
    
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
    
    local dGap = corridorSize+1;
    -- For Each Room:
    for y = 1, height, dGap do
        for x=1, width, dGap do 
            -- Door Bottom & Left
                for i = 1, corridorSize do
                    --Log("Dooring (%d, %d)", x+i, y)
                    if(x+i <= width) then
                        self:Wall(x+i, y)
                    end
                   -- Log("Dooring (%d, %d)", x, y+i)
                    if(y+i <= height) then
                        self:Wall(x, y+i)
                    end
                end 
        end
    end 
    
end

-- Fills a block ( a wall) in at coordinates (w,h), (TAKES THE 2X,2Y COORDS)
function Maze:Wall(w, h)

        local Properties = self.Properties;
        local width = 1+ self:width()*(self:corridorSize()+1)
        local nSlot = (h-1)*width + w;
        
        local objX = self.Model_Width;
        local objY = self.Model_Height;
        
        --Log("ObjX %d, ObjY %d", objX, objY);
        
		--Log("nslot: %d", nSlot);
		
		--this was eating up all my memory :(
		--TODO: Uncomment this
        self:LoadObject(nSlot, Properties.object_Model);
		
		
        -- So guess what, actual world coordinates requires further manipulation
        --self:SetSlotPos(nSlot, {x=2*(w-1),y=2*(h-1),z=0});
        
		--TODO: uncomment this
		self:SetSlotPos(nSlot, {x=objX*(w-1),y=objY*(h-1),z=0});

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
        
		--TODO: uncomment this
		self:DrawSlot(nSlot,1);
end

-- Alright, main maze gen code that calls other helper function
function Maze:New()
    Log("In New");
    
    local Properties = self.Properties;
	local success = false;
	
	--[[ this loading is fucking me up -Amal
	if (Properties.file_map_txt ~= "") then
        Log("Map property isn't empty");
        success = self:ReadMaze();
        --Properties.file_map_txt = "";
    end
	
	]]
    
    if (not success) then
        Log("Map property was empty");
        obj = obj or {}         -- Our 2d array that is the graph version of the maze with infinitesimally thin walls... so (1,1) is actually Room 1, which is really at (2,2) in the world
        setmetatable(obj, self)
        self.__index = self
        
        local width = self:width()   -- Returns width of graph with infinitesimally thin walls, so essentially its #rooms wide, not actual width which would be width*2+1
        local height = self:height() -- #rooms tall
        
        self:Border(); -- Fill in border cells with walls
        self:DoorSpawn();
        -- Setup Maze
            -- For each room in 2d array, record that there is a closed door (i.e. wall) in each direction
            -- Effectively doing what DoorSpawn() does, filling in remaining walls
        for y = 1, height do
            obj[y] = {}
            for x = 1, width do
                obj[y][x] = { east = obj:CreateDoor(true ), north = obj:CreateDoor(true)}
                --CreateDoor records that there is a wall there via bool value in 2d array that is obj[y][x], and fills wall in in actual 3D real world graph
                                            
            -- Doors are shared beetween the cells to avoid out of sync conditions and data dublication
            if x ~= 1 then obj[y][x].west = obj[y][x - 1].east
            else obj[y][x].west = obj:CreateDoor(true) end
            
            if y ~= 1 then obj[y][x].south = obj[y -1 ][x].north
            else obj[y][x].south = obj:CreateDoor(true) end
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
end

--Door class/ called to create doors
    -- Records there is a door adjacent to room in obj (The 2d graph with infinitesimally small walls)
    -- Fills in the real world coordinates with a wall
function Maze:CreateDoor(closed, h, w)

    local door = {}
    door.closed = closed and true or false -- records that door is closed  (e.g. door=true)
    
   -- self:Wall(w,h)  -- Fills in block object in world at real world coordinates (w,h)
    
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
    local Properties = self.Properties;
    local width = Properties.iM_Width
    return width
end

-- Returns number of open room high
function Maze:height()
    local Properties = self.Properties;
    local height = Properties.iM_Height
    return height
end

function Maze:corridorSize()
    local Properties = self.Properties;
    local cSize = Properties.iM_CorridorSize
    return cSize
end

-- OOO Buddy, the fun part, picking the doors to unlock to make a maze
    -- This is the growing tree algorithm...
        --[[
            "
            1) Let C be a list of cells, initially empty. Add one cell to C, at random.
            2) Choose a cell from C, and open door to any unvisited adjacent room of that cell, adding that neighbor to C as well. If there are no unvisited neighbors, remove the cell from C.
            3) Repeat #2 until C is empty.
            
            fun lies in how you choose the cells from C, in step #2. If you always choose the newest cell (the one most recently added), you�ll get the recursive backtracker. 
            If you always choose a cell at random, you get Prim�s. It�s remarkably fun to experiment with other ways to choose cells from C.
            " 
                - The Buck Blog
                
             Thus in this implementation, you can change, how C is selected in step 2 by specifying a selector function
             The default is a random Cell, which gives us Prim's algorithm
        ]]
function Maze:GrowingTree(selector)
    Log("In GrowingTree");
    selector = selector or function (list) return random(#list) end
    local cell = { x = random(self:width()), y = random(self:height()) } -- Select a random cell (Step 1)
    self[cell.y][cell.x].visited = true -- Mark as visited
    local list = { cell } -- Add random cell to list (also step 1)
    
    local width = self:width()
    local corridorSize = self:corridorSize()
    local realWidth = 1+ width*(self:corridorSize()+1)

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
             
            local nX, nY = self:CoordTransform(cell.x, cell.y)
            
            if (incX > 0) then 
                incX = incX*corridorSize
            elseif (incY > 0) then 
                incY = incY*corridorSize
            end 
            
            local s = ((nY-1)+incY)*(realWidth) +nX+incX; -- Slot of first door
            self:OpenDoor(s);
            
            for d=2, corridorSize do
                -- Free East or West doors...
                if (incX ~= 0) then 
                    s = s+realWidth
                elseif (incY ~= 0) then -- Free North or south doors
                    s = s+1
                end
               
                self:OpenDoor(s);                       -- Remove wall in world that represented the door
            end
            
            self[cell.y][cell.x][dirn.name]:Open()  -- Mark door as opened
            self[dirn.y][dirn.x].visited = true     -- Mark cell as visited
            list[#list + 1] = { x = dirn.x, y = dirn.y }  -- Add the new room just visted to list of cells that we can start branching out from
        end

    end
        
   -- Save generated map in maps folder
   if self.Properties.bMap_Save_TXT == 1 then
        Log("Saving...");
        self:PrintMaze();
   end

end

function Maze:PhysicalizeWallSlots()  
    local width, height = 1+ self:width()*(self:corridorSize()+1), 1+self:height()*(self:corridorSize()+1)
 
    for i = 1, width*height do 
            if(self:IsSlotValid(i)) then
                self:PhysicalizeSlot(i,  {mass=0});
            end
    end 
 
end


    -- Takes what is in obj and prints it out to a txt file
function Maze:PrintMaze(txtName) -- Optional parameter to name map
    Log("In PrintMaze");
    local width = self:width()--*2+1;
    local height = self:height()--*2+1;
    
    local realWidth = 1+width*(self:corridorSize()+1)
    local start_path = "C:\\Amazon\\Lumberyard\\1.1.0.0\\dev\\GameSDK\\Scripts\\Entities\\maps\\";

    --local all_maps = self:Scandir(start_path);
    --local num_maps = #all_maps;
    
    local txt = txtName or "map_".."temp"

    Log("txt is: "..txt);
    local path = start_path..txt..".txt";
    Log("path is: "..path);
    local file = io.open(path, "w");
    
    io.output(file)
    local corSize = self.CorridorSize;
    local corridorSizeSetting = "S= "..corSize.."\n"
    file:write(corridorSizeSetting)
    
   -- Top border
    for x = 1, realWidth do
        file:write("X");
    end
    file:write("\n");
    
    local curLine = ""
    -- Insides
    for y = height, 1, -1 do 
        curLine = ""
        for x = 1, width do
        
            -- Fill in walls by checking if there is a door to the west
            if(self[y][x].west.closed) then 
                --file:write("XO")
                curLine = curLine.."XO"
            else
                --file:write("OO")
                curLine = curLine.."OO"
            end
            -- Add additional corridor Width Size 
            for d=2, corridorSize do
                --file:write("O")
                curLine = curLine.."O"
            end
            
            -- Edge case (Must fill in right vertical border)
            if(x == width) then
                --file:write("X")
                curLine = curLine.."X"
            end 
            
        end
        curLine = curLine.."\n"
        for d=1, corridorSize do
            file:write(curLine)
        end
        
        curLine = "X"
        -- Next Line, vertical border left side
        --file:write("\n");
       -- file:write("X");
        
        for x = 1, width do 
            
            if(self[y][x].south:IsClosed()) then 
                --file:write("XX")
                for d=1, corridorSize+1 do
                    curLine = curLine.."X"
                end
            else 
                --file:write("OX")
                for d=1, corridorSize do
                    curLine = curLine.."O"
                end
                curLine = curLine.."X"
            end 
            
        end 
        
        curLine = curLine.."\n"
        
        file:write(curLine);
        
    end
    
    io.close(file)
    
    local Properties = self.Properties;
    Properties.file_map_txt = "Scripts\\Entities\\maps\\"..txt..".txt";
    
end

-- Reads in a txt file maze and creates it in the world
function Maze:ReadMaze(my_maze_file)

    Log("In ReadMaze");
    
    local file_str;
    local Properties = self.Properties;
    
    -- Open a file for read and test that it worked
    local file_str = my_maze_file or self.Properties.file_map_txt;
    --Log(file_str);
    
    local path = "C:\\Amazon\\Lumberyard\\1.1.0.0\\dev\\GameSDK\\"..file_str;--..".txt";
    local file, err = io.open(path, "r");
    if err then Log("Maze file does not exist");  return false; end
    
    Log("Opened Map.txt");
    
    io.input(file);
    -- Line by line
    local lines = {}
    for line in io.lines() do 
        lines[#lines + 1] = line
    end
    
    if #lines > 0 then
        Maze.Lines = lines
    end 
        
    --file:close();
    io.close(file);
    
    -- Get CorSize if it exists
    local corSize = 1
    local h, w = 0,0
    local cSizeSetting = lines[1]
    if (cSizeSetting.sub(1, 3) == "S= ") then
        h = 1
        corSize = tonumber(cSizeSetting.sub(3, -1))
    end
    
    -- Set iWidth and iHeight
    Properties.iM_Height =   ((#lines - h)-1)/(corSize+1)
    Properties.iM_Width = (#lines[2]-1)/(corSize+1)
    Properties.iM_CorridorSize = corSize
    
    -- Call setFromProperties
    self:SetFromProperties();
    
    self:LinesToWorld(lines);
    
    return true;
end

-- takes a 2D array Maze and creates it in world
function Maze:LinesToWorld(map_lines)
    
    Log("In LinesToWorld");
    
    local corridorSize = self:corridorSize()
    local lines = map_lines or Maze.Lines;
    local width = #lines[1]
    local height = #lines
    
    for k,v in pairs(lines) do
        --print('line[' .. k .. ']', v)
        for i = 1, #v do
            local c = v:sub(i,i)
            
            if (c == "X" ) then
                self:Wall(i, height+1-k);
            end
            
        end
    end
    
    self:PhysicalizeWallSlots();
    
end

function Maze:GetModelDimensions(v1, v2)
    local v = { x=0, y=0, z=0}
    SubVectors(v, v2, v1)
    self.Model_Width = v.x
    self.Model_Height = v.y;
    Log("Model_Width = %d, Model_Height = %d", v.x, v.y);
end

-- Determine Map numbers 
-- Lua implementation of PHP scandir function
function Maze:Scandir(directory)
    Log("In ScanDir")
    local i, t, popen = 0, {}, io.popen                 -- POPEN NOT SUPPORT ARRRRGH
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function Maze:CoordTransform(x,y)
    local Properties = self.Properties;
    local corridorSize =  Properties.iM_CorridorSize;
    
    local nX = 2*x + ((corridorSize-1)*(x-1))
    local nY = 2*y + ((corridorSize-1)*(y-1))
    return nX, nY
end