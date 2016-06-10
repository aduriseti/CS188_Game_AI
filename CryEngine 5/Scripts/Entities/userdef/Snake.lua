--CryEngine
--Script.ReloadScript( "SCRIPTS/Entities/userdef/LivingEntityBase.lua");
--Lumberyard
Script.ReloadScript( "SCRIPTS/Entities/Custom/LivingEntityBase.lua");

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Snake Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Snake = {
	
	type = "Snake",
	
	-- Instance Vars
	max_patrol = 100,
    cur_patrol = 0,
    cur_direction = "NorthEast",
	--pos = {},
	
	States = {"Opened","Closed","Destroyed", "Patrol", "Eat", "EatPlayer"},
	
    Properties = {
        --object_Model = "objects/characters/animals/reptiles/snake/snake.cdf",
        object_Model = "objects/default/primitive_sphere.cgf",
		fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		--m_speed = 0.1;
        --maze_ent_name = "Maze1",f
		maze_ent_name = "",
        bActive = 0,
		entType = "Snake",
        initial_direction = "up",
		
		--Copied from BasicEntity.lua
        --Physics = {
        --    bPhysicalize = 1, -- True if object should be physicalized at all.
         --   bRigidBody = 1, -- True if rigid body, False if static.
         --   bPushableByPlayers = 1,
        
         --   Density = -1,
         --   Mass = -1,
       -- },
    },
	
	Food_Properties = {
		ent_type = "Food",
		
	},
	
	Mouse_Properties = {
		ent_type = "Mouse",
	},
	
	Trap_Properties = {
		ent_type = "Trap",
	},
	
    Editor = { 
		Icon = "Checkpoint.bmp", 
	},
	
	ToEat = {},
	
};

MakeDerivedEntityOverride(Snake, LivingEntityBase);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Snake States                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
Snake.Patrol =
 {

  OnBeginState = function(self)
  	Log("Snake: Entering Patrol State")

  	self.direction = self.directions[up];

  end,
  
  OnEnterArea = function(self, entity, areaId)
	--[[
  		Log("Entered snake area")
		  if(entity.type == "Mouse") then 
		  	self.Player = entity 
			self.Player.pos = entity:GetPos()
			self:GotoState("EatPlayer")
		end 
		--]]
  end, 

  OnUpdate = function(self,time)
  
		  --Log("FUCKERS")
		  --self:myPatrol(time)
		  --[[
		  local target = self:ray_cast("Mouse");
		  if target ~= nil then
		  	self:GotoState("Eat");
		  end
		  
		  local p = self:GetPos()
		  local tab = System.GetEntitiesByClass("MousePlayer")
		  local target2
		  if(#tab > 0) then 
			target2 = tab[1]
			self.PlayID = target2.id
			self.Player = System.GetEntity(self.PlayID)
		  end
		  
		  --Log(#target2)
		  --self:PrintTable(target2)
		 -- Log(target2.class)
		  --Log("Target)
		  
		  if target2.type == "Mouse" then 
			local distance = vecLen(vecSub(target2:GetPos(),p));
			--Log("Distance = %d", distance)
			if distance < 20 then
			
			 	System.DrawLine(self:GetPos(), self.Player.pos, 1, 0, 0, 1);
 				local diff = {x = self.Player.pos.x - self:GetPos().x, y = self.Player.pos.y - self:GetPos().y, z = 0};
 				local fucker = {};
			 	Physics.RayWorldIntersection(self.pos, diff, 1, ent_all, self.id, self.Player.id, fucker);--, self:GetRawId(), target_mouse:GetRawId());
				local n_hits = 0;

				for key, value in pairs(fucker) do
					n_hits = n_hits + 1
				end

				if (n_hits == 0) then
					self:GotoState("EatPlayer");
				end
			end 
		  end 
		  
		  local hitData = {}-- = --System.GetEntitiesInSphereByClass(self:GetPos(), 10, "MousePlayer")
		  local dir = self:GetDirectionVector();
			dir = vecScale(dir, 20);
		  local hits = Physics.RayWorldIntersection({self:GetPos().x, self:GetPos().y, 32}, dir, 1, ent_all, self.id, nil, hitData )
		  local endPos = {dir.x+self:GetPos().x, dir.y+self:GetPos().y, 32}
		   	System.DrawLine(self:GetPos(), endPos, 1, 0, 1, 1);

		--Log(hits)
			if(hits > 0) then 
			--self:PrintTable(hitData)
			if(hitData[1].entity and hitData[1].entity.class == "MousePlayer") then 
				target2 = hitData[1].entity
			end 
		end 

		  if target2 ~= nil then
		  	self:GotoState("EatPlayer");
		  end

		  --]]

		  self:bounce(time);

		  --self:CheckMouseCollision()
		
  end,

  OnEndState = function(self)
  	Log("Snake: Exiting Patrol State")
  end,


 }

Snake.Eat =
{
	OnBeginState = function(self)
		Log("Snake: Enter Eat State")
    --self:Eat();

  	end,

  OnUpdate = function(self,time)
  	
	local continue_chase = self:chase("Mouse", time);

		if continue_chase == false then
			self:GotoState("Patrol");
		else end;

  end,

  OnEndState = function(self)
  	Log("Snake: Exiting Eat State")
  end,
	
}

Snake.EatPlayer =
{
	OnBeginState = function(self)
		Log("Snake: Enter EatPlayer State")
    --self:Eat();

  	end,

  OnUpdate = function(self,time)
  	
		
		if self.Player ~= nil then
			local distance = vecLen(vecSub(self.Player.pos, self:GetPos()));
			--Log("Distance = %d", distance)
			if distance < 1 then
				Log("Distance <= 2, Eat")
				self.Player:OnEat(self, 2);
				self.Player = nil;
				self:GotoState("Destroyed");
			elseif distance > 20 then 
				self:GotoState("Patrol");
			end 
			if(self.Player ~=nil) then 
			self:Move_to_Pos(time, self.Player.pos);
			end
			
		end
		
		if self.Player == nil then 
					self:GotoState("Patrol");
		end 
		

  end,

  OnEndState = function(self)
  	Log("Snake: Exiting EatPlayer State")
  end,
	
}

Snake.Destroyed =
{

    OnBeginState = function( self )

        Log("Snake: IN Destroyed STATE")

    end,


}

Snake.Dead =
{
	
	OnBeginState = function(self)
		Log("Snake: Entering Dead State")
		self:DeleteThis()
  	end,

 	OnUpdate = function(self,time)
  	

	end,

  	OnEndState = function(self)
		--self:SaveXMLData()
  	end,
}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
function Snake:THEFUCK()
	Log("Snake: Thefuck")
	 self:RegisterForAreaEvents(1);
    local v1, v2 = self:GetLocalBBox()
    v2.z = 3
	v2.x = 5*v2.x
	v2.y = 5*v2.y
    LogVec("V1", v1)
    LogVec("V2", v2)
    self:SetTriggerBBox(v1, v2)
		self:GotoState("Patrol");
end 
--sets the Snake's properties
function Snake:abstractReset()
	Log("Snake: In OnReset")

	--self.direction = self.directions.up;
	--Log(tostring(self.direction.row_inc));

	self:GotoState("Patrol");

end

--function Snake:OnCollision
--[[
function Snake:OnUpdate(frameTime)
	--Log("In OnUpdate");
	--Log("Frame at time" .. tostring(frameTime))
	
	if (self.state == "patrol") then
		self:Patrol();
	elseif (self.state == "eat") then
		--self:EatMice();
	else 
	
	end
	-
end
]]
----------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Snake:OnEat(userId, index)
	Log("RIP Snake")
	userId:Eating("Snake")
	self:GotoState("Dead")
end


function Snake:CheckMouseCollision()

	local nearby_entities = System.GetEntities(self.pos, 1)
	local foundMouse = ""
	for key, value in pairs( nearby_entities ) do
        if (tostring(value.type) == "Mouse") then
            foundMouse = value;
        end 
    end

    if foundMouse ~= "" then
		self.ToEat[1] = foundMouse;
    	self:GotoState("Eat")--foundMouse:GetEaten()
    end

end

function Snake:KillMouse()
	self.ToEat[1]:GetEaten()
	self:GotoState("Patrol")
end

function Snake:FaceAt(pos)
    local a = self:GetPos()
    local b = pos
	 local vector=DifferenceVectors(b, a);  -- Vector from player to target

     vector=NormalizeVector(vector);  -- Ensure vector is normalised (unit length)

     self:SetDirectionVector(vector); -- Orient player to the vector
end