-- MouseAvoid behavior

local Behavior = CreateAIBehavior("MouseAvoid",
{
    Alertness = 2,

    Constructor = function (self, entity)
        Log("=======")
        Log("FUCK ME")
        Log("=======")        
        AI.SetBehaviorVariable(entity.id, "AwareOfEnemy", true);
        entity:SelectPipe(0,"mouse_avoid");
    end,    

    Destructor = function(self, entity)
    end,

   --[[
    AnalyzeSituation = function (self, entity, sender, data)
        local range = 2.5;
        local distance = AI.GetAttentionTargetDistance(entity.id);
        if(distance > (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", false);
        elseif(distance < (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", true);
        end

    end,
    ]]
})