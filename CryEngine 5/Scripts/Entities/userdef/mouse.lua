--Amal's file path
Script.ReloadScript( "SCRIPTS/Entities/userdef/LivingEntityBase.lua");

--Mitchel's file path
--Script.ReloadScript( "SCRIPTS/Entities/Custom/LivingEntityBase.lua");


-- Globals

--Mitchel's file path
--Mouse_Data_Definition_File = "Scripts/Entities/Custom/Mouse_Data_Definition_File.xml"
--Mouse_Default_Data_File = "Scripts/Entities/Custom/DataFiles/Mouse_Data_File.xml"

--Amal's file path
Mouse_Data_Definition_File = "Scripts/Entities/userdef/Mouse_Data_Definition_File.xml"
Mouse_Default_Data_File = "Scripts/Entities/userdef/DataFiles/Mouse_Data_File.xml"

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Mouse Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Mouse = {
	type = "Mouse",
	
	States = {
		"Test",
		"Move",
		"Search",
		"Avoid",
		"Eat",
		"Sleep",
		"Dead",
		"Power",
	},

	heatmap = {

	},

	t_m = 100,

	t_b = 0.2,

	s_m = 100,

	s_b = 0.5,

	d_t = 1,

	f_m = 20,

	f_b = 0.5,

	dir = "up",
	
	heatmap_radius = 10;
	mouse_offset = 11;

	
	mouseDataTable = {},
	
    Properties = {
    	entType = "Mouse",
		bUsable = 0,
        object_Model = "Objects/characters/animals/rat/rat.cdf",
	    --object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 10, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.15;

		maze_ent_name = "",         --maze_ent_name = "Maze1",

        bActive = 1,
        supermouse = 0,

        mouseDataTable = {},
        
		
		--Physics = {
        --    bPhysicalize = 1, -- True if object should be physicalized at all.
         --   bRigidBody = 1, -- True if rigid body, False if static.
          --  bPushableByPlayers = 1,

         --   Density = -1,
         --   Mass = -1,
       -- },
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
	
	Move = {
		prev_state = "",
		jump = 0,
		impulseMag = 50,
		impulseDir = {x=0,y=0,z=0},
	},
	
	eatCount = {
		Cheese = 0,
		Berry = 0,
		Potato = 0,
		Grains = 0,
	},
	
	ToEat = {},

	timePassed = 0,
};

MakeDerivedEntityOverride(Mouse, LivingEntityBase);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Mouse States                 --------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
Mouse.Test = 
{
	OnBeginState = function(self)
		--Log("Mouse: Test state")
		self:calc_heatmap()
		--self:PrintTable(self.heatmap)
		
		
  	end,
	
	OnUpdate = function(self, time)
		  
		  self.Move.prev_state = "Test"
		  self.Move.impulseDir = self:GetDirectionVector()
		  self.Move.impulseMag = 30
		  --Log(self.Move.impulseMag)
		 -- LogVec("ImpulseDir", self.Move.impulseDir)
		  --self:GotoState("Move")
		  self:GreedyWalk(time)
		  --self:DisplayHeatmap()
	end,
	
	OnEndState = function(self)
		--Log("Mouse: Exiting Test State")
	end,
}

Mouse.Move = 
{
	OnBeginState = function(self)
		Log("Mouse: Move state")
		
  	end,
	
	OnUpdate = function(self, time)
		  --Log("Impulse added")
		   if(jump == 1) then self.Move.impulseDir.z = 1 end
		   --self:PrintTable(self.Move.impulseDir)
		   --Log(self.Move.impulseMag)
		  self:AddImpulse(-1, self:GetCenterOfMassPos(), self.Move.impulseDir, self.Move.impulseMag, 1)
		  self:GotoState(self.Move.prev_state)
		  --self:GotoState("Sleep")
	end,
	
	OnEndState = function(self)
		--Log("Mouse: Exiting Move State")
		self.Move.impulseDir = {}
		self.Move.prev_state = "Move"
	end,
}


Mouse.Search =
{
	OnBeginState = function(self)
		Log("Mouse: Entering Search State")
		self.Properties.mouseDataTable = self:LoadXMLData(Mouse_Default_Data_File)
		--self:PrintTable(self.Properties.mouseDataTable.defaultTable)
	end,

	OnUpdate = function(self,time)

		local trap;

		--local myTest = self:IntersectRay(0, self:GetPos(), self:GetDirectionVector(), 15)
		--self:PrintTable(myTest)

		local hitData = {};
		--local angles = self:GetAngles()
		--LogVec("angles", angles)
		local dir = self:GetDirectionVector();
		dir = vecScale(dir, 50);
		--LogVec("Direction", dir)
		local hits = Physics.RayWorldIntersection(self:GetPos(), dir, 1, ent_all, self.id, nil, hitData )
		--Log(hits)
		if(hits > 0) then 
			--self:PrintTable(hitData)
			if(hitData[1].entity and hitData[1].entity.class == "Trap1") then 
				trap = hitData[1].entity
			end 
		end 


		if(trap ~=nil) then 
		   Log("Mouse: Sees trap")
		   local child = trap:GetChild(0)
		   --self:PrintTable(child)
		   target = child;	
		end 
		--Log(tostring(enemy));
		--Log(tostring(target));
	  
		for i = 1, #self.Properties.mouseDataTable.defaultTable.KnownDangerEnts do 
			--Log("Checking for dangerous entity " .. tostring(self.Properties.mouseDataTable.defaultTable.KnownDangerEnts[i]));
			local enemy = self:ray_cast(self.Properties.mouseDataTable.defaultTable.KnownDangerEnts[i]);
			if enemy ~= nil then 
				self:GotoState("Avoid"); 
			end
		end
		  
		  --local enemy = self:ray_cast("Snake");
		 -- local trap = self:ray_cast("Trap1");
		local target = self:ray_cast("Food");

		if target ~= nil then
			--Log("Gonna Eat")
			self:GotoState("Eat");
		else end;
			--Log("exploratoryWalk");
		
		local max_toEat = 0;
		local max_key = nil;
		for key,value in pairs(self.eatCount) do
			local toEat = self.Properties.mouseDataTable.defaultTable.ToEat[key] - value;
			if toEat > max_toEat then
				max_toEat = toEat;
				max_key = key;
			end
		end
		
		if max_key ~= nil then
			local max_counter = 0;
			local location_key = nil;
			for key,value in pairs(self.Properties.mouseDataTable.defaultTable.FoodLocations[max_key]) do
				if value > max_counter then
					max_counter = value;
					location_key = key;
				end
			end

			if location_key ~= nil then
				local walk_dir = nil;
				if tostring(location_key) == "NorthEastCounter" then
					walk_dir = {row_inc = 1, col_inc = 1};
				elseif tostring(location_key) == "SouthEastCounter" then
					walk_dir = {row_inc = -1, col_inc = 1};
				elseif tostring(location_key) == "NorthWestCounter" then
					walk_dir = {row_inc = 1, col_inc = -1};
				elseif tostring(location_key) == "SouthWestCounter" then
					walk_dir = {row_inc = -1, col_inc = -1};
				end
				
				self:guidedExploratoryWalk(time, walk_dir);
				return;
			else
				--self:exploratoryWalk(time);
			end
		else
			--self:exploratoryWalk(time);
		end
		
		self:exploratoryWalk(time);
	end,

	OnEndState = function(self)
		Log("Mouse: Exiting Search State")
	end,
}

Mouse.Avoid =
{

	OnBeginState = function(self)
		Log("Mouse: Entering Avoid State")

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

	  	local continue_run = self:run("Snake", time);

		if continue_run == false then
			self:GotoState("Search");
		else end;
	end,

  	OnEndState = function(self)
		Log("Mouse: Exiting Avoid State")
  	end,
	
}

Mouse.Cautious =
{

	OnBeginState = function(self)
		Log("Mouse: Entering Cautious State")
		
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
		  
		  self:cautiousWalk()

	end,

  	OnEndState = function(self)
		Log("Mouse: Exiting Cautious State")
  	end,
	
}

Mouse.Eat =
{

	OnBeginState = function(self)
		Log("Mouse: Entering Eat State")

  	end,

 	OnUpdate = function(self,time)
  		local continue_chase = self:chase("Food", time);

  		if continue_chase == false then
  			self:GotoState("Search");
  		else end;	 	
	end,

  	OnEndState = function(self)
		Log("Mouse: Exiting Eat State")
		self:SaveXMLData(self.Properties.mouseDataTable, Mouse_Default_Data_File)
		-- Record Food Locs knowledge
  	end,
	
}

Mouse.Sleep =
{

	OnBeginState = function(self)
		Log("Mouse: Entering SLeep State")
		-- Mark as winner

  	end,

 	OnUpdate = function(self,time)
  	

	end,

  	OnEndState = function(self)

  	end,
	
}

Mouse.Dead =
{
	
	OnBeginState = function(self)
		Log("Mouse: Entering Dead State")
			--self:SaveXMLData()

			self:DeleteThis()

		-- Mark as Loser
		-- Record learned dangers
  	end,

 	OnUpdate = function(self,time)
  	

	end,

  	OnEndState = function(self)
		--self:SaveXMLData()
  	end,
}

Mouse.Power = 
{
	
	OnBeginState = function(self)
		Log("Mouse: Entering Power State")
		timePassed = 1000;
		self.Properties.supermouse = 1;
  	end,

 	OnUpdate = function(self,time)

		if timePassed > powerTime then
			self:GotoState("Search")
		end
			  
			 

		local continue_chase = self:chase("Snake", time);

  		if continue_chase == false then
  			self:GotoState("Search");
  		else end;	

  		timePassed = timePassed - 1;

	end,

  	OnEndState = function(self)
	  	Log("Mouse: Exiting Power State")
	  	self.Properties.supermouse = 0;
  	end,
}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function Mouse:OnEat(userId, index)
	Log("RIP Mouse")
	--self.Properties.mouseDataTable = self:LoadXMLData(Mouse_Default_Data_File);
	
	for i = 1, #self.Properties.mouseDataTable.defaultTable.KnownDangerEnts do 
		if self.Properties.mouseDataTable.defaultTable.KnownDangerEnts[i] == tostring(userId.type) then
			Log(tostring(userId.type) .. " already in data table");
			self:GotoState("Dead")
		end
	end
	Log("Adding " .. tostring(userId.type) .. " to data table");
	self.Properties.mouseDataTable.defaultTable.KnownDangerEnts[#self.Properties.mouseDataTable.defaultTable.KnownDangerEnts + 1] = userId.type;
	self:SaveXMLData(self.Properties.mouseDataTable, Mouse_Default_Data_File);
	self:GotoState("Dead")
end


function Mouse:THEFUCK()
	Log("Mouse: :In THEFUCK")
	--self:GotoState("Search")
	--self:SetScale(3)
	--self.Properties.mouseDataTable = self:LoadXMLData()
	--self:PrintTable(self.Properties.mouseDataTable);
	  --self:GotoState("Test")

	self:GotoState("Test")
	--Log("WTF")
end 


--sets the Mouse's properties
function Mouse:abstractReset()
	Log("Mouse: In AbstractReset")

	--self.direction = self.directions.up;
	--Log(tostring(self.direction.row_inc));
	-- Load Knowledge Base in
	self.Properties.mouseDataTable = self:LoadXMLData() -- Optional Parameter to SPecify what file to read
	
	--self:PrintTable(self.Properties.mouseDataTable)

	--self:GotoState("Search");

end

-- Loads a XML data file and returns it as a script table
function Mouse:LoadXMLData(dataFile)
	dataFile = dataFile	or Mouse_Default_Data_File
	return CryAction.LoadXML(Mouse_Data_Definition_File, dataFile);
end

-- Saves XML data from dataTable to dataFile
function Mouse:SaveXMLData(dataTable, dataFile)
	dataFile = dataFile or Mouse_Default_Data_File
	dataTable = dataTable or self.Properties.mouseDataTable
	
	CryAction.SaveXML(Mouse_Data_Definition_File, dataFile, dataTable);
end


function Mouse:OnUpdate(frameTime)
	self:SetScale(5);

	--[[
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
	--]]
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Mouse:Eating(foodType)

	--self.Properties.mouseDataTable = self:LoadXMLData(Mouse_Default_Data_File);
	local mid_x = self.Maze_Properties.ID.Width/2;
	local mid_y = self.Maze_Properties.ID.Height/2;
	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self.pos);
	local row = rowcol.row;
	local col = rowcol.col;
	local quadrant = "North-West";

	-- Find quadrant where food is picked up
	if col > mid_x and row > mid_y then 
		quadrant = "North-East";
	elseif col > mid_x and row < mid_y then
		quadrant = "South-East";
	elseif col < mid_x and row < mid_y then
		quadrant = "South-West";
	end

	if foodType == "Cheese" then     -- Cheese
        Log("Mouse:OnEat = I am eating Cheese")
		-- Update food table
		--self.Properties.mouseDataTable.defaultTable.ToEat.Cheese = self.Properties.mouseDataTable.defaultTable.ToEat.Cheese - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthWestCounter + 1;
		else
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthWestCounter + 1;
		end
    elseif foodType == "Berry" then -- Berry
        Log("Mouse:OnEat = I am eating Berry")
		--self.Properties.mouseDataTable.defaultTable.ToEat.Berry = self.Properties.mouseDataTable.defaultTable.ToEat.Berry - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.NorthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.SouthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.SouthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.SouthWestCounter + 1;
		else
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.NorthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Berry.NorthWestCounter + 1;
		end
    elseif foodType == "Potato" then -- Potato
        Log("Mouse:OnEat = I am eating Potato")
		--self.Properties.mouseDataTable.defaultTable.ToEat.Berry = self.Properties.mouseDataTable.defaultTable.ToEat.Berry - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.NorthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.SouthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.SouthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.SouthWestCounter + 1;
		else
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.NorthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Potato.NorthWestCounter + 1;
		end
    elseif foodType == "Grains" then -- Grains
        Log("Mouse:OnEat = I am eating Grains")
		--self:PrintTable(self.Properties.mouseDataTable);
		--self.Properties.mouseDataTable.defaultTable.ToEat.Grains = self.Properties.mouseDataTable.defaultTable.ToEat.Grains - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.NorthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.SouthEastCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.SouthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.SouthWestCounter + 1;
		else
			self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.NorthWestCounter = self.Properties.mouseDataTable.defaultTable.FoodLocations.Grains.NorthWestCounter + 1;
		end
    elseif foodType == "PowerBall" then -- PowerBall
        Log("Mouse:OnEat = I am eating PowerBall")
		self:GotoState("Power")
	elseif foodType == "Snake" then		-- Mouse eating Snake in Power Mode
		Log("Mouse: I am powerful and eating Snake!")

		-- Snake turns into random food that mouse still has to eat
		local lookfood = true;
		while lookfood do
			local randfood = math.random(4);

			if randfood == 1 and self.Properties.mouseDataTable.defaultTable.ToEat.Cheese > 0 then
				self.Properties.mouseDataTable.defaultTable.ToEat.Cheese = self.Properties.mouseDataTable.defaultTable.ToEat.Cheese - 1;
				lookfood = false;
				break	
			end
			if randfood == 2 and self.Properties.mouseDataTable.defaultTable.ToEat.Berry > 0 then
				self.Properties.mouseDataTable.defaultTable.ToEat.Berry = self.Properties.mouseDataTable.defaultTable.ToEat.Berry - 1;
				lookfood = false;
				break
			end
			if randfood == 3 and self.Properties.mouseDataTable.defaultTable.ToEat.Potato > 0 then
				self.Properties.mouseDataTable.defaultTable.ToEat.Potato = self.Properties.mouseDataTable.defaultTable.ToEat.Potato - 1;
				lookfood = false;
				break
			end
			if randfood == 4 and self.Properties.mouseDataTable.defaultTable.ToEat.Grains > 0 then
				self.Properties.mouseDataTable.defaultTable.ToEat.Grains = self.Properties.mouseDataTable.defaultTable.ToEat.Grains - 1;
				lookfood = false;
				break
			end
		end
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


--------------------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Overridden Functions                            ---------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

--[[
function Mouse:move_xy(impulseMag, jump)
	
	 self.Move.prev_state = self:GetState()
	 self.Move.impulseDir = self:GetDirectionVector()
	 self.Move.impulseMag = impulseMag
		  --Log(self.Move.impulseMag)
		 -- LogVec("ImpulseDir", self.Move.impulseDir)
		
	  
	self.Move.impulseDir = {x=0,y=1,z=0} --self:GetDirectionVector()
	self.Move.impulseMag = 30
	if(jump == 1) then self.Move.impulseDir.z = 1 end
	
	Log("Mouse's move_xy, adding imp of %d", impulseMag)
	LogVec("Mouse's ImpulseDirection is ", self.Move.impulseDir)
	--self:AddImpulse(-1, self:GetCenterOfMassPos(), self.Move.impulseDir, self.Move.impulseMag, 1)
	
	self:GotoState("Move")  

	self.pos = self:GetPos()
	
end

function Mouse:Move_to_Pos(frameTime, pos) 

	local a = self:GetPos();
	local b = pos;
	
	self:FaceAt(b, frameTime);
	
	local diff = {x = b.x - a.x, y = b.y - a.y};
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
	local speed_mag = self.Properties.m_speed / diff_mag;

	--self:move_xy({x = a.x + diff.x * speed_mag,
	--	y = a.y + diff.y * speed_mag});
	
	self:move_xy(diff_mag*10, 0)

end

]]
--------------------------------------------------------------------------------------------------------------------------------------------
-------------------------                      FlowGraph Utilities                             ---------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

function Mouse:GetData(self, entityid)
	local mouse = System.GetEntity(entityid)
	local mouseTable = mouse.Properties.mouseDataTable
	
	-- Wins
	self:ActivateOutput("numWins", mouseTable.WinCounter)
	--Deaths
	self:ActivateOutput("DeathCounter", mouseTable.DeathCounter)
	--Boldness
	self:ActivateOutput("Boldness", mouseTable.Boldness)
	-- LeftTurnTendency
	self:ActivateOutput("LeftTurnTendency", mouseTable.LeftTurnTendency)
	-- ToEats
	self:ActivateOutput("ToEatBerry", mouseTable.ToEat.Berry)
	self:ActivateOutput("ToEatGrains", mouseTable.ToEat.Grains)
	self:ActivateOutput("ToEatPotato", mouseTable.ToEat.Potato)
	self:ActivateOutput("ToEatPotato", mouseTable.ToEat.Cheese)
	-- Known Danger
	local killers = ""
	for k, v in mouseTable.KnownDangerEnts do 
		killers = killers..v.." "
	end 
	self:ActivateOutput("KnownDanger", killers)


end 

Mouse.FlowEvents = 
{
	--[[
		Value types supported for the inputs and outputs:
			string
			bool
			entityid
			int
			float
			vec3
	]]
	
	Inputs = 
	{	
		ID = {Mouse.GetData, "entityid"},

	},

	Outputs = 
	{
		-- Win Counter
		numWins = "int",
		
		-- Death counter
		DeathCounter = "int",
		
		-- Left Turn Tendency
		LeftTurnTendency = "float",
		
		-- Boldness 
		Boldness = "float",
		
		-- To Eats
		ToEatBerry = "int",
		ToEatGrains = "int",
		ToEatPotato = "int",
		ToEatCheese = "int",
		
		-- Known Danger
		KnownDanger = "string",
		
		-- 
	},

}

function Mouse:updateHeatMapBFS(class,pos)

	local qV = {}
	for i = 1,21 do
		qV[i] = {}
		for j = 1,21 do
			qV[i][j] = 0
		end
	end

	local dq = List.new()
	local item = {pos={x=pos.x, y=pos.y}, i=0}
	qV[item.pos.x][item.pos.y] = 1
	List.pushright(dq,item)
	local m = 0
	local b = 0
	local s = -1
	if class == "Food" then
		m = self.f_m
		b = self.f_b
		s = 1
	
	elseif class == "Trap" then
		m = self.t_m
		b = self.t_b
		s = -1
	
	elseif class == "Snake" then
		m = self.s_m
		b = self.s_b
		s = -1
	end

	local p = List.popleft(dq)
	local i = 0
	while p ~= nil do

		if i <= 9 then
			--self:PrintTable(p)
			i = i + 1
		end
		if p.i <= 9 then
			local tt = p

			local up = {pos = {x = tt.pos.x, y= tt.pos.y+1}, i=tt.i+1}
			--Log(up.pos.x.." "..up.pos.y)
			if up.pos.y <= 21 and qV[up.pos.x][up.pos.y] == 0 then
				List.pushright(dq,up)
				qV[up.pos.x][up.pos.y] = 1
			end

			local down = {pos = {x = tt.pos.x, y= tt.pos.y-1}, i=tt.i+1}
			--Log(down.pos.x.." "..down.pos.y)
			if down.pos.y >= 1 and qV[down.pos.x][down.pos.y] == 0 then
				List.pushright(dq,down)
				qV[down.pos.x][down.pos.y] = 1
			end

			local right = {pos = {x = tt.pos.x+1, y= tt.pos.y}, i=tt.i+1}
			--Log(right.pos.x.." "..right.pos.y)
			if right.pos.x <= 21 and qV[right.pos.x][right.pos.y] == 0 then
				List.pushright(dq,right)
				qV[right.pos.x][right.pos.y] = 1
			end

			local left = {pos = {x = tt.pos.x-1, y= tt.pos.y}, i=tt.i+1}
			--Log(left.pos.x.." "..left.pos.y)

			--Log(left.pos.x)
			if left.pos.x >= 1 and qV[left.pos.x][left.pos.y] == 0 then
				List.pushright(dq,left)
				qV[left.pos.x][left.pos.y] = 1
			end
			

		end

		local value = m * (b^p.i) * s
		--Log(class..p.pos.x..","..p.pos.y.."value:"..value..s)
		if( p.pos.x >= 1 and p.pos.x <= 21 and p.pos.y >= 1 and p.pos.y <= 21) then
			self.heatmap[p.pos.x][p.pos.y] = self.heatmap[p.pos.x][p.pos.y] + value
		end
		--Log("m,b"..m..","..b.."; value:"..value)
		--Log(self.heatmap[p.pos.x][p.pos.y])
		
		
		p = List.popleft(dq)
	end



	return nil
end

function Mouse:calc_heatmap()

	local ents = System.GetEntitiesInSphere(self.pos,self.heatmap_radius)
	self.pos = self:GetPos();
	local mpos = {x = math.floor(self.pos.x+0.5), y = math.floor(self.pos.y+0.5), z = math.floor(self.pos.z+0.5)}
	--Log("Mpos " .. Vec2Str(mpos));
	--Log("Self.pos ".. Vec2Str(self.pos));
	--self:PrintTable(surEnt)

	--initialize heatmap
	for row = 1, 21 do
        self.heatmap[row] = {};
        for col = 1, 21 do
        	if(self.dir == "up") then
            	self.heatmap[row][col] = col * self.d_t
            elseif(self.dir == "down") then
            	self.heatmap[row][col] = (22-col) * self.d_t
            elseif(self.dir == "right") then
            	self.heatmap[row][col] = row * self.d_t
            elseif(self.dir == "left") then
            	self.heatmap[row][col] = (22-row) * self.d_t
            end
        end
    end


	for i, ent in pairs(ents) do
			
		if self:can_see_obj(ent) then
			
			if(ent.class and ent.class == "Maze_Wall") then
				local pos = ent:GetPos()
				local rpos = {x = math.floor(pos.x+0.5) - (mpos.x-self.mouse_offset), y = math.floor(pos.y+0.5) - (mpos.y-self.mouse_offset), z = math.floor(pos.z+0.5)}
				--Log("Wall pos " .. Vec2Str(pos));
				--Log("Wall rounded pos " .. Vec2Str(rpos));
				
				if(rpos.x > 1 and rpos.x < 21 and rpos.y > 1 and rpos.y < 21) then 
					self.heatmap[rpos.x][rpos.y] = -math.huge
					self.heatmap[rpos.x][rpos.y+1] = -math.huge
					self.heatmap[rpos.x+1][rpos.y] = -math.huge
					self.heatmap[rpos.x+1][rpos.y+1] = -math.huge
				end

			end


			--if(ent.class and ent.class == "Food") then
			--	local pos = ent:GetPos()
			--	local rpos = {x = math.floor(pos.x+0.5) - (mpos.x-self.mouse_offset), y = math.floor(pos.y+0.5) - (mpos.y-self.mouse_offset), z = math.floor(pos.z+0.5)}
			--	--Log("Food:"..rpos.x..","..rpos.y)
			--	self:updateHeatMapBFS("Food",rpos)

			--end


			if(ent.class and ent.class == "Snake") then
				local pos = ent:GetPos()
				local rpos = {x = math.floor(pos.x+0.5) - (mpos.x-self.mouse_offset), y = math.floor(pos.y+0.5) - (mpos.y-self.mouse_offset), z = math.floor(pos.z+0.5)}
				--Log("Snake:"..rpos.x..","..rpos.y)
				self:updateHeatMapBFS("Snake",rpos)

			end


			if(ent.class and (ent.class == "Trap1" or ent.class == "Trap2")) then
				local pos = ent:GetPos()
				local rpos = {x = math.floor(pos.x+0.5) - (mpos.x-self.mouse_offset), y = math.floor(pos.y+0.5) - (mpos.y-self.mouse_offset), z = math.floor(pos.z+0.5)}
				--Log("Trap:"..rpos.x..","..rpos.y)
				self:updateHeatMapBFS("Trap",rpos)

			end
		
			--self:PrintTable(ent)
		end

		
		

	end

	

	--Log("-------MousePos"..mpos.x.." "..mpos.y.." "..mpos.z)

	--self:PrintTable(self.heatmap)

end

function Mouse:GreedyWalk(frameTime)

	self:updateDir();

	self:calc_heatmap()
	local maxVal = 0
	local maxPos_x = 0;
	local maxPos_y = 0;
	
	local rounded_pos = {x = math.floor(self.pos.x + 0.5), y = math.floor(self.pos.y + 0.5), z = self.pos.z};
	
	mouse_offset = self.mouse_offset;
	--[[
	for i = mouse_offset - 1, mouse_offset + 1 do
		i_mod = 
		for j = mouse_offset - 1, mouse_offset + 1 do
			local trypos = {x = rounded_pos.x + i - mouse_offset, y = rounded_pos.y + j - mouse_offset, z= rounded_pos.z}
			System.DrawLine(self.pos, {trypos.x, trypos.y, self.pos.z}, 1, 0, 0, 1);
			if self.heatmap[i][j] > maxVal then
				maxVal = self.heatmap[i][j];
				maxPos_x = i;
				maxPos_y = j;
			end
		end
	end
	--]]
	
	for i = 0, 2 do
		i_mod = mouse_offset - 1 + (1 + i) % 3;
		for j = 0, 2 do
			j_mod = mouse_offset - 1 + (1 + j) % 3;
			local trypos = {x = rounded_pos.x + i_mod - mouse_offset, y = rounded_pos.y + j_mod - mouse_offset, z= rounded_pos.z}
			System.DrawLine(self.pos, {trypos.x, trypos.y, self.pos.z}, 1, 0, 0, 1);
			if self.heatmap[i_mod][j_mod] > maxVal then
				maxVal = self.heatmap[i_mod][j_mod];
				maxPos_x = i_mod;
				maxPos_y = j_mod;
			end
		end
	end

	--Log("Max_pos_x " .. tostring(maxPos_x));
	--Log("Max_pos_y " .. tostring(maxPos_y));
	local newpos = {x = rounded_pos.x + maxPos_x - mouse_offset, y = rounded_pos.y + maxPos_y - mouse_offset, z= rounded_pos.z}
	--Log("New pos: " .. Vec2Str(newpos));
	--Log("Self pos: " .. Vec2Str(self.pos));
	
	Log("HEATMAP_VAL_AT_CUR_POS" .. tostring(self.heatmap[mouse_offset][mouse_offset]));
	
	self:DisplayHeatmap()
	--self:updateDir(newpos)
	--System.DrawLine(self.pos, {newpos.x, newpos.y, self.pos.z}, 0, 1, 0, 1);
	self:Move_to_Pos(frameTime, newpos);
	--System.DrawLabel(newpos, 3.0, tostring(maxVal), 0.6, 0.0, 0.0, 1);
	

end

function Mouse:updateDir()

	local dir = self.dir;

	--Log(tostring(self));
	self:demoWalk();
	Log("This direction: " .. tostring(self.direction.name));

	--self:PrintTable(self.direction);
	self.dir = self.direction.name;
	if self.dir == "down" then
		--self.dir = "up"
	end

end

--[[
function Mouse:updateDir(newpos)
	local dir = self.dir
	local xx = newpos.x - self:GetPos().x 
	local yy = newpos.y - self:GetPos().y 

	if(yy >= 1) then
		dir = "up"
	elseif(yy <= -1) then
		dir = "down"
	elseif(xx >= 1) then
		dir = "right"
	elseif(xx <= -1) then
		dir = "left"
	end
	self.dir = dir
end
--]]


-- Display heat map labels on screen
function Mouse:DisplayHeatmap()

	local r = 0.0
	local g = 0.0
	local b = 0.0

	for row=1, 21 do
		for col=1, 21 do
			local pos = {x = math.floor(self:GetPos().x + 0.5) + col - self.mouse_offset, y = math.floor(self:GetPos().y +0.5) + row - self.mouse_offset, z = 32}
			r = 0.0
			g = 0.0
			b = 0.0

			if self.heatmap[col][row] < -10 then
				r = 0.6
			elseif self.heatmap[col][row] > -10 and self.heatmap[col][row] <= 10 then
				r = 1
				b = 0
				g = 0.6
			elseif self.heatmap[col][row] > 10 and self.heatmap[col][row] < 20 then
				g = 0.6

			else
				b = 0.6
			end

			System.DrawLabel(pos, 1.7, tostring(self.heatmap[col][row]), r, g, b, 1);

		end
	end

end


function Mouse:print_heatmap()

	Log("HeatMap: ")
	for row=1, 21 do
		local rowprint = "";
		for col=1, 21 do
			rowprint = rowprint..tostring(self.heatmap[row][col])..", ";
		end
		Log(rowprint)
	end

end



List = {}
function List.new ()
  return {first = 0, last = -1}
end

function List.pushleft (list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end

function List.pushright (list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function List.popleft (list)
  local first = list.first
  if first > list.last then return nil end --error("list is empty") end
  local value = list[first]
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
  return value
end

function List.popright (list)
  local last = list.last
  if list.first > last then return nil end--error("list is empty") end
  local value = list[last]
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
  return value
end
