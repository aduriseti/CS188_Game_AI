--CryEngine
Script.ReloadScript( "SCRIPTS/Entities/userdef/LivingEntityBase.lua");
--Lumberyard
--Script.ReloadScript( "SCRIPTS/Entities/Custom/LivingEntityBase.lua");


-- Globals
Mouse_Data_Definition_File = "Scripts/Entities/userdef/Mouse_Data_Definition_File.xml"
Mouse_Default_Data_File = "Scripts/Entities/userdef/DataFiles/Mouse_Data_File.xml"

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Mouse Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Mouse = {
	type = "Mouse",
	
	States = {
		"Search",
		"Avoid",
		"Eat",
		"Sleep",
		"Dead",
		"Power",
	},
	
	mouseDataTable = {},
	
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

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Mouse States                 --------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
Mouse.Search =
 {

  OnBeginState = function(self)
  	Log("Entering Search State")

  end,

  OnUpdate = function(self,time)
  	
	  --[[
		  if SeeFood then 
		  	self:ApproachEntity()
			self:GotoState("Eat")
		end
		
		if Danger then 
			self:GotoState("Avoid")
		end
		
		if Dead then
			self:GotoState("Dead")
		end
		  
	  ]]
	  	self:randomDirectionalWalk(time);
		

  end,

  OnEndState = function(self)
  	Log("Exiting Search State")
  end,

 }

Mouse.Avoid =
{

	OnBeginState = function(self)
		Log("Entering Avoid State")

  	end,

 	OnUpdate = function(self,time)
  		
		  --[[
			  if Safe then
			  	self:GotoState("Search")
			  end
			  
			  if Dead then
			  	self:GotoState("Dead")
			  end
		  ]]
		  
		  --self:Avoid()

	end,

  	OnEndState = function(self)
		Log("Exiting Avoid State")
  	end,
	
}

Mouse.Eat =
{

	OnBeginState = function(self)
		Log("Entering Eat State")
		--[[
			GetNearbyFood Entity
		]]
  	end,

 	OnUpdate = function(self,time)
  		-- Call Nearby foodEntity's Eat function	 	
	end,

  	OnEndState = function(self)
		Log("Exiting Eat State")
		-- Record Food Locs knowledge
  	end,
	
}

Mouse.Sleep =
{

	OnBeginState = function(self)
		Log("Entering SLeep State")
		-- Mark as winner
		CryAction.SaveXML(Mouse_Data_Definition_File.xml, DataFiles/Mouse_Data_File.xml, mouseDataTable);

  	end,

 	OnUpdate = function(self,time)
  	

	end,

  	OnEndState = function(self)

  	end,
	
}

Mouse.Dead =
{
	
	OnBeginState = function(self)
		Log("Entering Dead State")
		-- Mark as Loser
		-- Record learned dangers
  	end,

 	OnUpdate = function(self,time)
  	

	end,

  	OnEndState = function(self)
		self:SaveXMLData()
  	end,
}

Mouse.Power = 
{
	
	OnBeginState = function(self)
		Log("Entering Power State")
		-- Mark as winner
  	end,

 	OnUpdate = function(self,time)
  		--[[
			  if timePassed > powerTime then
			  	self:GotoState("Search")
			  end
			  
			  self:PowerMode();
		  ]]

	end,

  	OnEndState = function(self)
	  	Log("Exiting Power State")
  	end,
}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--sets the Mouse's properties
function Mouse:abstractReset()
	--Log("In Mouse AbstractReset");
	
	-- Load Knowledge Base in
	self.mouseDataTable = self:LoadXMLData() -- Optional Parameter to SPecify what file to read
		
	self:GotoState("Search");
end


-- Loads a XML data file and returns it as a script table
function Mouse:LoadXMLData(dataFile)
	dataFile = dataFile	or Mouse_Default_Data_File
	return CryAction.LoadXML(Mouse_Data_Definition_File, dataFile);
end

-- Saves XML data from dataTable to dataFile
function Mouse:SaveXMLData(dataTable, dataFile)
	dataFile = dataFile or Mouse_Default_Data_File
	dataTable = dataTable or self.mouseDataTable
	
	CryAction.SaveXML(Mouse_Data_Definition_File, dataFile, dataTable);
end

--[[
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

	self:randomDirectionalWalk(frameTime);

end
]]

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

function Mouse:getUnoccupiedNeighbors(loc_row, loc_col)
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	
	row = loc_row or rowcol.row;
	col = loc_col or rowcol.col;
	
	local grid = self.Maze_Properties.grid
	local empty_neighbors = {};
	
	for key,value in pairs(self.directions) do
		local row_index = value.row_inc + loc_row
		local col_index = value.col_inc + loc_col
		
		if row_index > 0 and col_index > 0 and row_index <= #grid and col_index <= #grid[1] then 
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

function Mouse:randomDirectionalWalk(frameTime)
	
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

	--[[
	Log("row: " .. tostring(row));
	Log("col: " .. tostring(col));
	
	Log(tostring(self.Maze_Properties.grid[row][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row + 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row - 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col + 1].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col - 1].occupied));
	--]]
	
	-- TODO: AMAL FOR SOME REASON SOMETIMES THIS GETS CALLED WITH NIL VALs
	local empty_neighbors = self:getUnoccupiedNeighbors(row, col);
	
	--Log(tostring(#empty_neighbors));
	
	local rnd_idx = random(#empty_neighbors);
	self.direction = empty_neighbors[rnd_idx].direction;
	local target_cell = empty_neighbors[rnd_idx];
	local target_pos = self.Maze_Properties.ID:rowcol_to_pos(target_cell.row, target_cell.col);
	self:Move_to_Pos(frameTime, target_pos);
end

function Mouse:directionalWalk(frameTime)

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

	--[[
	Log("row: " .. tostring(row));
	Log("col: " .. tostring(col));
	
	Log(tostring(self.Maze_Properties.grid[row][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row + 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row - 1][col].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col + 1].occupied));
	Log(tostring(self.Maze_Properties.grid[row][col - 1].occupied));
	--]]
	
	
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

function Mouse:Avoid()

end

function Mouse:OnEat(foodType)

	if foodType == "0" then     -- Cheese
        Log("Mouse:OnEat = I am eating Cheese")
		-- Update food table
    elseif foodType == "1" then -- Berry
        Log("Mouse:OnEat = I am eating Berry")
		-- Update food table
    elseif foodType == "2" then -- Potato
        Log("Mouse:OnEat = I am eating Potato")
		-- Update food table
    elseif foodType == "3" then -- Grains
        Log("Mouse:OnEat = I am eating Grains")
		-- Update food table
    elseif foodType == "4" then -- PowerBall
        Log("Mouse:OnEat = I am eating PowerBall")
		self:GotoState("Power")
    else
        Log("Mouse:OnEat = I am eating IDK")
    end
	
	--[[ 
		if MealComplete then
			self:GotoState("Sleep")
		else
			self:GotoState("Search")
		end
		]]
	
end

function Mouse:PowerMode()

end