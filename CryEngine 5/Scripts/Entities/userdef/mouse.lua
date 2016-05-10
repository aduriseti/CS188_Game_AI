Mouse = {
	type = "Mouse",
	
    Properties = {
        object_Model = "objects/default/primitive_cube_small.cgf",
        fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.05;
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
	
	state = "",
};

--when Mouse is initialized, this function is called by the game engine
--call the OnReset function, which sets relevant members
function Mouse:OnInit() 
    self:OnReset();
end

--when a property is changed (by the user in the property editor window), set relevant properties
function Mouse:OnPropertyChange() 
    self:OnReset();
end

--sets the Mouse's properties
function Mouse:OnReset()
	Log("In OnReset");
    
	--require a model to be set for the Mouse
    if (self.Properties.object_Model ~= "") then
		--Load mouse object into game world
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
			Log("Error: Mouse unable to locate maze");
			return;
		end
		
		self.state = "search";
		
		self:Activate(self.Properties.bActive); --set OnUpdate() on/off
		self.angles = self:GetAngles(); --gets the current angles of Mouse
		self.pos = self:GetPos(); --gets the current position of Mouse
		self.pos.z = 33;
		self:SetPos({self.pos.x, self.pos.y, self.pos.z});
		
		Log("XPos: " .. tostring(self.pos.x));
		
		--populate Maze_Properties and put Mouse in maze
		--populate Maze Properties
		self.Maze_Properties.cell_height = self.Maze_Properties.ID:height();
		self.Maze_Properties.cell_width = self.Maze_Properties.ID:width();
		self.Maze_Properties.height = (self.Maze_Properties.ID:height()*(self.Maze_Properties.ID:corridorSize() + 1) + 1);
		self.Maze_Properties.width = (self.Maze_Properties.ID:width()*(self.Maze_Properties.ID:corridorSize() + 1) + 1);
		self.Maze_Properties.directions = self.Maze_Properties.ID.directions;
		self.Maze_Properties.model_height = self.Maze_Properties.ID.Model_Height;
		self.Maze_Properties.model_width = self.Maze_Properties.ID.Model_Width;
		self.Maze_Properties.corridor_width = self.Maze_Properties.ID.corridorSize;
		
		
		
		
		Log("Maze height (including walls): " .. tostring(self.Maze_Properties.height));
		
		
		if #self.Maze_Properties.grid ~= self.Maze_Properties.height then
			self.Maze_Properties.grid = {};
			for row = 1, self.Maze_Properties.height do
				self.Maze_Properties.grid[row] = {};
				for col = 1, self.Maze_Properties.width do
					local cur_nslot = self.Maze_Properties.ID:rowcol_to_nslot(row, col);
					local cur_wall = self.Maze_Properties.ID.myWalls[cur_nslot];
					--Log(tostring(cur_nslot));
					--Log(tostring(cur_wall));
					if cur_wall ~= nil then
						self.Maze_Properties.grid[row][col] = {occupied = true, nslot = cur_nslot};
					else
						self.Maze_Properties.grid[row][col] = {occupied = false, nlsot = -1};
					end
				end
			end
		end
		
		for row = 1, self.Maze_Properties.height do
			for col = 1, self.Maze_Properties.width do
				if self.Maze_Properties.grid[row][col].occupied == false then
					self:move_xy(self.Maze_Properties.ID:rowcol_to_pos(row, col));
					return;
				end
			end
		end
		
   
   else Log("Error: Modelname not found!"); end
end

function Mouse:move_xy(xy)
	--Log("XPos: " .. tostring(self.pos.x));
	self:SetPos({xy.x, xy.y, self.pos.z});
	self.pos.x = xy.x;
	self.pos.y = xy.y;
end

function Mouse:turnLeftAlways()
	--STATUS: Not finished for maze2
	
	local rowcol = Mouse.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	
	local row = rowcol.row;
	local col = rowcol.col;
	
	
end

function Mouse:depthFirstSearch()
	--STATUS: Not finished for any maze
end

function Mouse:randomWalk() 
	--STATUS: Cryengine only - will push when works with lumberyard
	
	local rowcol = Mouse.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	
	local row = rowcol.row;
	local col = rowcol.col;
	
end

function Mouse:clockwiseWalk(frameTime) 
	local rowcol = Mouse.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	
	local row = rowcol.row;
	local col = rowcol.col;
	
	if self.Maze_Properties.grid[row + 1][col] ~= nil and self.Maze_Properties.grid[row + 1][col].occupied == false then
	
		
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row+1, col);
		
		self:Move_to_Pos(frameTime, pos);
		
		return;
	else if self.Maze_Properties.grid[row - 1][col] ~= nil and self.Maze_Properties.grid[row - 1][col].occupied == false then
	
		
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row-1, col);
		
		self:Move_to_Pos(frameTime, pos);
		return;
		
	else if self.Maze_Properties.grid[row][col + 1] ~= nil and self.Maze_Properties.grid[row][col + 1].occupied == false then
	
		
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col + 1);
		
		self:Move_to_Pos(frameTime, pos);
		return;
		
	else if self.Maze_Properties.grid[row][col - 1] ~= nil and self.Maze_Properties.grid[row][col - 1].occupied == false then
	
		
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row+1, col);
		
		self:Move_to_Pos(frameTime, pos);
		return;
	end
end

function Mouse:raytrace()
	--STATUS: totally broken - will work on tomorrow
end

function Mouse:breathing_animation(frameTime)
	local cycle_time = 50;
	local new_scale = 0.9+(0.2 * cycle_time % frameTime );
	--Log("New scale " .. tostring(new_scale));
	--self.SetScale(new_scale);
	
	
	Log("cycle" .. tostring(frameTime));
	Log("New height" .. tostring(32 + 0.9+(0.2 * frameTime % cycle_time)));
	self:SetPos({self.pos.x, self.pos.y, 32 + 0.9+(0.2/50 * frameTime % cycle_time)});
end

function Mouse:OnUpdate(frameTime)
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
	--self:MoveXForward();
    --self:FaceAt(self.mazeID, frameTime); 
	
	--self:randomWalk();
	
	self.clockwiseWalk(frameTime);
end


function Mouse:MoveXForward() 
	self:move_xy({x = (self.pos.x + self.Properties.m_speed), y = self.pos.y});
	--Log(tostring(self:GetPos().x) .. tostring(self.pos.x));
	
end

function Mouse:Move_to_Pos(frameTime, pos) 
	--self:FaceAt_ID(self.Player_Properties.ID, frameTime);
	local a = self.pos;
	local b = pos;
	self:FaceAt(b, frameTime);
	--local b = self.Player_Properties.ID:GetPos();
	local diff = {x = b.x - a.x, y = b.y - a.y};
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
	if diff_mag < 5 then
		return;
	end
	local speed_mag = self.Properties.m_speed / diff_mag;
	self:move_xy({x = a.x + diff.x * speed_mag,
		y = a.y + diff.y * speed_mag});
	--Log("X: " .. tostring(self.angles.x));
	--Log("Z: " .. tostring(self.angles.z));
	
end

function Mouse:FollowPlayer(frameTime)
	self:FaceAt_ID(self.Player_Properties.ID, frameTime);
	local a = self.pos;
	local b = self.Player_Properties.ID:GetPos();
	--local b = self.Player_Properties.ID:GetPos();
	local diff = {x = b.x - a.x, y = b.y - a.y};
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
	if diff_mag < 5 then
		return;
	end
	local speed_mag = self.Properties.m_speed / diff_mag;
	self:move_xy({x = a.x + diff.x * speed_mag,
		y = a.y + diff.y * speed_mag});
	--Log("X: " .. tostring(self.angles.x));
	--Log("Z: " .. tostring(self.angles.z));
end

function Mouse:FaceAt(pos, fT)
	--Log("In FaceAt");
    local a = self.pos;
    local b = pos;
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.fRotSpeed*fT));  
    self:SetAngles(self.angles);

end


function Mouse:FaceAt_ID(ID, fT)
	--Log("In FaceAt");
    local a = self.pos;
    local b = ID:GetPos();
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.fRotSpeed*fT));  
    self:SetAngles(self.angles);

end