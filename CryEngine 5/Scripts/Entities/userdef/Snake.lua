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
	
	States = {"Opened","Closed","Destroyed", "Patrol", "Eat"},
	
    Properties = {
        --object_Model = "objects/characters/animals/reptiles/snake/snake.cdf",
        object_Model = "objects/default/primitive_sphere.cgf",
		fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		--m_speed = 0.1;
        --maze_ent_name = "Maze1",f
		maze_ent_name = "",
        bActive = 0,

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

  OnUpdate = function(self,time)
  
		  --Log("FUCKERS")
		  --self:myPatrol(time)

		  local target = self:ray_cast("Mouse");

		  if target ~= nil then
		  	self:GotoState("Eat");
		  end

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

Snake.Destroyed =
{

    OnBeginState = function( self )

        Log("Snake: IN Destroyed STATE")

    end,


}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
function Snake:THEFUCK()
	Log("Snake: Thefuck")
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