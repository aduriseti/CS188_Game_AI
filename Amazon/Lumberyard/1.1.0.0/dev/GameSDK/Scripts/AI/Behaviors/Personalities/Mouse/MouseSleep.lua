-- MouseSleep behavior

local Behavior = CreateAIBehavior("MouseSleep",
{
    Alertness = 0,

    Constructor = function (self, entity)
        entity:Sleep();
        Log("=======")
        Log("...ZZZZZZ...")
        Log("=======")
        AI.SetBehaviorVariable(entity.id, "Hungry", false);
        AI.SetBehaviorVariable(entity.id, "AwareOfEnemy", false);
        entity:SelectPipe(0,"mouse_sleep");
    end,

    --[[

    AnalyzeSituation = function (self, entity, sender, data)
        local range = 2.5;
        local distance = AI.GetAttentionTargetDistance(entity.id);

        Log("Distance in attack:")
        Log(distance);

        if(distance > (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", false);
        elseif(distance < (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", true);
        end

    end,    

    ]]
})