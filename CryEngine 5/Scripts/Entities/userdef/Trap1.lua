----------------------------------------------------------------------------------------------------------------------------------
-------------------------                    Trap1 Table Declaration                 ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

Trap1 =
{
  type = "Trap_Spring",
  States = {"Ready","Sprung"},
  pos = {},
  myFood = {},
  
  Properties =
  {
   object_Model = "objects/default/primitive_box.cgf",
   bActive = 1,
   entType = "Trap",
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
Trap1.Ready =
 {

    OnBeginState = function(self)
        Log("Trap1: Lying in wait to kill")
    end,
    
    OnEnterArea = function(self,entity,areaId)
      Log("Trap1: In my area!")
      if (entity.type == "Mouse") then
        Log("Mouse Entered my Box")
        entity:OnEat(self,2)
        self:GotoState("Sprung")
      end;
   
   end;


  OnEndState = function(self)
  	Log("Trap1: Ima straight killa")
  end,

 }

Trap1.Sprung =
 {

    OnBeginState = function(self)
        Log("Trap1: I killed for my country")
    end,

 }
---------------------------------------------------------------------------------------------------------------------------------
-------------------------                     State Functions                        --------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

function Trap1:OnInit()
    self:OnReset()
end


function Trap1:OnPropertyChange()
    self:OnReset()
end

function Trap1:OnReset()
    self:SetupModel()
    self.pos = self:GetPos(); --gets the current position of Rotating
    self:Activate(1)
    self:RegisterForAreaEvents(1);
    local v1, v2 = self:GetLocalBBox()
    v2.z = 3
    LogVec("V1", v1)
    LogVec("V2", v2)
    self:SetTriggerBBox(v1, v2)

    self:GotoState("Ready")
end
--[[
function Trap1:OnDestroy()
      self.myFood[1]:DeleteThis()
end 
]]
--[[
function Trap1:OnEnterArea(entity, areaID)
    Log("MOTHER FUCKER ENTERED ME BOX")
end
]]

function Trap1:SetupModel()
        
    local Properties = self.Properties;

    if(Properties.object_Model ~= "") then          -- Make sure objectModel is specified
        self:LoadObject(0,Properties.object_Model)  -- Load model into main entity  
            
        --self:SetModelDimensions();
        
        if (Properties.Physics.bPhysicalize == 1) then -- Physicalize it
            self:PhysicalizeThis();
        end
        
        -- Put cheese on top of it to entice mice to it

        local params = {
            class = "Food";
            name = "F";
           -- position = spawnPos;
            --orientation = dVec;
            properties = {
                esFoodType = "Cheese"
              --  object_Model = self.Model;
            };
        };

        local food = System.SpawnEntity(params);
        --local trapPos = self:GetPos();
        --local foodPos = {trapPos.x , trapPos.y - 2, trapPos.z}
        --food:SetPos(foodPos);

       -- self.myFood[1] = food
        self:AttachChild(food.id, 0)

    end
    
end

function Trap1:PhysicalizeThis() -- Helper function to physicalize, Copied from BasicEntity.lua
    -- Init physics.
	local Physics = self.Properties.Physics;
	EntityCommon.PhysicalizeRigid( self,0,Physics,self.bRigidBodyActive );
end

function Trap1:SetFromProperties()
    --Log("In SetFromProperties")
    
	local Properties = self.Properties;
	
	if (Properties.object_Model == "") then
		do return end;
	end    

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------- Functions -------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Trap1:Test()

end

function Trap1:Collide(target_class)
    local target = self:ray_cast(target_class)
    --local target = System.GetEntitiesByClass("Mouse")
    --local target = self:GetEntitiesInContact()
    
    --Log(target)
    --Log("In Collide")
    if(target ~=nil) then
        --Log("Trap: I HAVE SEEN A MOUSE")
        if(target.class ~= "") then 
            local distance = vecLen(vecSub(target.pos, self.pos));
            if distance < 1.1 then 
                Log("Trap: Mouse Triggered -> KILL IT")
                return true, target;                
            end 
        end 
    end 
    
    return false
end

function Trap1:ray_cast(target_class)

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