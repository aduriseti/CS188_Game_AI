Rotating = {
    Properties = {
        object_Model = "objects/default/primitive_cube.cgf",
        fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
        --entName = "Maze1",
		entName = "",
        bActive = 0,
    },
    Editor = { Icon = "Checkpoint.bmp", },
    entID = "",
    angles = 0, 
    pos = 0,
};

function Rotating:OnInit() 
    self:OnReset();
end

function Rotating:OnPropertyChange() 
    self:OnReset();
end

function Rotating:OnReset()
    
    if (self.Properties.object_Model ~= "") then
        self:LoadObject(0, self.Properties.object_Model); 
        
        if (self.Properties.entName ~= "") then 
            self.entID = System.GetEntityByName(self.Properties.entName); 
			Log(tostring(self.entID));
			Log(self.entID.type);

       else 
			--Log("Error: Target entity not set!"); 
			local nearby_entities = System.GetEntities(self:GetPos(), 1000);
			--Log(tostring(nearby_entities));
			for key, value in pairs( nearby_entities ) do
				if (tostring(value.type) == "Player") then
					Log(tostring(key) .. tostring(value));
					Log(tostring(value.type));
					self.entID = value;
				end
			end
		end
		self.angles = self:GetAngles(); --gets the current angles of Rotating
		self.pos = self:GetPos(); --gets the current position of Rotating
		self:Activate(self.Properties.bActive); --set OnUpdate() on/off
    else Log("Error: Modelname not found!"); end
end

function Rotating:OnUpdate(frameTime)
	Log("In OnUpdate");
	Log("Frame at time" .. tostring(frameTime))
    self:FaceAt(self.entID, frameTime); 
end

function Rotating:FaceAt(ID, fT)
	Log("In FaceAt");
    local a = self.pos;
    local b = ID:GetPos();
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.fRotSpeed*fT));  
    self:SetAngles(self.angles);

end


--[[
Rotating = {
    Properties = {
		am_active = 0;
		ent_name = "Maze1",
		rot_speed = 3,
        object_Model = "objects/default/primitive_cube.cgf",
    },
	ent_ID = "",
	angles = 0,
	pos = 0,
    Editor = { Icon = "Checkpoint.bmp", },
};

function Rotating:OnInit() -- use OnSpawn if you want to spawn this entity on the fly
	Log("In OnInit");
    self:OnReset();
end

function Rotating:OnPropertyChange() --makes for realtime updating when in the editor
    self:OnReset();
end

function Rotating:OnReset()
	Log("In OnReset");
    if (self.Properties.object_Model ~= "") then --makes sure a model is specified
            self:LoadObject(0, self.Properties.object_Model); -- loads the model
			
			if (self.Properties.ent_name ~= "") then
				self.ent_ID = System.GetEntityByName(self.Properties.ent_name);
				--Log("Target entity ID ")
				self.angles = self:GetAngles();
				self.pos = self:GetPos();
				self:Activate(self.Properties.am_active);
			else 
				Log("Gotta pick an entity bro"); 
			end
    else 
		Log("No model specified"); 
	end

end

function Rotating:OnUpdate (frame_Time) 
	
	self:FaceAt(self.EntId, frame_Time)
	
end

function Rotating:FaceAt(ID,fT)
	Log("ID: " .. tostring(ID));
    local a = self.pos;
    local b = ID:GetPos();
    local newAngle = math.atan2 (b.y-a.y, b.x-a.x);    
    
    local difference =((((newAngle - self.angles.z) % (2 * math.pi)) + (3 * math.pi)) % (2 * math.pi)) - math.pi;
    newAngle = (self.angles.z + difference);
    
    self.angles.z = Lerp(self.angles.z, newAngle, (self.Properties.nRotSpeed*fT));  
    self:SetAngles(self.angles);

end

]]