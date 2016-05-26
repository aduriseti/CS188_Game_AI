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
	
	mouseDataTable = {},
	
    Properties = {
		bUsable = 0,
        object_Model = "Objects/characters/animals/rat/rat.cdf",
	    --object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 10, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.15;

		maze_ent_name = "",         --maze_ent_name = "Maze1",

        bActive = 1,

        
		
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
	}

};

MakeDerivedEntityOverride(Mouse, LivingEntityBase);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Mouse States                 --------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
Mouse.Test = 
{
	OnBeginState = function(self)
		--Log("Mouse: Test state")
		
  	end,
	
	OnUpdate = function(self, time)
		  
		  self.Move.prev_state = "Test"
		  self.Move.impulseDir = self:GetDirectionVector()
		  self.Move.impulseMag = 30
		  --Log(self.Move.impulseMag)
		 -- LogVec("ImpulseDir", self.Move.impulseDir)
		  self:GotoState("Move")

	end,
	
	OnEndState = function(self)
		--Log("Mouse: Exiting Test State")
	end,
}

Mouse.Move = 
{
	OnBeginState = function(self)
		--Log("Mouse: Move state")
		
  	end,
	
	OnUpdate = function(self, time)
		  --Log("Impulse added")
		   if(jump == 1) then self.Move.impulseDir.z = 1 end
		   --self:PrintTable(self.Move.impulseDir)
		   --Log(self.Move.impulseMag)
		  self:AddImpulse(-1, self:GetCenterOfMassPos(), self.Move.impulseDir, self.Move.impulseMag, 1)
		  --self:GotoState(self.Move.prev_state)
		  self:GotoState("Sleep")
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
	self.mouseDataTable = self:LoadXMLData(Mouse_Default_Data_File)
	--self:PrintTable(self.mouseDataTable)
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
		   self:PrintTable(child)
		   target = child;	
	  end 
	  --Log(tostring(enemy));
	  --Log(tostring(target));
	  
	for i = 1, #self.mouseDataTable.defaultTable.KnownDangerEnts do 
		Log("Checking for dangerous entity " .. tostring(self.mouseDataTable.defaultTable.KnownDangerEnts[i]));
		local enemy = self:ray_cast(self.mouseDataTable.defaultTable.KnownDangerEnts[i]);
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

		--self:randomDirectionalWalk(time);

		--Log("exploratoryWalk");
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
		self:SaveXMLData(self.mouseDataTable, Mouse_Default_Data_File)
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
	  	Log("Mouse: Exiting Power State")
  	end,
}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function Mouse:OnEat(userId, index)
	Log("RIP Mouse")
	--self.mouseDataTable = self:LoadXMLData(Mouse_Default_Data_File);
	
	for i = 1, #self.mouseDataTable.defaultTable.KnownDangerEnts do 
		if self.mouseDataTable.defaultTable.KnownDangerEnts[i] == tostring(userId.type) then
			Log(tostring(userID.type) .. " already in data table");
			self:GotoState("Dead")
		end
	end
	Log("Adding " .. tostring(userID.type) .. " to data table");
	self.mouseDataTable.defaultTable.KnownDangerEnts[#self.mouseDataTable.defaultTable.KnownDangerEnts + 1] = userID.type;
	self:SaveXMLData(self.mouseDataTable, Mouse_Default_Data_File);
	self:GotoState("Dead")
end


function Mouse:THEFUCK()
	Log("Mouse: :In THEFUCK")
	--self:GotoState("Search")
	--self:SetScale(3)
	--self.mouseDataTable = self:LoadXMLData()
	--self:PrintTable(self.mouseDataTable);
	  --self:GotoState("Test")

	self:GotoState("Search")
	--Log("WTF")
end 


--sets the Mouse's properties
function Mouse:abstractReset()
	Log("Mouse: In AbstractReset")

	--self.direction = self.directions.up;
	--Log(tostring(self.direction.row_inc));
	-- Load Knowledge Base in
	self.mouseDataTable = self:LoadXMLData() -- Optional Parameter to SPecify what file to read
	
	self:PrintTable(self.mouseDataTable)

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
	dataTable = dataTable or self.mouseDataTable
	
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

	--self.mouseDataTable = self:LoadXMLData(Mouse_Default_Data_File);
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
		--self.mouseDataTable.defaultTable.ToEat.Cheese = self.mouseDataTable.defaultTable.ToEat.Cheese - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Cheese.SouthWestCounter + 1;
		else
			self.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Cheese.NorthWestCounter + 1;
		end
    elseif foodType == "Berry" then -- Berry
        Log("Mouse:OnEat = I am eating Berry")
		--self.mouseDataTable.defaultTable.ToEat.Berry = self.mouseDataTable.defaultTable.ToEat.Berry - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Berry.NorthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Berry.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Berry.SouthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Berry.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.mouseDataTable.defaultTable.FoodLocations.Berry.SouthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Berry.SouthWestCounter + 1;
		else
			self.mouseDataTable.defaultTable.FoodLocations.Berry.NorthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Berry.NorthWestCounter + 1;
		end
    elseif foodType == "Potato" then -- Potato
        Log("Mouse:OnEat = I am eating Potato")
		--self.mouseDataTable.defaultTable.ToEat.Berry = self.mouseDataTable.defaultTable.ToEat.Berry - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Potato.NorthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Potato.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Potato.SouthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Potato.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.mouseDataTable.defaultTable.FoodLocations.Potato.SouthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Potato.SouthWestCounter + 1;
		else
			self.mouseDataTable.defaultTable.FoodLocations.Potato.NorthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Potato.NorthWestCounter + 1;
		end
    elseif foodType == "Grains" then -- Grains
        Log("Mouse:OnEat = I am eating Grains")
		--self:PrintTable(self.mouseDataTable);
		--self.mouseDataTable.defaultTable.ToEat.Grains = self.mouseDataTable.defaultTable.ToEat.Grains - 1;

		-- Update location table
		if quadrant == "North-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Grains.NorthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Grains.NorthEastCounter + 1;
		elseif quadrant == "South-East" then
			self.mouseDataTable.defaultTable.FoodLocations.Grains.SouthEastCounter = self.mouseDataTable.defaultTable.FoodLocations.Grains.SouthEastCounter + 1;
		elseif quadrant == "South-West" then
			self.mouseDataTable.defaultTable.FoodLocations.Grains.SouthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Grains.SouthWestCounter + 1;
		else
			self.mouseDataTable.defaultTable.FoodLocations.Grains.NorthWestCounter = self.mouseDataTable.defaultTable.FoodLocations.Grains.NorthWestCounter + 1;
		end
    elseif foodType == "PowerBall" then -- PowerBall
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