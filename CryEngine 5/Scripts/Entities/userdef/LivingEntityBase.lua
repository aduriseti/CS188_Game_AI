----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    LivingEntity Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

LivingEntityBase = {

  type = "LivingEntity",                                   -- can be useful for scripting

  -- Instance Vars
   -- entID = "",
    angles = 0, 
    pos = {},
	dimensions = {},
	
   Properties = {

        bUsable = 0,
        --object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.1;       

		maze_ent_name = "",         --maze_ent_name = "Maze1",

        bActive = 1,

        Physics = {

            --bPhysicalize = 1, -- True if object should be physicalized at all.
           -- bRigidBody = 1, -- True if rigid body, False if static.
            --bPushableByPlayers = 1,

			
            --Density = -1,
            mass = 10,
			flags = 0,
			stiffness_scale = 73,
			
			--Living:
			Living = {
				height = 0, -- vertical offset of collision geometry center
				--size = {x=1,z=0.5}, --collision cylinder dimensions, a vector WTF WONT WORK U PIECE OF SHIT
				size = {x=2.4,y=2.4,z=0.8},
				--height_eye = , --vertical offset of the camera
				--height_pivot = , -- offset from central ground position that is considered the entity center
				--height_head = , -- vertical offset of the head
				inertia = 5.0, -- inertia coefficient, higher means less inertia, 0 means no inertia
				inertiaAccel = 8.0, -- Same as inertia, but used when the player accel
				air_resistance = 0.2, -- air control coefficient, 0.0-1.0, where 1 is special (total control of movement)
				gravity = 9.81, -- vertical gravity magnitude
				mass = 10, -- in kg
				min_slide_angle = 30, --  if surface slope is more than this angle (in radians), player starts sliding
				max_climb_angle =30 , -- player cannot climb surface with slope steeper than this angle, in radians
				--max_jump_angle = , -- player cannot jump towards ground if this angle is exceeded
				min_fall_angle = 70, -- player starts falling when slope is steeper than this, in radians
				max_vel_ground = 100, -- player cannot stand on surfaces that are moving faster than this
				--colliderMat = "mat_player_collider",
				--useCapsule=0,
			},
			
			-- Area:
			Area = {
				type = AREA_BOX, -- type of the area, AREA_BOX, AREA_SPHERE, AREA_GEOMETRY, AREA_SHAPE, AREA_CYLINDER, AREA_SPLINE
				--radius = , radius of the area sphere, required if the area type is AREA_SPHERE
				box_min = {x=0,y=0,z=0}, --min vector of the bounding box, rquired if the area type is AREA_BOX
				box_max = {x=0,y=0,z=0}, -- max vector of the bounding box, rquired if the area type is AREA_BOX
				--points = {}, -- table containing collection of vectors in local entity space defining the 2D shape of the area, if the area type is AREA_SHAPE
				--height = 0, -- height of the 2D area, relative to the minimal Z in the points table, if the area type is AREA_SHAPE
				--uniform = , -- same direction in every point or always point to the center
				--falloff = , --ellipsoidal falloff dimensions, a vector. zero vector if no falloff
				gravity = 9.81, --gravity vector inside the physical area
			},
			
				PlayerDim = {
					cyl_r = 1, --float - radius of collider cylinder default -

					cyl_pos =0.5 , --float - vertical position of collider cylinder default -
				},
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
			--none = {row_inc = 0, col_inc = 0, name = "none"},
			up = {row_inc = 1, col_inc = 0, name = "up"},
			down = {row_inc = -1, col_inc = 0, name = "down"},
			right = {row_inc = 0, col_inc = 1, name = "right"},
			left = {row_inc = 0, col_inc = -1, name = "left"}
		},

	direction = {row_inc = 0, col_inc = 0},
	Previous_Loc={},

	target = "",

	enemy = "",

	timer  = 0,
	


};


---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:OnInit() 
	--Log("LivingEntityBase: OnInit()")
    self:OnReset();
end

function LivingEntityBase:OnPropertyChange() 
	--Log("LivingEntityBase: OnPropertyChange()")

    self:OnReset();

end

function LivingEntityBase:OnReset()
	--OK wtf is it really not possible to reload this script from maze2?
	--Log("test reload from maze");
	--Log("LivingEntityBase: OnReset()")
    self:SetFromProperties()  

	--Log("About to call abstractReset")
    self:abstractReset()
	self:THEFUCK()
	--Log("Should have called abstractReset")
end

-- This abstract reset is empty in Base, it purely exists if you want extra functionality from reset in subclass
function LivingEntityBase:abstractReset()
		Log("LivingEntityBase: AbstractReset()")
end


----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:SetupModel()
	Log("LivingEntityBase: SetupModel()")
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity

		local v1, v2 = self:GetLocalBBox()
		--local v = {x=0,y=0,z=0}
		--LogVec("v2", v2)
		--LogVec("v1", v1)
		--SubVectors(v, v2, v1)
		--LogVec("v", v)
		--self.dimensions.Model_Width = v.x
		--self.dimensions.Model_Height = v.y;
		--self.Properties.Physics.Living.height = 0;
		--self.Properties.Physics.Living.size = v;

        --if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
		self.Properties.Physics.Area.box_min = v1
		self.Properties.Physics.Area.box_max = v2
		--LogVec("Max", self.Properties.Physics.Area.box_max)
		self.Properties.Physics.PlayerDim.cyl_r = v2.x
		self.Properties.Physics.PlayerDim.cyl_pos = v2.y 
        self:PhysicalizeThis();
        --end
    end
	
	--if(self.type == "Mouse") then 
		--self:SetScale(3)
	--end

end

function LivingEntityBase:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
   
   --self:Physicalize(0, PE_AREA, self.Properties.Physics);
   --Log(self.Properties.Physics.PlayerDim.cyl_r)
   
   self:Physicalize(0, PE_LIVING, self.Properties.Physics);
   self:SetPhysicParams(PHYSICPARAM_PLAYERDIM, self.Properties.Physics.PlayerDim)
   self:AwakePhysics(1)
   
end

function LivingEntityBase:SetFromProperties()
	--Log("LivingEntityBase: SetFromProperties()")

    self:SetupModel();
	self.angles = self:GetAngles(); --gets the current angles of Rotating
    self.pos = self:GetPos(); --gets the current position of Rotating
    --self.pos.z = 32
    --self:SetPos({self.pos.x, self.pos.y, self.pos.z})

	local Properties = self.Properties;
	if (Properties.object_Model == "") then
		do return end;
	end

    local nearby_entities = System.GetEntities(self.pos, 100)

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

    if (self.Maze_Properties.ID ~= "") then
		self:SetupMaze()
    else 
	     Log("Error: LivingEntityBase unable to locate maze");
        --return;
	end
	

    if(self.Player_Properties.ID == "") then
        for key, value in pairs( nearby_entities ) do
            if (tostring(value.type) == "Player") then
                self.Player_Properties.ID = value;
            end 
        end
    end

    --self.direction = self.directions.none

    self:Activate(1); --set OnUpdate() on/off

end

function LivingEntityBase:SetupMaze()
	--Log("LivingEntityBase: SetupMaze()");
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

	self.Maze_Properties.grid = {};
	
    if #self.Maze_Properties.grid ~= self.Maze_Properties.height then
        --self.Maze_Properties.grid = {};
        for row = 1, self.Maze_Properties.height do
            self.Maze_Properties.grid[row] = {};
            for col = 1, self.Maze_Properties.width do
                local cur_nslot = self.Maze_Properties.ID:rowcol_to_nslot(row, col);
                local cur_wall = self.Maze_Properties.ID.myWalls[cur_nslot];

                if cur_wall ~= nil then
                    self.Maze_Properties.grid[row][col] = {occupied = true, nslot = cur_nslot, n_visited = 0};
                else
                    self.Maze_Properties.grid[row][col] = {occupied = false, nlsot = -1, n_visited = 0};
                end
				--Log(tostring(row) .. "," .. tostring(col) .. " occupied: " .. tostring(self.Maze_Properties.grid[row][col].occupied));
            end
        end
    end	
	
	self.Previous_Loc = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos())
	--self:PrintTable(self.Maze_Properties.grid);

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

	local a = self:GetPos();
	local b = pos;
	
	self:FaceAt(b, frameTime);
	
	local diff = {x = b.x - a.x, y = b.y - a.y};
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
	local speed_mag = self.Properties.m_speed / diff_mag;

	self:move_xy({x = a.x + diff.x * speed_mag,
		y = a.y + diff.y * speed_mag});

end

function LivingEntityBase:FaceAt(pos, fT)
	--Log("In FaceAt");
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
			
				try_pos = self.Maze_Properties.ID:rowcol_to_pos(row_index, col_index);
			
				System.DrawLine(self.pos, {try_pos.x, try_pos.y, self.pos.z}, 0, 1, 0, 1);

				empty_neighbors[#empty_neighbors+1] = {row =row_index, col = col_index, n_visited = grid[row_index][col_index].n_visited, direction = value};

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

function LivingEntityBase:runFrom(target, frameTime)
	--Cryengine
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	local row = rowcol.row;
	local col = rowcol.col;

	local loc_row_inc = self.direction.row_inc;
	local loc_col_inc = self.direction.col_inc;

	local prev_pos = self.Previous_Loc
	--if we haven't moved out of a grid space yet, continue as before
	if row == prev_pos.row and col == prev_pos.col and (loc_row_inc ~= 0 or loc_col_inc) ~= 0 then
		--Log("STAY ON COURSE");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
		--target_pos.z = 32;
		self:Move_to_Pos(frameTime, target_pos);
		return;
	end

	--else change our behavior
	self.Previous_Loc.col = col;
	self.Previous_Loc.row = row;

	--increment visit counter of current grid space
	--Log(tostring(self.Maze_Properties.grid[row][col].n_visited));
	self.Maze_Properties.grid[row][col].n_visited = self.Maze_Properties.grid[row][col].n_visited + 1;
	--Log(tostring(self.Maze_Properties.grid[row][col].n_visited));

	local empty_neighbors = self:getUnoccupiedNeighbors(row, col);

	--Log("Num Empty_neighbors: " .. tostring(#empty_neighbors));

	--get direction vector of target
	local target_col_inc, target_row_inc;
	block_offset_x = math.floor((target.pos.x - self.pos.x)/2 + 0.5);
	block_offset_y = math.floor((target.pos.y - self.pos.y)/2 + 0.5);
	if block_offset_x < 0 then
		target_col_inc = -1;
	elseif block_offset_x > 0 then
		target_col_inc = 1;
	else
		target_col_inc = 0;
	end

	if block_offset_y < 0 then
		target_row_inc = -1;
	elseif block_offset_y > 0 then
		target_row_inc = 1;
	else
		target_row_inc = 0;
	end

	local target_direction = {row_inc = target_row_inc, col_inc = target_col_inc};

	-- if there are more options than mvoing towards target
	if #empty_neighbors >=2 then
		--remove moving towards target as an option
		for key, value in pairs(empty_neighbors) do
			--remove moving towards target as an option
			try_dir = empty_neighbors[key].direction;
			if try_dir.row_inc ==  target_row_inc and
					try_dir.col_inc == target_col_inc then
				--Log("REMOVE BACKTRACKING AS OPTION");
				empty_neighbors[key] = nil;
			--if a movement direction takes the mouse out of the sight of the snake - take it
			else
				try_pos = self.Maze_Properties.ID:rowcol_to_pos(value.row, value.col);
				
				local diff = {x = target.pos.x - try_pos.x, y = target.pos.y - try_pos.y, z = 0};

				--Log(Vec2Str(diff));

			 	local fucker = {};

			 	Physics.RayWorldIntersection({try_pos.x, try_pos.y, self.pos.z}, diff, 1, ent_all, self.id, target.id, fucker);--, self:GetRawId(), target_mouse:GetRawId());

				local n_hits = 0;

				--self:PrintTable(fucker);

				for key, value in pairs(fucker) do
					n_hits = n_hits + 1
				end

				if (n_hits > 0) then
					Log("HIDE AND SEEK");
					self.direction = value.direction;
					return;
				end
			end
		end
	else end
	
	local min_val = 10000;
	local min_key = 0

	for key, value in pairs(empty_neighbors) do
		--Log(tostring(value.n_visited));
		if value.n_visited < min_val then
			min_val = value.n_visited;
			min_key = key;
		end
	end
	
	--select minimally visited neighbor
	self.direction = empty_neighbors[min_key].direction;
end

function LivingEntityBase:exploratoryWalk(frameTime)
	--Cryengine
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	local row = rowcol.row;
	local col = rowcol.col;

	local loc_row_inc = self.direction.row_inc;
	local loc_col_inc = self.direction.col_inc;
	
	local empty_neighbors = self:getUnoccupiedNeighbors(row, col);

	local prev_pos = self.Previous_Loc
	--if we haven't moved out of a grid space yet, continue as before
	if row == prev_pos.row and col == prev_pos.col and (loc_row_inc ~= 0 or loc_col_inc) ~= 0 then
		--Log("STAY ON COURSE");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
		self:Move_to_Pos(frameTime, target_pos);
		return;
	end

	--else change our behavior
	self.Previous_Loc.col = col;
	self.Previous_Loc.row = row;

	--increment visit counter of current grid space
	self.Maze_Properties.grid[row][col].n_visited = self.Maze_Properties.grid[row][col].n_visited + 1;

	-- if there are more options than backwards
	if #empty_neighbors >=2 then
		--remove backtracking as an option
		for key, value in pairs(empty_neighbors) do
			try_dir = empty_neighbors[key].direction;
			if try_dir.row_inc ==  -self.direction.row_inc and try_dir.col_inc == -self.direction.col_inc then
				--Log("REMOVE BACKTRACKING AS OPTION");
				empty_neighbors[key] = nil;
			end
		end
	else 
	
	end
	
	local min_val = 10000;
	local min_key = 0

	for key, value in pairs(empty_neighbors) do
		--Log(tostring(value.n_visited));
		if value.n_visited < min_val then
			min_val = value.n_visited;
			min_key = key;
		end
	end
	
	--select minimally visited neighbor
	self.direction = empty_neighbors[min_key].direction;
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
	local rnd_idx = random(#empty_neighbors);
	self.direction = empty_neighbors[rnd_idx].direction;

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
			return;
		end
	end

	--choose random starting direction
	--Log("choose rand initial direction");
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
-------------------------              Behaviors                             ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
function LivingEntityBase:chase(target_class, time)
	--Log("In Chase")
	local target = self:ray_cast(target_class);

	if (target ~= nil) then
		--self:PrintTable(target)
		if (target.class ~= "") then
			--Log("In if state")
			local distance = vecLen(vecSub(target.pos, self.pos));
			--Log("Distance = %d", distance)
			if distance < 1.1 then
				--Log("Distance <= 1, Eat")
				target:OnEat(self, 2);
				self.target = nil;

				return false;
			end

			self:Move_to_Pos(time, target.pos);

			return true;
		else
			return false;
		end
	else 
		return false;
	end
end


function LivingEntityBase:run(target_class, time)

	local target = self:ray_cast(target_class);

	if (target ~= nil) then
		self:runFrom(target, time);
		return true;
	else
		return false;
	end
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------              Utility Functions                             ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
function LivingEntityBase:ray_cast(target_class)

	local target = System.GetNearestEntityByClass({self.pos.x, self.pos.y, self.pos.z},
 			 20, target_class);

	if target == nil then
		return nil;
	end

 	--Log(tostring(target));

 	System.DrawLine(self.pos, target.pos, 1, 0, 0, 1);

 	local diff = {x = target.pos.x - self.pos.x, y = target.pos.y - self.pos.y, z = 0};

 	local fucker = {};

 	Physics.RayWorldIntersection(self.pos, diff, 1, ent_all, self.id, target.id, fucker);--, self:GetRawId(), target_mouse:GetRawId());

	
	local n_hits = 0;

	for key, value in pairs(fucker) do
		n_hits = n_hits + 1
	end

	if (n_hits > 0) then
		--Log("Raycast intersect");
		return nil;
	end
	
	
	return target;
end


function LivingEntityBase:PrintTable(t)

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
end