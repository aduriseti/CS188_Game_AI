--CryEngine
--Script.ReloadScript( "SCRIPTS/Entities/userdef/LivingEntityBase.lua");
--Lumberyard
Script.ReloadScript( "SCRIPTS/Entities/Custom/LivingEntityBase.lua");

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Mouse Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Mouse = {
	type = "Mouse",

    Properties = {
		bUsable = 0,
        object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.05;   

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

	Food_Properties = {
		ent_type = "Food",	
	},	

	Snake_Properties = {
		ent_type = "Snake",
	},

	Trap_Properties = {
		ent_type = "Trap",
	},

    Editor = { 
		Icon = "Checkpoint.bmp", 
	},	

};

MakeDerivedEntityOverride(Mouse, LivingEntityBase);

---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--sets the Mouse's properties
function Mouse:abstractReset()
	--Log("In Mouse AbstractReset");
	self.state = "search";
end


function Mouse:OnUpdate(frameTime)

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

	self:directionalWalk(frameTime);

end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

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

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	local row = rowcol.row;
	local col = rowcol.col;

end



function Mouse:directionalWalk(frameTime)

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	
	local row = rowcol.row;
	local col = rowcol.col;
	
	local row_inc = self.direction.row_inc;
	local col_inc = self.direction.col_inc;
	
	if row_inc ~= 0 or col_inc ~= 0 then
		if self.Maze_Properties.grid[row+row_inc][col+col_inc].occupied == false then
			--Log("continue moving in same direction");
			local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row+row_inc, col + col_inc);
			self:Move_to_Pos(frameTime, target_pos);
			return;
		end
	end

	--[[
	Log("row: " .. tostring(row));
	Log("col: " .. tostring(col));
	
	Log(tostring(self.Maze_Properties.grid[row][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row + 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row - 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col + 1].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col - 1].occupied));
	--]]
	
	if self.Maze_Properties.grid[row + 1][col].occupied == false then
		
		--Log("can move up");
		self.direction = self.directions.up;
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row + 1, col);
		
		self:Move_to_Pos(frameTime, target_pos);
		return;
	

	elseif self.Maze_Properties.grid[row][col + 1].occupied == false then
		
		--Log("can move right");
		self.direction = self.directions.right;
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row, col + 1);
		self:Move_to_Pos(frameTime, target_pos);
		return;
		
	elseif self.Maze_Properties.grid[row - 1][col].occupied == false then
			
		--Log("can move down");
		self.direction = self.directions.down;
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row-1, col);
		self:Move_to_Pos(frameTime, target_pos);
		return;
		
	elseif self.Maze_Properties.grid[row][col - 1].occupied == false then
		
		Log ("can move left");
		self.direction = self.directions.left;
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row, col - 1);
		self:Move_to_Pos(frameTime, target_pos);
		return;
	
	else end

end



function Mouse:shittyWalk(frameTime) 

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	
	local row = rowcol.row;
	local col = rowcol.col;

	--[[
	Log("row: " .. tostring(row));
	Log("col: " .. tostring(col));
	
	--Log(tostring(row) .. tostring(col));
	Log(tostring(self.Maze_Properties.grid[row][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row + 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row - 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col + 1].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col - 1].occupied));
	]]--
	
	if self.Maze_Properties.grid[row + 1][col].occupied == false then
		
		Log("can move up");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row + 1, col);
		self:Move_to_Pos(frameTime, target_pos);
		return;
	

	elseif self.Maze_Properties.grid[row][col + 1].occupied == false then
		
		Log("can move right");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row, col + 1);
		self:Move_to_Pos(frameTime, target_pos);
		return;
		
	elseif self.Maze_Properties.grid[row - 1][col].occupied == false then
			
		
		Log("can move down");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row-1, col);	
		self:Move_to_Pos(frameTime, target_pos);
		return;
		
		
	elseif self.Maze_Properties.grid[row][col - 1].occupied == false then
		
		Log ("can move left");
		local target_pos = self.Maze_Properties.ID:rowcol_to_pos(row, col - 1);
		self:Move_to_Pos(frameTime, target_pos);
		return;
	
	else end
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

function Mouse:MoveXForward() 
	self:move_xy({x = (self.pos.x + self.Properties.m_speed), y = self.pos.y});

	--Log(tostring(self:GetPos().x) .. tostring(self.pos.x));
end