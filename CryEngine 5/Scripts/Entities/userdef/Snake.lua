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
	
	States = {"Opened","Closed","Destroyed", "Patrol", "Eat"},
	
    Properties = {
        --object_Model = "objects/characters/animals/reptiles/snake/snake.cdf",
        object_Model = "objects/default/primitive_sphere.cgf",
		fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 0.1;
        --maze_ent_name = "Maze1",f
		maze_ent_name = "",
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

  end,

  OnUpdate = function(self,time)
  
		  --Log("FUCKERS")
		  self:myPatrol(time)

		  self:CheckMouseCollision()
		
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
  	
	self:KillMouse()
    --if (--[[ Lose Sight ]]) then
      --self:GotoState("Patrol");
    --end

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

  

    OnUpdate = function(self, dt)

       -- self:OnUpdate();

    end,

}
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

--sets the Mouse's properties
function Snake:abstractReset()
	--Log("In OnResettttttttt")
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

function Snake:myPatrol(time)
	if (self.cur_patrol ~= self.max_patrol and self.cur_direction == "NorthEast") then
		self:MoveNorthEast(time);
		self.cur_patrol = self.cur_patrol + 1;
	elseif (self.cur_patrol ~= self.max_patrol and self.cur_direction == "SouthWest") then
		self:MoveSouthWest(time);
		self.cur_patrol = self.cur_patrol + 1;
	elseif (self.cur_patrol == self.max_patrol and self.cur_direction == "NorthEast") then
		self.cur_direction = "SouthWest";
		self.cur_patrol = 0;
	else
		self.cur_direction = "NorthEast";
		self.cur_patrol = 0;
	end
		
end

function Snake:MoveNorthEast(frameTime) 

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	local row = rowcol.row
	local col = rowcol.col
	
	local grid = self.Maze_Properties.grid;
	local maxX, maxY = #grid, #grid[1]
	
	-- Check if snake can move north, then east, then west, then south
	if (row-1 > 0 and row-1 <= maxX and col > 0 and col <= maxY) and (self.Maze_Properties.grid[row-1][col].occupied == false) then		-- North
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row-1, col);
		self:Move_to_Pos(frameTime, pos);
	elseif (row > 0 and row <= maxX and col+1 > 0 and col+1 <= maxY) and (self.Maze_Properties.grid[row][col+1].occupied == false) then	-- East
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col+1);
		self:Move_to_Pos(frameTime, pos);
	elseif (row > 0 and row <= maxX and col-1 > 0 and col-1 <= maxY) and (self.Maze_Properties.grid[row][col-1].occupied == false) then	-- West
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col-1);
		self:Move_to_Pos(frameTime, pos);
	elseif (row+1 > 0 and row+1 <= maxX and col > 0 and col <= maxY) and (self.Maze_Properties.grid[row+1][col].occupied == false) then	-- South
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row+1, col);
		self:Move_to_Pos(frameTime, pos);
	end
	--Log(tostring(self:GetPos().x) .. tostring(self.pos.x));
	
end

function Snake:MoveSouthWest(frameTime) 

	local rowcol = self.Maze_Properties.ID:pos_to_rowcol(self:GetPos());
	local row = rowcol.row
	local col = rowcol.col
	
	local grid = self.Maze_Properties.grid;
	local maxX, maxY = #grid, #grid[1]
	
	-- Check if snake can move south, then west, then east, then north
	if (row+1 > 0 and row+1 <= maxX and col > 0 and col <= maxY) and (self.Maze_Properties.grid[row+1][col].occupied == false) then		-- South
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row+1, col);
		self:Move_to_Pos(frameTime, pos);
	elseif (row > 0 and row <= maxX and col-1 > 0 and col-1 <= maxY) and (self.Maze_Properties.grid[row][col-1].occupied == false) then	-- West
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col-1);
		self:Move_to_Pos(frameTime, pos);
	elseif (row > 0 and row <= maxX and col+1 > 0 and col+1 <= maxY) and (self.Maze_Properties.grid[row][col+1].occupied == false) then	-- East
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row, col+1);
		self:Move_to_Pos(frameTime, pos);
	elseif (row-1 > 0 and row-1 <= maxX and col > 0 and col <= maxY) and (self.Maze_Properties.grid[row-1][col].occupied == false) then	-- North
		local pos = self.Maze_Properties.ID:rowcol_to_pos(row-1, col);
		self:Move_to_Pos(frameTime, pos);
	end
	--Log(tostring(self:GetPos().x) .. tostring(self.pos.x));
	
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