----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Trap2 Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Trap2 =
{
  type = "Trap_Thwomp",
  States = {"Up","Down"},
  pos = {},
  --myFood = {},
  
  Properties =
  {
   entType = "Trap",
   object_Model = "objects/default/primitive_cube.cgf",
   bActive = 1,
   m_speed = 0.005,
   Physics = {
        bPhysicalize = 1, -- True if object should be physicalized at all.
        bRigidBody = 1, -- True if rigid body, False if static.
        bPushableByPlayers = 0,
    
        Density = -1,
        Mass = -1,
     },
     
  },
  
  Editor =
  {
	 	Icon = "physicsobject.bmp",
        IconOnTop = 1
  }
}

---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     States                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
Trap2.Up =
 {

    OnBeginState = function(self)
        Log("Trap2: Time to CRUSH! Down we gooooo~")
        --self:MoveTo(32)
        --self:GotoState("Down")
    end,

    OnUpdate = function(self, dt)

        self:MoveTo(32)
        --LogVec("Up Update, MyPos", self:GetPos())
        if(self:GetPos().z <= 32) then 
            self:GotoState("Down")
        end 

    end,
    
   --[[ OnEnterArea = function(self,entity,areaId)
        if (entity.type == "Mouse") then
            Log("Mouse Entered my Box")
            entity:OnEat(self,2)
            --self:GotoState("Sprung")
        end;
     end,]]
    
    
    OnCollision = function(self, hitdata)
        Log("A COLLISION!")
        local target = hitdata.target
        Log("Target.type is "..target.type)
        if target.type == "Mouse" then
               Log("Trap2: CRUSH LIL MOUSEY");
               target:OnEat(self,2)
               
        end
    end,

  OnEndState = function(self)
  	Log("Trap2: Kill? Goin' up~ ")
    --self:Kill()
  end,

 }

Trap2.Down =
 {

    OnBeginState = function(self)
        Log("Trap2: Up up and away")
        --self:MoveTo(34)
    end,
    
    OnUpdate = function(self, dt)

        self:MoveTo(34)
        if(self:GetPos().z >= 34) then 
            self:GotoState("Up")
        end 
    end,
      
      OnEndState = function(self)
        
      end,

 }
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function Trap2:OnInit()
    self:OnReset()
end


function Trap2:OnPropertyChange()
    self:OnReset()
end

function Trap2:OnReset()
    self:SetupModel()
    self.pos = self:GetPos(); --gets the current position of Rotating
    self:Activate(1)
    self:RegisterForAreaEvents(1);
    local v1, v2 = self:GetLocalBBox()

    self:SetTriggerBBox(v1, v2)
    self:GotoState("Up")
end


function Trap2:OnCollision(hitdata)
    Log("In OnCollision Main")
end 


function Trap2:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity  
            
        --self:SetModelDimensions();
        
        --if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
       --end

    end
    
end

function Trap2:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
    --[[
	local Physics = self.Properties.Physics;
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
    ]]
    self:Physicalize (0, PE_RIGID, {mass = 0})
   self:AwakePhysics(1)
end

function Trap2:SetFromProperties()
    --Log("In SetFromProperties")
    
	local Properties = self.Properties;
	
	if (Properties.object_Model == "") then
		do return end;
	end    

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- Functions -------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Trap2:MoveTo(dz)
    local a = self:GetPos()
    local b = {x= a.x, y= a.y, z= dz}

    local diff = {x=0, y=0, z= dz-a.z}
    local diff_mag = math.abs(diff.z )
    local speed_mag = self.Properties.m_speed/diff_mag 

    local dD = diff.z*speed_mag
    local nZ = a.z+dD
    self:Move({x=a.x, y=a.y, z=a.z+diff.z*speed_mag})
    
end

function Trap2:Move(new)
    self:SetPos(new)
end 


function Trap2:Kill()
    Log("In Kill")
    
end 
