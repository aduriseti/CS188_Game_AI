Mouse_LOS = {
	type = "Mouse_LOS",
	
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

--when Mouse_LOS is initialized, this function is called by the game engine
--call the OnReset function, which sets relevant members
function Mouse_LOS:OnInit() 
    self:OnReset();
end

--when a property is changed (by the user in the property editor window), set relevant properties
function Mouse_LOS:OnPropertyChange() 
    self:OnReset();
end

--sets the Mouse_LOS's properties
function Mouse_LOS:OnReset()
	Log("In OnReset");
    
	--require a model to be set for the Mouse_LOS
    if (self.Properties.object_Model ~= "") then
		--Load Mouse_LOS object into game world
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
			Log("Error: Mouse_LOS unable to locate maze");
			return;
		end
		
		self.state = "search";
		
		self.angles = self:GetAngles(); --gets the current angles of Mouse_LOS
		self.pos = self:GetPos(); --gets the current position of Mouse_LOS
		self.pos.z = 33;
		--self:SetPos({self.pos.x, self.pos.y, self.pos.z});
		
		self:SetupMaze();
		
		--self.direction = self.directions.none;

		--self.movement_stack = {};
		
		self:Activate(self.Properties.bActive); --set OnUpdate() on/off

   
   else Log("Error: Modelname not found!"); end
end

function Mouse_LOS:SetupMaze()
	 --populate Maze_Properties and put LivingEntityBase in maze
    --populate Maze Properties
    self.Maze_Properties.cell_height = self.Maze_Properties.ID:height();
    self.Maze_Properties.cell_width = self.Maze_Properties.ID:width();
    self.Maze_Properties.height = (self.Maze_Properties.ID:height()*(self.Maze_Properties.ID:corridorSize() + 1) + 1);
    self.Maze_Properties.width = (self.Maze_Properties.ID:width()*(self.Maze_Properties.ID:corridorSize() + 1) + 1);
    self.Maze_Properties.directions = self.Maze_Properties.ID.directions;
    self.Maze_Properties.model_height = self.Maze_Properties.ID.Model_Height;
    self.Maze_Properties.model_width = self.Maze_Properties.ID.Model_Width;
    self.Maze_Properties.corridor_width = self.Maze_Properties.ID.CorridorSize;       

    if #self.Maze_Properties.grid ~= self.Maze_Properties.height then
        self.Maze_Properties.grid = {};
        for row = 1, self.Maze_Properties.height do
            self.Maze_Properties.grid[row] = {};
            for col = 1, self.Maze_Properties.width do
                local cur_nslot = self.Maze_Properties.ID:rowcol_to_nslot(row, col);
                local cur_wall = self.Maze_Properties.ID.myWalls[cur_nslot];
				self.Maze_Properties.grid[row][col] = {occupied = false, nslot = cur_nslot, n_visited = 0, n_examined = 0}

                if cur_wall ~= nil then
                    self.Maze_Properties.grid[row][col].occupied = true;
					--self.Maze_Properties.grid[row][col].nslot = cur_nslot, n_visited = 0};
                else
                    --self.Maze_Properties.grid[row][col] = {occupied = false, nlsot = -1, n_visited = 0};
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

function Mouse_LOS:OnUpdate(frameTime)
	--self:depthFirstSearch(frameTime);
	self:los_search(frameTime);
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------              Movement Functions                             ---------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
		

function Mouse_LOS:move_xy(xy)
	self:SetPos({xy.x, xy.y, self.pos.z});
	self.pos.x = xy.x;
	self.pos.y = xy.y;
end

function Mouse_LOS:getFarthestUnoccupied(loc_row, loc_col)
	
	local farthestUnoccupied = {};
	
	local max_distance = 1000;
	
	for key,value in pairs(self.directions) do
		local dir = {y = value.row_inc * max_distance, 
					x = value.col_inc * max_distance, z = 0};
		
		local fucker = {};
		
		Physics.RayWorldIntersection(self.pos, dir, 1, ent_all, self.id, nil, fucker);
		
		--[[
		self:PrintTable(fucker);
		
		for key, value in pairs(fucker) do 
			Log("KEY" .. tostring(key));
			Log("VALUE" .. tostring(value));
			for k, v in pairs(value) do 
				Log("K" .. tostring(k));
				Log("V" .. tostring(v));
			end
		end
		--]]
		
		if fucker ~= nil then
			--[[
			Log(tostring(fucker.type));
			Log(tostring(fucker.class));
			if tostring(fucker.type) == "Maze_Wall" then
			--]]
				local rowcol = self.Maze_Properties.ID:pos_to_rowcol(fucker[1].pos);
				local row_index = rowcol.row - value.row_inc;
				local col_index = rowcol.col - value.col_inc;
				
				--if the row or column returned isn't this row or column or if its far enough away that its worth exploring
				if math.abs(row_index - loc_row + col_index - loc_col) > (self.Maze_Properties.corridor_width - 1) then 
				
				
					try_pos = self.Maze_Properties.ID:rowcol_to_pos(row_index, col_index);
					System.DrawLine(self.pos, {try_pos.x, try_pos.y, self.pos.z}, 0, 1, 0, 1);
					
					farthestUnoccupied[#farthestUnoccupied+1] = {
						row = row_index, 
						col = col_index, 
						n_visited = self.Maze_Properties.grid[row_index][col_index].n_visited,
						n_examined = self.Maze_Properties.grid[row_index][col_index].n_examined,
						direction = value
					};
				end
			--end
		end
		--]]
	end
	
	--self:PrintTable(farthestUnoccupied);
	
	return farthestUnoccupied;
end

function Mouse_LOS:los_search(frameTime)

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	--Lumberyard
	--local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());

	local row = rowcol.row;
	local col = rowcol.col;
	
	
	--populate movement stack with unvisited and "unexamined" neighbors
	--local empty_neighbors = self:getUnoccupiedNeighbors(row, col);
	local empty_neighbors = self:getFarthestUnoccupied(row, col);
	
	--self:PrintTable(empty_neighbors);
	
	for key,value in pairs(empty_neighbors) do
		if value.n_visited == 0 and value.n_examined == 0 then
			--self.PrintTable(value);
			self.Maze_Properties.grid[row][col].n_examined = self.Maze_Properties.grid[row][col].n_examined + 1;
			self.movement_stack[#self.movement_stack + 1] = value;
			local center_row = value.row;
			local center_col = value.col;
			local radius = self.Maze_Properties.corridor_width;
			for i = -radius, radius do
				for j = -radius, radius do
					if (i >= 1 and i <= self.Maze_Properties.height) and
							(j >= 1 and j <= self.Maze_Properties.width) then
						self.Maze_Properties.grid[center_row + i][center_col + j].n_examined = 
								self.Maze_Properties.grid[center_row + i][center_col + j].n_examined + 1;
					end
				end
			end
		end
	end
	
	--entire maze explored - additionally backtrackstack will hold path back to origin
	if #self.movement_stack == 0 then
		Log("Explored entire maze");
	end

	
	
	--Log("Backtrack length: " .. tostring(#self.backtrack_stack));

	--if there are still grid spaces in our movement stack
	if #self.movement_stack ~= 0 then
		local target_square = self.movement_stack[#self.movement_stack];
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(target_square.row, target_square.col);
		
		--Log("Target pos: " .. Vec2Str(target_pos));
		
		System.DrawLine(self.pos, {target_pos.x, target_pos.y, self.pos.z}, 0, 1, 0, 1);
		
		local diff = {x = target_pos.x - self.pos.x, y = target_pos.y - self.pos.y, z = 0};
		local fucker = {};
		Physics.RayWorldIntersection(self.pos, diff, 1, ent_all, self.id, nil, fucker);
		local n_hits = 0;
		for key, value in pairs(fucker) do
			n_hits = n_hits + 1
		end
		
		--if the target square is not within LOS follow backtrack stack back to that square
		if n_hits > 0 then
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
	
	

	--[[
	--populate movement stack with unvisited and "unexamined" neighbors
	--local empty_neighbors = self:getUnoccupiedNeighbors(row, col);
	local empty_neighbors = self:getFarthestUnoccupied(row, col);
	
	--self:PrintTable(empty_neighbors);
	
	for key,value in pairs(empty_neighbors) do
		if value.n_visited == 0 and value.n_examined == 0 then
			self.movement_stack[#self.movement_stack + 1] = value;
			self.Maze_Properties.grid[row][col].n_examined = self.Maze_Properties.grid[row][col].n_examined + 1;
		end
	end
	
	--entire maze explored - additionally backtrackstack will hold path back to origin
	if #self.movement_stack == 0 then
		Log("Explored entire maze");
	end
	--]]
	--self:PrintTable(empty_neighbors);
	--self:PrintTable(self.movement_stack);
	--]]

end

function Mouse_LOS:getUnoccupiedNeighbors(loc_row, loc_col)

	--local grid = self.Maze_Properties.grid
	local empty_neighbors = {};

	for key,value in pairs(self.directions) do
		local row_index = value.row_inc + loc_row
		local col_index = value.col_inc + loc_col

		--if row_index > 0 and col_index > 0 and row_index <= #grid and col_index <= #grid[1] then 
			--Log("row_index = %d, col_index = %d", row_index, col_index)
			if self.Maze_Properties.grid[row_index][col_index].occupied == false then
				--[[
				try_pos = self.Maze_Properties.ID:rowcol_to_pos(row_index, col_index);
				System.DrawLine(self.pos, {try_pos.x, try_pos.y, self.pos.z}, 0, 1, 0, 1);
				Log("continue moving in same direction");
				Log(tostring(loc_row + loc_row_inc));
				Log(tostring(loc_col + loc_col_inc));
				--]]
				empty_neighbors[#empty_neighbors+1] = {
					row =row_index, 
					col = col_index, 
					n_visited = self.Maze_Properties.grid[row_index][col_index].n_visited, 
					direction = value
				};

				--Log(tostring(#empty_neighbors));
			end
		--end
	end

	return empty_neighbors;

end

--Most efficient algorithm for exploring maze
function Mouse_LOS:depthFirstSearch(frameTime)
	
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

function Mouse_LOS:exploratoryWalk(frameTime)
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

function Mouse_LOS:randomDirectionalWalk(frameTime)
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


function Mouse_LOS:directionalWalk(frameTime)

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
---------------------------------------------------------------------------------------------------------------------------------

function Mouse_LOS:PrintTable(t)

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

function Mouse_LOS:Move_to_Pos(frameTime, pos) 
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

function Mouse_LOS:FaceAt(pos, fT)
	--Log("In FaceAt");
    local a = self.pos;
    local b = pos;
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.fRotSpeed*fT));  
    self:SetAngles(self.angles);
end