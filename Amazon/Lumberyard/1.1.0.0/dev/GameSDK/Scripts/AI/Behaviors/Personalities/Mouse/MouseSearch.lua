-- MouseSearch behavior

local Behavior = CreateAIBehavior("MouseSearch",
{
	Alertness = 0,

	Constructor = function (self, entity)
        Log("============")
        Log("SEARCHING!");
        Log("============")
        AI.SetBehaviorVariable(entity.id, "Hungry", true);
        entity:SelectPipe(0, "mouse_search");    
    end,

    Destructor = function(self, entity)
    end,

    --[[
    AnalyzeSituation = function (self, entity, sender, data)
        local range = 2.5;
        local distance = AI.GetAttentionTargetDistance(entity.id);

        Log("Distance in approach:");
        Log(distance);

        if(distance > (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", false);
        elseif(distance < (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", true);
        end

    end,
    ]]
})