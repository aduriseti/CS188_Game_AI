----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Maze Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Maze_Wall = {
  type = "Maze_Wall",                                   -- can be useful for scripting
    
  -- Instance vars
  Model_Dimensions = {Width = 0, Height = 0, Z = 0},
  Model = "",
  
  -- Copied from BasicEntity.lua
  Properties = {
      entType = "Maze_Wall",
     bUsable = 0,
	 object_Model = "objects/default/primitive_cube.cgf",
    -- file_Material = "", 
     --Copied from BasicEntity.lua
     Physics = {
        bPhysicalize = 1, -- True if object should be physicalized at all.
        bRigidBody = 1, -- True if rigid body, False if static.
        bPushableByPlayers = 0,
    
        Density = -1,
        Mass = -1,
     },
  },
  
  -- optional editor information taken from BasicEntity.lua
  Editor = {
	 	Icon = "physicsobject.bmp",
		IconOnTop=1,
  },
  
};

-- I DUNNO WTF THIS IS I COPIED FROM BasicEntity.lua
local Physics_DX9MP_Simple = {
	bPhysicalize = 1, -- True if object should be physicalized at all.
	bPushableByPlayers = 0,
		
	Density = 0,
	Mass = 0,
		
}

-- I dunno, make it usable?
--MakeUsable(Maze_Wall);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Entity State Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------


function Maze_Wall:OnInit()
   
    self:OnReset()
end

function Maze_Wall:OnPropertyChange()
    --Log("OnPropertyChange is running");
    
    self:SetFromProperties();
    self:OnReset();
end

function Maze_Wall:OnReset()
    --Log("OnReset is running");
    self:SetupModel()
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Maze_Wall:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity  
            
        self:SetModelDimensions();
        
        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
    end
    
    --if(Properties.file_Material ~= "") then 
     --   self:SetMaterial(Properties.file_Material)
     --   self.Material = Properties.file_Material;
   -- end
    
end

function Maze_Wall:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		Physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function Maze_Wall:SetFromProperties()
    --Log("In SetFromProperties")
    
	local Properties = self.Properties;
	
	if (Properties.object_Model == "") then
		do return end;
	end    
    
    self.Width = width
    self.Height = height
    self.Map = map
    self.Model = model
    
    self:SetupModel();

end

function Maze_Wall:SetModelDimensions()
    
    local vStart, vEnd = self:GetLocalBBox()
    
    local v = { x=0, y=0, z=0}
    SubVectors(v, vEnd, vStart)
    
    self.Model_Dimensions.Width = v.x
    self.Model_Dimensions.Height = v.y 
    self.Model_Dimensions.Z = v.z
    --Log("Maze_Wall: Model_Width = %d, Model_Height = %d", v.x, v.y);

end

function Maze_Wall:GetModelDimensions()
    return self.Model_Dimensions
end

function Maze_Wall:test()
    Log("Maze_Wall: Function Call worked")
end

function Maze_Wall:TestDelete()
    self:DeleteThis()
end