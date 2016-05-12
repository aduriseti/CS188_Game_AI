--Amal's file path
--Script.ReloadScript( "SCRIPTS/Entities/userdef/LivingEntityBase.lua");

--Mitchel's file path
Script.ReloadScript( "SCRIPTS/Entities/Custom/LivingEntityBase.lua");


-- Globals

--Mitchel's file path
Mouse_Data_Definition_File = "Scripts/Entities/Custom/Mouse_Data_Definition_File.xml"
Mouse_Default_Data_File = "Scripts/Entities/Custom/DataFiles/Mouse_Data_File.xml"

--Amal's file path
--Mouse_Data_Definition_File = "Scripts/Entities/userdef/Mouse_Data_Definition_File.xml"
--Mouse_Default_Data_File = "Scripts/Entities/userdef/DataFiles/Mouse_Data_File.xml"

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

	ToEat = {},

};

MakeDerivedEntityOverride(Mouse, LivingEntityBase);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Mouse States                 --------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
Mouse.Search =
 {

  OnBeginState = function(self)
  	Log("Mouse: Entering Search State")

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

	  	self:CheckFoodCollision()
		

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
		  
		  --self:Avoid()

	end,

  	OnEndState = function(self)
		Log("Mouse: Exiting Avoid State")
  	end,
	
}

Mouse.Eat =
{

	OnBeginState = function(self)
		Log("Mouse: Entering Eat State")
		--[[
			GetNearbyFood Entity
		]]
  	end,

 	OnUpdate = function(self,time)
  		-- Call Nearby foodEntity's Eat function
  		ToEat[1]:OnUsed(self)	 	
	end,

  	OnEndState = function(self)
		Log("Mouse: Exiting Eat State")
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
			self:DeleteThis()

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

function Mouse:GetEaten()
	Log("RIP Mouse")
	self:GotoState("Dead")
end

--sets the Mouse's properties
function Mouse:abstractReset()
	--Log("In Mouse AbstractReset");
	
	-- Load Knowledge Base in
	self.mouseDataTable = self:LoadXMLData() -- Optional Parameter to SPecify what file to read
	
	--self:PrintTable(self.mouseDataTable)
	
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

function Mouse:CheckFoodCollision()
	local nearby_entities = System.GetEntities(self.pos, 1)
	local foundFood = ""
	for key, value in pairs( nearby_entities ) do
        if (tostring(value.type) == "Food") then
            foundFood = value;
        end 
    end

    if foundFood ~= "" then
		self.ToEat[1] = foundFood;
    	self:GotoState("Eat")--foundMouse:GetEaten()
    end
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

    self:GotoState("Search")
	
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
