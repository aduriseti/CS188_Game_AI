Food = {
  type = "Food",                                   -- can be useful for scripting
    
  -- Instance vars
  --Model_Dimensions = {Width = 0, Height = 0, Z = 0},
  Model = "",
  
  -- Copied from BasicEntity.lua
  Properties = {
     bUsable = 1,
     sUseMessage = "Eat",
	 object_Model = "Objects/default/primitive_sphere_small.cgf",
     
     -- Cheese = 0, Berry = 1, Potato = 2, Grains = 3, PowerBall = 4
     esFoodType = "Cheese",                 
     
    
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

MakeUsable(Food);

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     Entity State Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
function Food:OnInit()
    
    self:OnReset()
end

function Food:OnPropertyChange()
    --Log("OnPropertyChange is running");
    
    self:SetFromProperties();
    self:OnReset();
end

function Food:OnReset()
    --Log("OnReset is running");
    self:SetupModel()
end

----------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Helper Function                  ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

function Food:SetupModel()
        
    local Properties = self.Properties;
    local foodType = Properties.esFoodType;
    local model = "";
    Log(foodType)
    
    if foodType == "Cheese" or foodType == "0" then     -- Cheese
        Log("I am cheese")
        model = "Objects/yellow cheese.cgf"
    elseif foodType == "Berry" or foodType == "1" then -- Berry
        Log("I am Berry")
        model = "Objects/apple.cgf"
    elseif foodType == "Potato" or foodType == "2" then -- Potato
        model = "Objects/croissant.cgf"
    elseif foodType == "3" or foodType == "Grains" then -- Grains
        model = "Objects/walnut.cgf"
    elseif foodType == "4" or foodType == "PowerBall" then -- PowerBall
        model = "Objects/default/primitive_cylinder.cgf"
    else
        Log("Going to default")
        model = Properties.object_Model
    end
    
    if(model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,model)  -- Load model into main entity  
            
        --self:SetModelDimensions();
        
        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
    end
    
end

function Food:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function Food:SetFromProperties()
    --Log("In SetFromProperties")
    
	--local Properties = self.Properties;
	--local type = Properties.esFoodType;
    --Log(type)
	--if (Properties.object_Model == "") then
	--	do return end;
	--end    

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- Functions -------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Food:Eaten()
    self:DeleteThis()
    
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- Usability -------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function Food:IsUsable(userId)
    return 2;
end

function Food:GetUseableMessage(index)
    if(self.Properties.bUsable == 1) then
        return self.Properties.sUseMessage;
    else 
        return "Is Not Usable";
    end
end

function Food:OnUsed(userId, index)
    Log("Used")
    userId:OnEat(self.Properties.esFoodType)
end