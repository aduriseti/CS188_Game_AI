Rotating = {
	type = "Mouse",
	
    Properties = {
        object_Model = "objects/default/primitive_cube_small.cgf",
        fRotSpeed = 3, --[0.1, 20, 0.1, "Speed of rotation"]
		m_speed = 1;
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