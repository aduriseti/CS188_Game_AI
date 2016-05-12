----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    LivingEntity Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

LivingEntityBase = {
  
  type = "LivingEntity",                                   -- can be useful for scripting
  
  -- Instance Vars
   -- entID = "",
    angles = 0, 
    pos = {},
    --state = "",

   Properties = {
        bUsable = 0,
        object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.1;
        
		maze_ent_name = "",         --maze_ent_name = "Maze1",
        
        bActive = 0,
        
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
	 	Icon = "Checkpoint.bmp",
		IconOnTop=1,
  },
  
  Player_Properties = {
		ent_type = "Player",
		ID = "",
	},
    
    Maze_Properties = {
        ent_type = "Maze2",
        ID = "",
        cell_width = -1,
        cell_height = -1,
        width = -1,
        height = -1,
        corridor_width = -1,
        model_width = -1,
        model_height = -1,
        directions = {},
        
        grid = {},
    },
    
    directions = {
			none = {row_inc = 0, col_inc = 0, name = "none"},
			up = {row_inc = 1, col_inc = 0, name = "up"},
			down = {row_inc = -1, col_inc = 0, name = "down"},
			right = {row_inc = 0, col_inc = 1, name = "right"},
			left = {row_inc = 0, col_inc = -1, name = "left"}
		},
		
	direction = {row_inc = 0, col_inc = 0},
};

-- I DUNNO WTF THIS IS I COPIED FROM BasicEntity.lua
local Physics_DX9MP_Simple = {
	bPhysicalize = 1, -- True if object should be physicalized at all.
	bPushableByPlayers = 0,
		
	Density = 0,
	Mass = 0,	
}

---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:OnInit() 
    self:OnReset();
end

function LivingEntityBase:OnPropertyChange() 
	Log("In OnPropertyChange");
    self:OnReset();
end

function LivingEntityBase:OnReset()
    self:SetFromProperties()  
    self:abstractReset()
end

-- This abstract reset is empty in Base, it purely exists if you want extra functionality from reset in subclass
function LivingEntityBase:abstractReset()
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity

        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
    end
    
    --[[
    if (self.Properties.entName ~= "") then 
        self.entID = System.GetEntityByName(self.Properties.entName); 
        Log(tostring(self.entID));
        Log(self.entID.type);
    end 
    ]]
    
end

function LivingEntityBase:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		Physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function LivingEntityBase:SetFromProperties()
    
    self:SetupModel();

    self.angles = self:GetAngles(); --gets the current angles of Rotating
    self.pos = self:GetPos(); --gets the current position of Rotating
    self.pos.z = 33
    self:SetPos({self.pos.x, self.pos.y, self.pos.z})
    
	local Properties = self.Properties;
	if (Properties.object_Model == "") then
		do return end;
	end
    
    local nearby_entities = System.GetEntities(self.pos, 100)
    --[[
    if (self.entID == "") then 
        for key, value in pairs( nearby_entities ) do
            if (tostring(value.type) == Properties.type) then
                self.entID = value;
            end
        end
    end
    ]]
    --if the user has specified the name of an entity to target, use that
    if (self.Properties.maze_ent_name ~= "") then 
        self.mazeID = System.GetEntityByName(self.Properties.maze_ent_name); 
    --else use the first Maze2 found in a radius of 1000 game measurement units (meters?)
    else 
        for key, value in pairs( nearby_entities ) do
            if (tostring(value.type) == "Maze2") then
                self.Maze_Properties.ID = value;
            end 
        end
    end
    
    if (self.Maze_Properties.ID == "") then
        Log("Error: LivingEntityBase unable to locate maze");
        return;
    end
    
    self:SetupMaze()

    if(self.Player_Properties.ID == "") then
        for key, value in pairs( nearby_entities ) do
            if (tostring(value.type) == "Player") then
                self.Player_Properties.ID = value;
            end 
        end
    end
    
    self.direction = self.directions.none
    
    self:Activate(self.Properties.bActive); --set OnUpdate() on/off
    

end

function LivingEntityBase:SetupMaze()
    --populate Maze_Properties and put LivingEntityBase in maze
    --populate Maze Properties
    self.Maze_Properties.cell_height = self.Maze_Properties.ID:height();
    self.Maze_Properties.cell_width = self.Maze_Properties.ID:width();
    self.Maze_Properties.height = (self.Maze_Properties.ID:height()*(self.Maze_Properties.ID:corridorSize() + 1) + 1);
    self.Maze_Properties.width = (self.Maze_Properties.ID:width()*(self.Maze_Properties.ID:corridorSize() + 1) + 1);
    self.Maze_Properties.directions = self.Maze_Properties.ID.directions;
    self.Maze_Properties.model_height = self.Maze_Properties.ID.Model_Height;
    self.Maze_Properties.model_width = self.Maze_Properties.ID.Model_Width;
    self.Maze_Properties.corridor_width = self.Maze_Properties.ID.corridorSize;
        
    if #self.Maze_Properties.grid ~= self.Maze_Properties.height then
        self.Maze_Properties.grid = {};
        for row = 1, self.Maze_Properties.height do
            self.Maze_Properties.grid[row] = {};
            for col = 1, self.Maze_Properties.width do
                local cur_nslot = self.Maze_Properties.ID:rowcol_to_nslot(row, col);
                local cur_wall = self.Maze_Properties.ID.myWalls[cur_nslot];

                if cur_wall ~= nil then
                    self.Maze_Properties.grid[row][col] = {occupied = true, nslot = cur_nslot};
                else
                    self.Maze_Properties.grid[row][col] = {occupied = false, nlsot = -1};
                end
            end
        end
    end	

    (function ()

        for row = 1, self.Maze_Properties.height do
            for col = 1, self.Maze_Properties.width do
                if self.Maze_Properties.grid[row][col].occupied == false then
					--Log("put living entity in maze");
					--local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row, col);
                    self:move_xy(self.Maze_Properties.ID:rowcol_to_pos(row, col));
                    --self:SetPos({target_pos.x, target_pos.y, 33});
					return;
                end
            end
        end

    end ) ()
end
----------------------------------------------------------------------------------------------------------------------------------
-------------------------              Movement Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:move_xy(xy)
	--Log("x " .. tostring(self.pos.x));
	self:SetPos({xy.x, xy.y, self.pos.z});
	self.pos.x = xy.x;
	--Log("x " .. tostring(self.pos.x));
	self.pos.y = xy.y;
end

function LivingEntityBase:Move_to_Pos(frameTime, pos) 
	local a = self.pos;
	local b = pos;
	self:FaceAt(b, frameTime);
	local diff = {x = b.x - a.x, y = b.y - a.y};
	
	--[[
	Log("xdiff: " .. tostring(diff.x));
	Log("ydiff: " .. tostring(diff.y));
	]]--
	
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);

	local speed_mag = self.Properties.m_speed / diff_mag;
	self:move_xy({x = a.x + diff.x * speed_mag,
		y = a.y + diff.y * speed_mag});
	
end

function LivingEntityBase:FaceAt(pos, fT)
    local a = self.pos;
    local b = pos;
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.fRotSpeed*fT));  
    self:SetAngles(self.angles);

end

function LivingEntityBase:FollowPlayer(frameTime)
	self:FaceAt(self.Player_Properties.ID:GetPos(), frameTime);
	local a = self.pos;
	local b = self.Player_Properties.ID:GetPos();
	local diff = {x = b.x - a.x, y = b.y - a.y};
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
	if diff_mag < 5 then
		return;
	end
	local speed_mag = self.Properties.m_speed / diff_mag;
	self:move_xy({x = a.x + diff.x * speed_mag,
		y = a.y + diff.y * speed_mag});
	
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------              Movement Algorithms                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:turnLeftAlways()
	--STATUS: Not finished for maze2

	local rowcol = LivingEntityBase.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	local row = rowcol.row;
	local col = rowcol.col;

end

function LivingEntityBase:depthFirstSearch()

	--STATUS: Not finished for any maze

end

function LivingEntityBase:randomWalk() 

	--STATUS: Cryengine only - will push when works with lumberyard

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	local row = rowcol.row;
	local col = rowcol.col;

end

function LivingEntityBase:getUnoccupiedNeighbors(loc_row, loc_col)
	
	local grid = self.Maze_Properties.grid
	local empty_neighbors = {};
	
	for key,value in pairs(self.directions) do
		local row_index = value.row_inc + loc_row
		local col_index = value.col_inc + loc_col
		
		if row_index > 0 and col_index > 0 and row_index <= #grid and col_index <= #grid[1] then 
			--Log("row_index = %d, col_index = %d", row_index, col_index)
			
			if grid[row_index][col_index].occupied == false then
				--Log("continue moving in same direction");
				--Log(tostring(loc_row + loc_row_inc));
				--Log(tostring(loc_col + loc_col_inc));
				empty_neighbors[#empty_neighbors+1] = {row =row_index, col = col_index, direction = value};
				--Log(tostring(#empty_neighbors));
			end
		end
	end
	
	return empty_neighbors;
end

function LivingEntityBase:getLeftRight()
	local dir = self.direction;
	local dirs = self.directions;
	if dir.name == "up" then
		return dirs.left, dirs.right;
	elseif dir.name == "down" then
		return dirs.right, dirs.left;
	elseif dir.name == "left" then 
		return dirs.up, dirs.down;
	elseif dir.name == "right" then
		return dirs.down, dirs.up;
	else
		return nil;
	end
end

function LivingEntityBase:randomDirectionalWalk(frameTime)
	--Cryengine
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	
	local row = rowcol.row;
	local col = rowcol.col;
	
	local loc_row_inc = self.direction.row_inc;
	local loc_col_inc = self.direction.col_inc;
	
	
	if loc_row_inc ~= 0 or loc_col_inc ~= 0 then
		if self.Maze_Properties.grid[row+loc_row_inc][col+loc_col_inc].occupied == false then
			--Log("continue moving in same direction");
			local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
			self:Move_to_Pos(frameTime, target_pos);
			return;
		end
	end
	
	local empty_neighbors = self:getUnoccupiedNeighbors(row, col);

	--[[
	Log("row: " .. tostring(row));
	Log("col: " .. tostring(col));

	Log(tostring(self.Maze_Properties.grid[row][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row + 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row - 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col + 1].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col - 1].occupied));
	
	Log(tostring(#empty_neighbors));
	Log(tostring(frameTime))
	--]]
	
	-- TODO: AMAL FOR SOME REASON SOMETIMES THIS GETS CALLED WITH NIL VALs
		--commenting out last 3 lines of this function is a fix - don't ask me why
	--local empty_neighbors = self:getUnoccupiedNeighbors(row, col);
	
	
	local rnd_idx = random(#empty_neighbors);
	--if rnd_idx >1 then rnd_idx = rnd_idx-1 end
	self.direction = empty_neighbors[rnd_idx].direction;
	--local target_cell = empty_neighbors[rnd_idx];
	--local target_pos = self.Maze_Properties.ID:rowcol_to_pos(target_cell.row, target_cell.col);
	--self:Move_to_Pos(frameTime, target_pos);
end

--function which makes living entity patrol the straight line pathway its spawned in
function LivingEntityBase:bounce(frameTime)
	--Cryengine
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	
	local row = rowcol.row;
	local col = rowcol.col;
	
	local loc_row_inc = self.direction.row_inc;
	local loc_col_inc = self.direction.col_inc;
	

	if loc_row_inc ~= 0 or loc_col_inc ~= 0 then
		if self.Maze_Properties.grid[row+loc_row_inc][col+loc_col_inc].occupied == false then
			--Log("continue moving in same direction");
			local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
			self:Move_to_Pos(frameTime, target_pos);
			return;
		else
			--reverse direction if living enity has one
			self.direction = {row_inc = -loc_row_inc, col_inc = -loc_col_inc};
		end
	end
	
	--choose random starting direction
	local empty_neighbors = self:getUnoccupiedNeighbors(row, col);
	local rnd_idx = random(#empty_neighbors);
	self.direction = empty_neighbors[rnd_idx].direction;
end	


function LivingEntityBase:directionalWalk(frameTime)

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	
	local row = rowcol.row;
	local col = rowcol.col;
	
	local loc_row_inc = self.direction.row_inc;
	local loc_col_inc = self.direction.col_inc;
	
	if loc_row_inc ~= 0 or loc_col_inc ~= 0 then
		if self.Maze_Properties.grid[row+loc_row_inc][col+loc_col_inc].occupied == false then
			--Log("continue moving in same direction");
			local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
			self:Move_to_Pos(frameTime, target_pos);
			return;
		end
	end
	
	for key,value in pairs(self.directions) do
		loc_row_inc = value.row_inc;
		loc_col_inc = value.col_inc;
		if self.Maze_Properties.grid[row+loc_row_inc][col+loc_col_inc].occupied == false then
			--Log("continue moving in same direction");
			self.direction = {row_inc = loc_row_inc, col_inc = loc_col_inc};
			local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
			self:Move_to_Pos(frameTime, target_pos);
			return;
		end
	end

end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------              Utility Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Mouse:PrintTable(t)

    local print_r_cache={}

    local function sub_print_r(t,indent)

        if (print_r_cache[tostring(t)]) then

            Log(indent.."*"..tostring(t))

        else

            print_r_cache[tostring(t)]=true

            if (type(t)=="table") then

                for pos,val in pairs(t) do

                    if (type(val)=="table") then

                        Log(indent.."["..pos.."] => "..tostring(t).." {")

                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))

                        Log(indent..string.rep(" ",string.len(pos)+6).."}")

                    elseif (type(val)=="string") then

                        Log(indent.."["..pos..'] => "'..val..'"')

                    else

                        Log(indent.."["..pos.."] => "..tostring(val))

                    end

                end

            else

                Log(indent..tostring(t))

            end

        end

    end

    if (type(t)=="table") then

        Log(tostring(t).." {")

        sub_print_r(t,"  ")

        Log("}")

    else

        sub_print_r(t,"  ")

    end

    --Log()

end