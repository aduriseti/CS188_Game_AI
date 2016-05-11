----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    LivingEntity Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

LivingEntityBase = {
  
  type = "LivingEntity",                                   -- can be useful for scripting
  
  -- Instance Vars
    entID = "",
    angles = 0, 
    pos = {},
    state = "",

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
  
  -- optional editor information taken from BasicEntity.lua
  Editor = {
	 	Icon = "Checkpoint.bmp",
		IconOnTop=1,
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
};

-- I DUNNO WTF THIS IS I COPIED FROM BasicEntity.lua
local Physics_DX9MP_Simple = {
	bPhysicalize = 1, -- True if object should be physicalized at all.
	bPushableByPlayers = 0,
		
	Density = 0,
	Mass = 0,	
}

---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:OnInit() 
    self:OnReset();
end

function LivingEntityBase:OnPropertyChange() 
    self:OnReset();
end

function LivingEntityBase:OnReset()
    self:SetFromProperties()  
end

function LivingEntityBase:OnUpdate(frameTime)
	 
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity

        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
    end
    
    if (self.Properties.entName ~= "") then 
        self.entID = System.GetEntityByName(self.Properties.entName); 
        Log(tostring(self.entID));
        Log(self.entID.type);
    end 
    
    
end

function LivingEntityBase:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		Physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function LivingEntityBase:SetFromProperties()
   
    self.angles = self:GetAngles(); --gets the current angles of Rotating
    self.pos = self:GetPos(); --gets the current position of Rotating
   
	local Properties = self.Properties;
	if (Properties.object_Model == "") then
		do return end;
	end
    
    local nearby_entities = System.GetEntities(self.pos, 100)
    if (self.entID == "") then 
        for key, value in pairs( nearby_entities ) do
            if (tostring(value.type) == Properties.type) then
                self.entID = value;
            end
        end
    end
    
    --if the user has specified the name of an entity to target, use that
    if (self.Properties.maze_ent_name ~= "") then 
        self.mazeID = System.GetEntityByName(self.Properties.maze_ent_name); 
    --else use the first Maze2 found in a radius of 1000 game measurement units (meters?)
    else 
        for key, value in pairs( nearby_entities ) do
            if (tostring(value.type) == "Maze2") then
                self.Maze_Properties.ID = value;
            end 
        end
    end
    
    if (self.Maze_Properties.ID == "") then
        Log("Error: Mouse unable to locate maze");
        return;
    end

    if(self.Player_Properties.ID == "") then
        for key, value in pairs( nearby_entities ) do
            if (tostring(value.type) == "Player") then
                self.Player_Properties.ID = value;
            end 
        end
    end
    
    self:Activate(self.Properties.bActive); --set OnUpdate() on/off
    
    self:SetupModel();

end


----------------------------------------------------------------------------------------------------------------------------------
-------------------------                      Functions                             ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function LivingEntityBase:move_xy(xy)
	self:SetPos({xy.x, xy.y, self.pos.z});
	self.pos.x = xy.x;
	self.pos.y = xy.y;
end

function LivingEntityBase:Move_to_Pos(frameTime, pos) 
	local a = self.pos;
	local b = pos;
    
	self:FaceAt(b, frameTime);
    
	local diff = {x = b.x - a.x, y = b.y - a.y};
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
	if diff_mag < 5 then
		return;
	end
	local speed_mag = self.Properties.m_speed / diff_mag;
    
	self:move_xy({x = a.x + diff.x * speed_mag,
		y = a.y + diff.y * speed_mag});
	
end

function LivingEntityBase:FaceAt(ID, fT)
    local a = self.pos;
    local b = ID:GetPos();
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.fRotSpeed*fT));  
    self:SetAngles(self.angles);

end

function LivingEntityBase:FollowPlayer(frameTime)
	self:FaceAt(self.Player_Properties.ID, frameTime);
	
    local a = self.pos;
	local b = self.Player_Properties.ID:GetPos();

	local diff = {x = b.x - a.x, y = b.y - a.y};
	local diff_mag = math.sqrt(diff.x^2 + diff.y^2);
	if diff_mag < 5 then
		return;
	end
	
    local speed_mag = self.Properties.m_speed / diff_mag;
	
    self:move_xy({x = a.x + diff.x * speed_mag,
		y = a.y + diff.y * speed_mag});
	
end