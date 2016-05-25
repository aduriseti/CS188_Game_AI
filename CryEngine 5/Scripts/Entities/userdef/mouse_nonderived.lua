Mouse_ND = {
	type = "Mouse_ND",
	
    Properties = {
        object_Model = "objects/characters/animals/rat/rat.cdf",
		--object_Model = "objects/default/primitive_cube_small.cgf",
        fRotSpeed = 10, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.15;
        --maze_ent_name = "Maze1",
		maze_ent_name = "",
        bActive = 0,
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
	
	Food_Properties = {
		ent_type = "Food",
		
	},
	
	Snake_Properties = {
		ent_type = "Snake",
	},
	
	Trap_Properties = {
		ent_type = "Trap",
	},
	
    Editor = { Icon = "Checkpoint.bmp", },
    angles = 0, 
    pos = {},
	
	directions = {
			--current = {row_inc = 0, col_inc = 0},
			up = {row_inc = 1, col_inc = 0},
			down = {row_inc = -1, col_inc = 0},
			right = {row_inc = 0, col_inc = 1},
			left = {row_inc = 0, col_inc = -1},
		},
		
	direction = {row_inc = 0, col_inc = 0},

	movement_stack = {},

	backtrack_stack = {},

	movement_queue = {},

	toggle = 0,
	
	state = "",
};

--when Mouse_ND is initialized, this function is called by the game engine
--call the OnReset function, which sets relevant members
function Mouse_ND:OnInit() 
    self:OnReset();
end

--when a property is changed (by the user in the property editor window), set relevant properties
function Mouse_ND:OnPropertyChange() 
    self:OnReset();
end

--sets the Mouse_ND's properties
function Mouse_ND:OnReset()
	Log("In OnReset");
    
	--require a model to be set for the Mouse_ND
    if (self.Properties.object_Model ~= "") then
		--Load Mouse_ND object into game world
		self:LoadObject(0, self.Properties.object_Model); 

		--if the user has specified the name of an entity to target, use that
        if (self.Properties.maze_ent_name ~= "") then 
            self.mazeID = System.GetEntityByName(self.Properties.maze_ent_name); 
			Log(tostring(self.mazeID));
			Log(self.mazeID.type);
		--else use the first Maze2 found in a radius of 1000 game measurement units (meters?)
       else 
			--Log("Error: Target entity not set!"); 
			local nearby_entities = System.GetEntities(self:GetPos(), 100);
			--Log(tostring(nearby_entities));
			for key, value in pairs( nearby_entities ) do
				if (tostring(value.type) == "Maze2") then
					--Log(tostring(key) .. tostring(value));
					Log(tostring(value.type));
					self.Maze_Properties.ID = value;
				elseif (tostring(value.type) == "Player") then
					Log(tostring(value.type));
					self.Player_Properties.ID = value;
				end
			end
		end
		
		if (self.Maze_Properties.ID == "") then
			Log("Error: Mouse_ND unable to locate maze");
			return;
		end
		
		self.state = "search";
		
		self.angles = self:GetAngles(); --gets the current angles of Mouse_ND
		self.pos = self:GetPos(); --gets the current position of Mouse_ND
		self.pos.z = 33;
		--self:SetPos({self.pos.x, self.pos.y, self.pos.z});
		
		self:SetupMaze();
		
		--self.direction = self.directions.none;

		--self.movement_stack = {};
		
		self:Activate(self.Properties.bActive); --set OnUpdate() on/off

   
   else Log("Error: Modelname not found!"); end
end

function Mouse_ND:SetupMaze()
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
                    self.Maze_Properties.grid[row][col] = {occupied = true, nslot = cur_nslot, n_visited = 0};
                else
                    self.Maze_Properties.grid[row][col] = {occupied = false, nlsot = -1, n_visited = 0};
                end
				--Log(tostring(row) .. "," .. tostring(col) .. " occupied: " .. tostring(self.Maze_Properties.grid[row][col].occupied));
            end
        end
    end

	(function ()
		for row = 1, self.Maze_Properties.height do
			for col = 1, self.Maze_Properties.width do
				if self.Maze_Properties.grid[row][col].occupied == false then
					self:move_xy(self.Maze_Properties.ID:rowcol_to_pos(row, col));
					return;
				end
			end
		end
	
	end ) ()
end
		

function Mouse_ND:move_xy(xy)
	self:SetPos({xy.x, xy.y, self.pos.z});
	self.pos.x = xy.x;
	self.pos.y = xy.y;
end

function Mouse_ND:getLeftRight()
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

function Mouse_ND:getUnoccupiedNeighbors(loc_row, loc_col)

	local grid = self.Maze_Properties.grid
	local empty_neighbors = {};

	for key,value in pairs(self.directions) do
		local row_index = value.row_inc + loc_row
		local col_index = value.col_inc + loc_col

		if row_index > 0 and col_index > 0 and row_index <= #grid and col_index <= #grid[1] then 
			--Log("row_index = %d, col_index = %d", row_index, col_index)
			if grid[row_index][col_index].occupied == false then
				--[[
				try_pos = self.Maze_Properties.ID:rowcol_to_pos(row_index, col_index);
				System.DrawLine(self.pos, {try_pos.x, try_pos.y, self.pos.z}, 0, 1, 0, 1);
				Log("continue moving in same direction");
				Log(tostring(loc_row + loc_row_inc));
				Log(tostring(loc_col + loc_col_inc));
				--]]
				empty_neighbors[#empty_neighbors+1] = {row =row_index, col = col_index, n_visited = grid[row_index][col_index].n_visited, direction = value};

				--Log(tostring(#empty_neighbors));
			end
		end
	end

	return empty_neighbors;

end

function Mouse_ND:getOccupiedNeighbors(loc_row, loc_col)

	local grid = self.Maze_Properties.grid
	local neighbor_blocks = {};

	for key,value in pairs(self.directions) do
		local row_index = value.row_inc + loc_row
		local col_index = value.col_inc + loc_col

		if row_index > 0 and col_index > 0 and row_index <= #grid and col_index <= #grid[1] then 
			--Log("row_index = %d, col_index = %d", row_index, col_index)
			if grid[row_index][col_index].occupied == true then
				local cur_nslot = self.Maze_Properties.ID:rowcol_to_nslot(row_index, col_index);
                local cur_wall = self.Maze_Properties.ID.myWalls[cur_nslot];

                if cur_wall ~= nil then
					neighbor_blocks[#neighbor_blocks+1] = cur_wall;
				end
			end
		end
	end

	return neighbor_blocks;

end

function Mouse_ND:tractorBeam(frameTime)

	--Log(tostring(self.toggle));
	--Log("In tractor beam");
	if self.toggle == 0 then
		self.toggle = 1;
	else
		self.toggle = 0;
	end

	self:move_xy(self.pos);

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	local row = rowcol.row;
	local col = rowcol.col;

	local neighbor_blocks = self:getOccupiedNeighbors(row, col);

	--Log("Num neighbor blocks: " .. tostring(#neighbor_blocks));

	local num_beams = 5;
	local spacing = 1/num_beams;

	for key,value in pairs(neighbor_blocks) do
		local center_pos = value:GetPos();
		center_pos.z = center_pos.z + 1;
		for i = -num_beams,num_beams do
			for j = -num_beams,num_beams do
				for k = -num_beams,num_beams do
					local endpos = {x = center_pos.x + spacing*i, 
									y = center_pos.y + spacing*j,
									z = center_pos.z + spacing*k};
					System.DrawLine(self.pos, endpos, 0, 1, 1, 0.3 + 0.05*self.toggle);
				end
			end
		end

		up_pos = value:GetPos();
		up_pos.z = up_pos.z + 0.1;
		
		if up_pos.z - self.pos.z < 1 then
			value:SetPos(up_pos);
		end
	
		return;
		--System.DrawLine(self.pos, center_pos.z, 0, 0, 1, 1);
	end
	
end

--Most efficient algorithm for exploring maze
function Mouse_ND:depthFirstSearch(frameTime)
	
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	local row = rowcol.row;
	local col = rowcol.col;

	Log("Backtrack length: " .. tostring(#self.backtrack_stack));

	--if there are still grid spaces in our movement stack
	if #self.movement_stack ~= 0 then
		local target_square = self.movement_stack[#self.movement_stack];
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(target_square.row, target_square.col);

		System.DrawLine(self.pos, {target_pos.x, target_pos.y, self.pos.z}, 0, 1, 0, 1);
		--if the target square is not a neighbor or the current square do nothing for now
		if (target_square.row - row)^2 + (target_square.col - col)^2 > 1 then
			--TODO: implement create movement queue using BFS/A*	
			--Log("Need to follow movement queue back to target square");
			local backtrack_square = self.backtrack_stack[#self.backtrack_stack];
			if row ~= backtrack_square.row or col ~= backtrack_square.col then
				backtrack_pos = self.Maze_Properties.ID:rowcol_to_pos(backtrack_square.row, backtrack_square.col);
				self:Move_to_Pos(frameTime, backtrack_pos);
			else
				self.backtrack_stack[#self.backtrack_stack] = nil;
			end
			--self:Move_to_Pos(frameTime, target_pos);
			return;
		--if we haven't reached the top square in the movement stack
		elseif row ~= target_square.row or col ~= target_square.col then
			--Log("STAY ON COURSE");
			--local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
			--local target_pos = self.Maze_Properties.ID:rowcol_to_pos(target_square.row, target_square.col);
			--target_pos.z = 32;
			self:Move_to_Pos(frameTime, target_pos);
			return;
		--else if the top square has been reached
		else
			--increment visit counter of current grid space
			--Log(tostring(self.Maze_Properties.grid[row][col].n_visited));
			self.Maze_Properties.grid[row][col].n_visited = self.Maze_Properties.grid[row][col].n_visited + 1;
			--Log(tostring(self.Maze_Properties.grid[row][col].n_visited));

			--add top square of movement stack to backtrack stack so mouse can get out of dead ends
			self.backtrack_stack[#self.backtrack_stack + 1] = self.movement_stack[#self.movement_stack];

			--remove top square of movement stack
			--Log("movement stack length: " .. tostring(#self.movement_stack));
			self.movement_stack[#self.movement_stack] = nil;
			--Log("movement stack length: " .. tostring(#self.movement_stack));

			--now exit out of if statement to add unvisited neighbors to movement stack
		end
	end

	
	--populate movement stack with unvisited neighbors
	local empty_neighbors = self:getUnoccupiedNeighbors(row, col);
	for key,value in pairs(empty_neighbors) do
		if value.n_visited == 0 then
			self.movement_stack[#self.movement_stack + 1] = value;
		end
	end
	
	--entire maze explored - additionally backtrackstack will hold path back to origin
	if #self.movement_stack == 0 then
		Log("Explored entire maze");
	end
	--self:PrintTable(empty_neighbors);
	--self:PrintTable(self.movement_stack);
	--]]
end

function Mouse_ND:runFrom(target, frameTime)
	--Cryengine
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	local row = rowcol.row;
	local col = rowcol.col;

	local loc_row_inc = self.direction.row_inc;
	local loc_col_inc = self.direction.col_inc;

	--if we haven't moved out of a grid space yet, continue as before
	if row == self.previous_row and
			col == self.previous_col and 
			(loc_row_inc ~= 0 or loc_col_inc) ~= 0 then
		--Log("STAY ON COURSE");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
		self:Move_to_Pos(frameTime, target_pos);
		return;
	end

	--else change our behavior
	self.previous_col = col;
	self.previous_row = row;

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

function Mouse_ND:exploratoryWalk(frameTime)
	--Cryengine
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	local row = rowcol.row;
	local col = rowcol.col;

	local loc_row_inc = self.direction.row_inc;
	local loc_col_inc = self.direction.col_inc;
	
	local empty_neighbors = self:getUnoccupiedNeighbors(row, col);

	--if we haven't moved out of a grid space yet, continue as before
	if row == self.previous_row and
			col == self.previous_col and 
			(loc_row_inc ~= 0 or loc_col_inc) ~= 0 then
		--Log("STAY ON COURSE");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+loc_row_inc, col + loc_col_inc);
		self:Move_to_Pos(frameTime, target_pos);
		return;
	end
	
	--[[
	Log("row: " .. tostring(row));
	Log("col: " .. tostring(col));
	
	Log(tostring(self.Maze_Properties.grid[row][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row + 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row - 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col + 1].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col - 1].occupied));
	]]--

	--else change our behavior
	self.previous_col = col;
	self.previous_row = row;

	--increment visit counter of current grid space
	--Log(tostring(self.Maze_Properties.grid[row][col].n_visited));
	self.Maze_Properties.grid[row][col].n_visited = self.Maze_Properties.grid[row][col].n_visited + 1;
	--Log(tostring(self.Maze_Properties.grid[row][col].n_visited));

	--local empty_neighbors = self:getUnoccupiedNeighbors(row, col);

	--Log("Num Empty_neighbors: " .. tostring(#empty_neighbors));

	-- if there are more options than backwards
	if #empty_neighbors >=2 then
		--remove backtracking as an option
		for key, value in pairs(empty_neighbors) do
			try_dir = empty_neighbors[key].direction;
			if try_dir.row_inc ==  -self.direction.row_inc and
					try_dir.col_inc == -self.direction.col_inc then
				--Log("REMOVE BACKTRACKING AS OPTION");
				empty_neighbors[key] = nil;
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

function Mouse_ND:randomDirectionalWalk(frameTime)
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
function Mouse_ND:bounce(frameTime)
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

function Mouse_ND:directionalWalk(frameTime)

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
function Mouse_ND:chase(target_class, time)
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


function Mouse_ND:run(target_class, time)

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
function Mouse_ND:ray_cast(target_class)

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


function Mouse_ND:PrintTable(t)

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


function Mouse_ND:breathing_animation(frameTime)
	local cycle_time = 50;
	local new_scale = 0.9+(0.2 * cycle_time % frameTime );
	--Log("New scale " .. tostring(new_scale));
	--self.SetScale(new_scale);
	
	
	Log("cycle" .. tostring(frameTime));
	Log("New height" .. tostring(32 + 0.9+(0.2 * frameTime % cycle_time)));
	self:SetPos({self.pos.x, self.pos.y, 32 + 0.9+(0.2/50 * frameTime % cycle_time)});
end

function Mouse_ND:OnUpdate(frameTime)
	--Log("In OnUpdate");
	--Log("Frame at time" .. tostring(frameTime))
	
	if (self.state == "search") then
		--self:turnLeftAlways();
	elseif (self.state == "run") then
	
	elseif (self.state == "eat") then
		
	else 
	
	end
	--self:turnLeftAlways();
	--self:FollowPlayer(frameTime);
	--self:breathing_animation(frameTime);
    --self:FaceAt(self.mazeID, frameTime); 
	
	--self:randomWalk();
	
	--self:directionalWalk(frameTime);
	
	--self:randomDirectionalWalk(frameTime);
	
	--self:exploratoryWalk(frameTime);

	self:depthFirstSearch(frameTime);
	self:SetScale(5);
	self:tractorBeam(frameTime);
end

function Mouse_ND:Move_to_Pos(frameTime, pos) 
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

function Mouse_ND:FollowPlayer(frameTime)
	self:FaceAt_ID(self.Player_Properties.ID:GetPos(), frameTime);
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

function Mouse_ND:FaceAt(pos, fT)
	--Log("In FaceAt");
    local a = self.pos;
    local b = pos;
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference - 0.5 * math.pi);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.fRotSpeed*fT));  
    self:SetAngles(self.angles);
end