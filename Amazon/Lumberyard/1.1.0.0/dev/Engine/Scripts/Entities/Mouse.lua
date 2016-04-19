----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Mouse = {
  
  type = "Mouse",                                   -- can be useful for scripting
  MapVisMask = 0,
  ENTITY_DETAIL_ID = 1,

  Properties =
  {
    Movement =
    {
      SpeedMin = 1,
      SpeedMax = 5,
      MaxAnimSpeed = 4,
    },

    Boid =
    {
      nCount = 10, --[0,1000,1,"Specifies how many individual objects will be spawned."]
      object_Model = "objects/characters/animals/rat/rat.cdf",
      Mass = 10,
      bInvulnerable = false,
    },

    Options =
    {
      bPickableWhenAlive = 1,
      bPickableWhenDead = 1,
      PickableMessage = "Squeak: Unhand me sir",
      bFollowPlayer = 0,
      bAvoidWater = 1,
      bObstacleAvoidance = 1,
      VisibilityDist = 50,
      bActivate = 1,
      Radius = 10,
    },

    ParticleEffects =
    {
      
    },

  },

  Audio =
  {
    
  },

  Animations =
  {
    "walk_loop",  -- walking
    "idle01",     -- idle1
  },

  Editor =
  {
    Icon = "Bug.bmp"
  },

  params={x=0,y=0,z=0},
};


----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Entity State Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- Order of Events: (Spawn) -> (Init)

--[[
function Mouse:OnSpawn()
  self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
  self:SetFlagsExtended(ENTITY_FLAG_EXTENDED_NEEDS_MOVEINSIDE, 0);
end
]]

function Mouse:OnInit()
    self:OnReset()
end

function Mouse:OnPropertyChange()
    Log("OnPropertyChange is running");
    self:SetFromProperties();
    self:OnReset();
end

function Mouse:OnReset()
    Log("OnReset is running");
    self:SetupModel()
    
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Mouse:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.Boid.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.Boid.object_Model)  -- Load model into main entity

        --[[
        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        ]]
        
    end
    
end

function Mouse:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		Physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function Mouse:SetFromProperties()
    
	local Properties = self.Properties;
	
	if (Properties.Boid.object_Model == "") then
		do return end;
	end
    
    self:SetupModel();

end


----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     AI Functions                           ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Mouse:Search()

end

function Mouse:Sleep()

end

function Mouse:Avoid()

end