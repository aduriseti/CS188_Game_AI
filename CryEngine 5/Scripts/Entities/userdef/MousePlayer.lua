
-- Globals

--Mitchel's file path
MousePlayer_Data_Definition_File = "Scripts/Entities/Custom/MousePlayer_Data_Definition_File.xml"
MousePlayer_Default_Data_File = "Scripts/Entities/Custom/DataFiles/MousePlayer_Data_File.xml"

--Amal's file path
--MousePlayer_Data_Definition_File = "Scripts/Entities/userdef/MousePlayer_Data_Definition_File.xml"
--MousePlayer_Default_Data_File = "Scripts/Entities/userdef/DataFiles/MousePlayer_Data_File.xml"

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    MousePlayer Player Table Declaration    ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

MousePlayer = {
	type = "Mouse",
	
	States = {
		"Player",
		"PlayerRecorder",
		"Eat",
		"Sleep",
		"Dead",
		"Power",
	},
	    
    angles = 0,
    pos = {},
	lastTime = 0,
    
    --moveQueue = {},
    nextPos,
	prevPos,
	
	toEat = {Cheese = 2, Berry = 2, Grains = 2, Potato = 2},
	
    Properties = {
    	entType = "MousePlayer",
		bUsable = 0,
        object_Model = "Objects/characters/animals/rat/rat.cdf",
	    --object_Model = "objects/default/primitive_cube_small.cgf",
		fRotSpeed = 10, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.15;

		maze_ent_name = "",         --maze_ent_name = "Maze1",

        bActive = 1,

        MousePlayerDataTable = {},
        
        impulse_modifier = 5,
        
		Physics = {
			
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

    Editor = { 
		Icon = "Checkpoint.bmp", 
	},	
	
	
	eatCount = {
		Cheese = 0,
		Berry = 0,
		Potato = 0,
		Grains = 0,
	},
	
	ToEat = {},
    
    Snake = {
        --pos,
		--entity,
    },
    
    Food = {
        --type = "",
        --pos,
		--entity,
    },
    
    Trap = {
       -- type = "",
       -- pos,
		--entity,
		
    },
	
	Wall = {
		
	},
    
};

function MousePlayer:Round(val)
	local temp = val + 0.5
	temp = math.floor(temp)
	return temp
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    MousePlayer States                 --------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
MousePlayer.PlayerRecorder = 
{
	OnBeginState = function(self)
		Log("MousePlayer: Record state")
		
  	end,
	
	OnUpdate = function(self, time)
	--self:SetScale(5)
		--self.prevPos 
		self:OnUpdate()
		
        -- Recording
		local curPos = self:GetPos()
		local difX = math.abs(curPos.x - self.prevPos.x)
		local difY = math.abs(curPos.y - self.prevPos.y)
		if( (self:Round(curPos.x) ~= self:Round(self.prevPos.x)) or (self:Round(curPos.y) ~= self:Round(self.prevPos.y)) ) then  
        	self:UpdateTable()
		end

        -- See anything new?
        if self:Observe() == false then 
			self:GotoState("Player")
		end 
        
        -- Movement
		--self.prevPos = self:GetPos()
        self:Move()
        
	end,
	
	OnCollision = function(self, hitdata)
		--Log("A COLLISION!")
		local target = hitdata.target
		if target ~= nil then 
			Log("Target.type is "..target.type)
			
			if target.type == "Food" then
				Log("Eating Food")
				local foodType = target.Properties.esFoodType;
				if foodType == "Cheese" or foodType == "0" then     -- Cheese
					--Log("I am cheese")
					self.toEat.Cheese = self.toEat.Cheese - 1
				elseif foodType == "Berry" or foodType == "1" then -- Berry
					--Log("I am Berry")
					self.toEat.Berry = self.toEat.Berry - 1
				elseif foodType == "Potato" or foodType == "2" then -- Potato
					self.toEat.Potato = self.toEat.Potato - 1
				elseif foodType == "3" or foodType == "Grains" then -- Grains
					self.toEat.Grains = self.toEat.Grains - 1
				elseif foodType == "4" or foodType == "PowerBall" then -- PowerBall
					self:GotoState("PowerMode")
				end
				--self:GotoState("Eat")
				target:DeleteThis()
			elseif target.type == "Snake" or target.type == "Trap1" or target.type == "Trap2" then 
				Log("fuck hit a trap/snake")
				self:GotoState("Dead")
			end 
		end
		
	end, 
	
	OnEndState = function(self)
		Log("MousePlayer: Exiting Record State")
		--self:PrintTable(self.Properties.MousePlayerDataTable)
		self:SaveXMLData(self.Properties.MousePlayerDataTable, MousePlayer_Default_Data_File)
		--self.Snake.pos = nil 
		--self.Snake.entity = nil 
		--self.Food.type = nil 
		--self.Food.pos = nil
		--self.Food.entity = nil 
		--self.Trap.type = nil 
		--self.Trap.pos = nil 
		--self.Trap.entity = nil 
	end,
}

MousePlayer.Player = 
{
	OnBeginState = function(self)
		Log("MousePlayer: Player state")
		
  	end,
	
	OnUpdate = function(self, time)
		 --self:SetScale(5)
		 self:OnUpdate()
		 --self:Observe()
		-- Ray trace and check for food, traps, snakes
		 if(self:Observe()) then 
		 	self:GotoState("PlayerRecorder");
		 end 
		          
         -- Movement
         self:Move()
         
	end,
	
	OnCollision = function(self, hitdata)
		--Log("A COLLISION!")
        local target = hitdata.target
		if target ~= nil then 
			Log("Target.type is "..target.type)
			
			if target.type == "Food" then
				Log("Eating Food")
				local foodType = target.Properties.esFoodType;
				if foodType == "Cheese" or foodType == "0" then     -- Cheese
					--Log("I am cheese")
					self.toEat.Cheese = self.toEat.Cheese - 1
					self:PrintTable(self.toEat)
				elseif foodType == "Berry" or foodType == "1" then -- Berry
					--Log("I am Berry")
					self.toEat.Berry = self.toEat.Berry - 1
										self:PrintTable(self.toEat)

				elseif foodType == "Potato" or foodType == "2" then -- Potato
					self.toEat.Potato = self.toEat.Potato - 1
										self:PrintTable(self.toEat)

				elseif foodType == "3" or foodType == "Grains" then -- Grains
					self.toEat.Grains = self.toEat.Grains - 1
										self:PrintTable(self.toEat)

				elseif foodType == "4" or foodType == "PowerBall" then -- PowerBall
					self:GotoState("PowerMode")
				end
				--self:GotoState("Eat")
				target:DeleteThis()
			elseif target.type == "Snake" or target.type == "Trap1" or target.type == "Trap2" then 
				self:GotoState("Dead")
			end 
		end
		
	end, 
	
	OnEndState = function(self)
		Log("MousePlayer: Exiting Player State")

	end,
}


MousePlayer.Eat =
{

	OnBeginState = function(self)
		Log("MousePlayer: Entering Eat State")

  	end,

 	OnUpdate = function(self,time)
	 --self:SetScale(5)
	 		self:OnUpdate()

  		local continue_chase = self:chase("Food", time);

  		if continue_chase == false then
  			self:GotoState("Search");
  		else end;	 	
	end,

  	OnEndState = function(self)
		Log("MousePlayer: Exiting Eat State")
		self:SaveXMLData(self.Properties.MousePlayerDataTable, MousePlayer_Default_Data_File)
		-- Record Food Locs knowledge
  	end,
	
}

MousePlayer.Sleep =
{

	OnBeginState = function(self)
		Log("MousePlayer: Entering SLeep State")
		-- Mark as winner

  	end,

 	OnUpdate = function(self,time)
  	
	  --self:SetScale(5)
		self:OnUpdate()

	end,

  	OnEndState = function(self)

  	end,
	
}

MousePlayer.Dead =
{
	
	OnBeginState = function(self)
		Log("MousePlayer: Entering Dead State")
			--self:SaveXMLData()

			self:DeleteThis()

		-- Mark as Loser
		-- Record learned dangers
  	end,

 	OnUpdate = function(self,time)
  	--self:SetScale(5)
		self:OnUpdate()

	end,

  	OnEndState = function(self)
		--self:SaveXMLData()
  	end,
}

MousePlayer.Power = 
{
	
	OnBeginState = function(self)
		Log("MousePlayer: Entering Power State")
  	end,

 	OnUpdate = function(self,time)
  		--[[
			  if timePassed > powerTime then
			  	self:GotoState("Search")
			  end
			  
			  self:PowerMode();
		  ]]
		self:OnUpdate()
--self:SetScale(5)
	end,

  	OnEndState = function(self)
	  	Log("MousePlayer: Exiting Power State")
  	end,
}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function MousePlayer:OnInit() 
    self:OnReset();
end

function MousePlayer:OnPropertyChange() 
    self:OnReset();
end

function MousePlayer:OnReset()
	--self:SetScale(5)
    self:SetFromProperties() 
	Log("Calling Load XML")
	self.prevPos = self:GetPos();
    self.Properties.MousePlayerDataTable = self:LoadXMLData() 
	--self:PrintTable(self.Properties.MousePlayerDataTable)
	--self:PrintTable(self.Properties.MousePlayerDataTable)
    self:GotoState("Player")
	
end

function MousePlayer:SetupModel()
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity

		local v1, v2 = self:GetLocalBBox()
		
		self.Properties.Physics.Area.box_min = v1
		self.Properties.Physics.Area.box_max = v2

		local m_x = v2.x
		local m_y = v2.y
		--local m_x = 0.25
		--local m_y = 0.05

		self.Properties.Physics.PlayerDim.cyl_r = m_x
		self.Properties.Physics.PlayerDim.cyl_pos = m_y
        self:PhysicalizeThis();
        
    end
	
end

function MousePlayer:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
   
   self:Physicalize(0, PE_LIVING, self.Properties.Physics);
   self:SetPhysicParams(PHYSICPARAM_PLAYERDIM, self.Properties.Physics.PlayerDim)
   self:AwakePhysics(1)
   
end

function MousePlayer:SetFromProperties()
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

    self:Activate(1); --set OnUpdate() on/off

end

function MousePlayer:OnEat(userId, index)
	Log("RIP MousePlayer")
	--self.Properties.MousePlayerDataTable = self:LoadXMLData(MousePlayer_Default_Data_File);
	
	--for i = 1, #self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts do 
		--if self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts[i] == tostring(userId.type) then
			--Log(tostring(userID.type) .. " already in data table");
			self:GotoState("Dead")
		--end
	--end
	--Log("Adding " .. tostring(userID.type) .. " to data table");
	--self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts[#self.Properties.MousePlayerDataTable.defaultTable.KnownDangerEnts + 1] = userID.type;
	--self:SaveXMLData(self.Properties.MousePlayerDataTable, MousePlayer_Default_Data_File);
	--self:GotoState("Dead")
end



-- Loads a XML data file and returns it as a script table
function MousePlayer:LoadXMLData(dataFile)
	dataFile = MousePlayer_Default_Data_File --dataFile	or MousePlayer_Default_Data_File
	return CryAction.LoadXML(MousePlayer_Data_Definition_File, dataFile);
end

-- Saves XML data from dataTable to dataFile
function MousePlayer:SaveXMLData(dataTable, dataFile)
	Log("Saving Data")
	dataFile = dataFile or MousePlayer_Default_Data_File
	dataTable = dataTable or self.Properties.MousePlayerDataTable
	
	--self:PrintTable(dataTable)
	
	CryAction.SaveXML(MousePlayer_Data_Definition_File, dataFile, dataTable);
end


function MousePlayer:OnUpdate(frameTime)
	--self:SetScale(5);
	self.pos = self:GetPos();
	if(self:Full()) then self:GotoState("Sleep") end 
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function MousePlayer:ray_cast(target_class)

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

function MousePlayer:Move(ft)

--[[
    if #self.moveQueue > 1 then 
        local loc = table.remove(self.moveQueue, 1)
        self:MoveTo(loc)

    end 
    ]]
    --self.prevPos = self:GetPos();
    if self.nextPos ~= nil then 
       -- self:MoveTo(self.nextPos, ft)
       self:PhysicsMoveTo(self.nextPos)
       self.nextPos = nil
    end 
    
end

function MousePlayer:MoveTo(loc, ft)
    local a = self:GetPos()
    local b = loc
    
    if a == b then self.nextPos = nil; return; end 
    
    self:FaceAt(loc, ft)
    
    local diff = {x = b.x-a.x, y=b.y-a.y}
    local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
    local speed_mag = self.Properties.m_speed/diff_mag;
    
    local x = a.x + diff.x*speed_mag 
    local y = a.y+diff.y*speed_mag 
    
    self:SetPos({x, y, a.z})
    
end

function MousePlayer:PhysicsMoveTo(loc)

    self:FaceAt(loc)
    
    local distance = DifferenceVectors(loc, self:GetPos())
    local distance_mag = math.sqrt(distance.x^2 + distance.y^2)
    local impulse_mag = distance_mag * self.Properties.impulse_modifier
    self:AddImpulse(-1, self:GetCenterOfMassPos(), self:GetDirectionVector(), impulse_mag, 1)
    
 end

function MousePlayer:FaceAt(pos)
    local a = self:GetPos()
    local b = pos
	 local vector=DifferenceVectors(b, a);  -- Vector from player to target

     vector=NormalizeVector(vector);  -- Ensure vector is normalised (unit length)

     self:SetDirectionVector(vector); -- Orient player to the vector
end

function MousePlayer:Observe()
         -- See anything
        local traps = {};
		local enemies = {};
		local food = {};
		local walls = {};
		
		local hitData = {};
		
		local entities = {};
		entities = System.GetEntitiesInSphere(self:GetPos(), 10)
		--self:PrintTable(entities);

		for x, y in ipairs(entities) do
			if y.class == "Maze_Wall" then 
				walls[#walls+1] = y
			elseif y.class == "Snake" then 
				enemies[#enemies + 1] = y 
			elseif y.class == "Food" then 
				food[#food+1] = y 
			elseif y.class == "Trap1" or y.class == "Trap2" then 
				traps[#traps+1] = y 
			end 
		end 
		
		self.Trap = traps 
		self.Snake = enemies
		self.Food = food 
		self.Wall = walls 
		
		if(#traps > 0 or #enemies > 0 or #food > 0) then 
			return true;
		end 
		
		
		-- Old way with Raycast
		--[[
		local dir = self:GetDirectionVector();
		
		dir = vecScale(dir, 50); --See up to 50 away
		local hits = Physics.RayWorldIntersection(self:GetPos(), dir, 5, ent_all, self.id, nil, hitData )
		if(hits > 0) then 

			if(hitData[1].entity) then
			
				if(hitData[1].entity.class == "Trap1" or hitData[1].entity.class == "Trap2") then 
					Log("Observing TrAP")
					trap = hitData[1].entity
				end
				if(hitData[1].entity.class == "Snake") then 
					Log("Observing Snake")
					enemy = hitData[1].entity
				end 
				if(hitData[1].entity.class == "Food") then 
					Log("Observing Food")
					food = hitData[1].entity 
				end 
				
			end 
			
		end 
		
		--food = self:ray_cast("Food");
		--]]
		--[[
		if(trap ~=nil and trap.class == "Trap1" and food == nil) then 
		   --Log("Mouse: Sees trap")
		   local child = trap:GetChild(0)
		   --self:PrintTable(child)
		   food = child;	
		end 
		
		if(trap ~= nil) then 
			Log("Trap not nil")
			Log("Trap type is "..trap.type)
			self.Trap.type = trap.type
			self.Trap.pos = trap:GetPos()
			self.Trap.entity = trap;
		else 
			self.Trap.entity = nil;
		end 
	  
		--enemy = self:ray_cast("Snake");
		
		if(food ~= nil) then 
			Log("Food not nil")
			Log("Food type is "..food.Properties.esFoodType)
			self.Food.type = food.Properties.esFoodType
			self.Food.pos = food:GetPos()
			self.Food.entity = food;
		else 
			self.Food.entity = nil;
		end 
		
		if(enemy ~= nil) then 
			Log("Snake not nil")
			self.Snake.pos = enemy:GetPos()
			self.Snake.entity = enemy;
		else 
			self.Snake.entity = nil;
		end 
		
		if(enemy ~= nil or trap ~= nil or food ~= nil) then 
			return true;
		else
			return false;
		end 
		
		--]]
		
		return false;
end 

function MousePlayer:Full()
	local toDo = self.toEat
	
	if toDo.Cheese < 1 and toDo.Berry < 1 and toDo.Grains < 1 and toDo.Potato < 1 then 
		return true 
	end 
	
	return false
end 

function MousePlayer:UpdateTable()
	
	local God = self.Properties.MousePlayerDataTable.defaultTable.God
		-- New Index 
		local index = #God+1
		
		local newElement = {

		}

	table.insert(self.Properties.MousePlayerDataTable.defaultTable.God, index, newElement)

	local curTime = System.GetCurrTime()
	local timeSinceLast = curTime - self.lastTime
	self.lastTime = curTime
	
	self.Properties.MousePlayerDataTable.defaultTable.God[index].Time = timeSinceLast
	self.Properties.MousePlayerDataTable.defaultTable.God[index].MouseLocCur = self:GetPos();
	self.prevPos = self:GetPos();
	self.Properties.MousePlayerDataTable.defaultTable.God[index].MouseLocTo = self.nextPos or {x=0,y=0,z=0}

	local WallStr, SnakeStr, TrapStr, FoodStr = "", "", "", ""
	
	for x,y in ipairs(self.Wall) do 
		WallStr = WallStr..y:GetPos().x..","..y:GetPos().y..","..y:GetPos().z.."; "
	end 
	for x,y in ipairs(self.Snake) do 
		SnakeStr = SnakeStr..y:GetPos().x..","..y:GetPos().y..","..y:GetPos().z.."; "
	end 		
	for x,y in ipairs(self.Trap) do 
		TrapStr = TrapStr..y:GetPos().x..","..y:GetPos().y..","..y:GetPos().z.." - "..y.type.."; "

		--defT[clickDex].Traps[x].TrapType = y.type or ""--.TrapLoc = y:GetPos() or {x=0,y=0,z=0} ;
		--clicks[clickDex].clickTable.Traps[x].TrapType = y.type or "";		
	end 
	for x,y in ipairs(self.Food) do 
		--clicks[clickDex].clickTable.Foods[x] = {FoodLoc = y:GetPos() or {x=0,y=0,z=0}, FoodType = y.Properties.esFoodType or ""}
		--defT[clickDex].Foods[x] = {}
		--defT[clickDex].Foods[x].FoodType = y.type or ""
		--clicks[clickDex].clickTable.Foods[#clicks[clickDex].clickTable.Foods + 1] = y.Properties.esFoodType or "";
		FoodStr = FoodStr..y:GetPos().x..","..y:GetPos().y..","..y:GetPos().z.." - "..y.Properties.esFoodType.."; "
	end 

	self.Properties.MousePlayerDataTable.defaultTable.God[index].AllWalls = WallStr
	self.Properties.MousePlayerDataTable.defaultTable.God[index].AllSnakes = SnakeStr
	self.Properties.MousePlayerDataTable.defaultTable.God[index].AllTraps = TrapStr
	self.Properties.MousePlayerDataTable.defaultTable.God[index].AllFoods = FoodStr


--[==[
	--self:PrintTable(self.Properties.MousePlayerDataTable.defaultTable.Locations)
    -- Locations 
    local locations = self.Properties.MousePlayerDataTable.defaultTable.Locations
    -- New Index 
    local index = #locations+1
	
	local newElement = {
		--[[
		MouseLocCur = self:GetPos();
		MouseLocTo = self.nextPos;
		SnakeLoc = self.Snake.pos;
		TrapLoc = self.Trap.pos;
		TrapType = self.Trap.type;
		FoodLoc = self.Food.pos;
		FoodType = self.Food.type;
		]]
	}
	
	table.insert(self.Properties.MousePlayerDataTable.defaultTable.Locations, index, newElement)
    
	locations[index].MouseLocCur = self:GetPos() --or {x=0,y=0,z=0}
    
	local timeSinceLast = System.GetCurrTime() - self.lastTime
	locations[index].Time = timeSinceLast
	
	if self.nextPos == nil then 
		locations[index].MouseLocTo = {x=0,y=0,z=0}
	else 
		locations[index].MouseLocTo = self.nextPos --or {x=0,y=0,z=0}
    end
	if self.Snake.entity == nil then 
		locations[index].SnakeLoc = {x=0,y=0,z=0}
	else 
		locations[index].SnakeLoc = self.Snake.entity:GetPos() --or {x=0,y=0,z=0}
    end
	if self.Trap.entity == nil then 
		locations[index].TrapLoc = {x=0,y=0,z=0}
	else 
    	locations[index].TrapLoc = self.Trap.pos --or {x=0,y=0,z=0}
    end
	if self.Trap.entity == nil then 
		locations[index].TrapType = ""
	else 
		Log("Logging trap type = " .. self.Trap.type)
		locations[index].TrapType = self.Trap.entity.type --or ""
    end
	if self.Food.entity == nil then 
		locations[index].FoodLoc = {x=0,y=0,z=0}
	else 
	    locations[index].FoodLoc = self.Food.entity:GetPos() --or {x=0,y=0,z=0}
	end 
	if self.Food.entity == nil then 
		locations[index].FoodType = ""
	else 
		locations[index].FoodType = self.Food.entity.Properties.esFoodType --or ""
	end 
	
	self:SaveXMLData()
--]==]
self:SaveXMLData()
end

function MousePlayer:PrintTable(t)

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

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    MousePlayer FlowGraph Utilities         ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--[[
  function MousePlayer:QueueMoveTo(loc)
    self.moveQueue[#self.moveQueue+1] = loc 
    
end
]]

function MousePlayer:NextMove(sender, pos)
    --self:OnUpdate()
	--self:SetScale(5)
	self.nextPos = pos;
    self.nextPos.z = 32;
	--if(self:GetState() == "PlayerRecorder") then self:UpdateTable() end;
end 

function MousePlayer:ChangeDir(sender, pos)
	--self:OnUpdate()
	--self:SetScale(5)
	self:FaceAt(pos)
end

function MousePlayer:GetStats(sender, ent)
	--local table = self.toEat

	self:ActivateOutput("ToEatCheese", self.toEat.Cheese)
	self:ActivateOutput("ToEatBerry", self.toEat.Berry)
	self:ActivateOutput("ToEatGrains", self.toEat.Grains)
	self:ActivateOutput("ToEatPotato", self.toEat.Potato)
end

MousePlayer.FlowEvents = 
{
    Inputs = 
	{	
		--Coordinates = {MousePlayer.QueueMoveTo, "Vec3"},
        Coordinates = {MousePlayer.NextMove, "Vec3"},
		FacePos = {MousePlayer.ChangeDir, "Vec3"},
		Stats = {MousePlayer.GetStats, "bool"}
	},

	Outputs = 
	{
		ToEatCheese = "int",
		ToEatBerry = "int",
		ToEatGrains = "int",
		ToEatPotato = "int",
	},
}