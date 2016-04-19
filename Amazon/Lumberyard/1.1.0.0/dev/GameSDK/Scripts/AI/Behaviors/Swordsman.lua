-- Swordsman Behaviors

-- SwordsmanApproach behavior.
-- Based on a file created by the_grim

CreateAIBehavior("SwordsmanApproach",
{
    Alertness = 2,

    Constructor = function (self, entity)
        Log("============")
        Log("Approaching!");
        Log("============")
        entity:SelectPipe(0, "swordsman_approach");    
    end,

    Destructor = function(self, entity)
    end,

    OnGroupMemberDiedNearest = function ( self, entity, sender,data)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);
    end,

    OnGroupMemberDied = function( self, entity, sender)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);        
    end,

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
})

-- SwordsmanAttack behavior by the_grim
-- Based on FogOfWarAttack by Francesco Roccucci

CreateAIBehavior("SwordsmanAttack",
{
    Alertness = 2,

    Constructor = function (self, entity)
        entity:MakeAlerted();
        entity:DrawWeaponNow();
        Log("=======")
        Log("Attack!")
        Log("=======")
        entity:SelectPipe(0,"swordsman_attack");
    end,

    OnGroupMemberDiedNearest = function ( self, entity, sender,data)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);
    end,

    OnGroupMemberDied = function( self, entity, sender)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);        
    end,

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
})

-- SwordsmanIdle behavior
-- Created by the_grim

CreateAIBehavior("SwordsmanIdle",
{
    Alertness = 0,

    Constructor = function (self, entity)
        Log("Idling...");
        AI.SetBehaviorVariable(entity.id, "AwareOfPlayer", false);
        entity:SelectPipe(0,"swordsman_idle");
        entity:DrawWeaponNow();
    end,    

    Destructor = function(self, entity)
    end,

    OnGroupMemberDiedNearest = function ( self, entity, sender,data)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);
        end,
    OnGroupMemberDied = function( self, entity, sender)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);        
    end,

    AnalyzeSituation = function (self, entity, sender, data)
        local range = 2.5;
        local distance = AI.GetAttentionTargetDistance(entity.id);
        if(distance > (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", false);
        elseif(distance < (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", true);
        end

    end,
})

-- SwordsmanSeek behavior
-- Created by the_grim

CreateAIBehavior("SwordsmanSeek",
{
    Alertness = 2,

    Constructor = function (self, entity)
        Log("Seeking!");
        entity:SelectPipe(0, "swordsman_seek");    
    end,

    Destructor = function(self, entity)
    end,

    OnGroupMemberDiedNearest = function ( self, entity, sender,data)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);
    end,
    OnGroupMemberDied = function( self, entity, sender)
        AI.SetBehaviorVariable(entity.id, "Alerted", true);        
    end,

    AnalyzeSituation = function (self, entity, sender, data)
        local range = 2.5;
        local distance = AI.GetAttentionTargetDistance(entity.id);
        if(distance > (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", false);
        elseif(distance < (range)) then
            AI.SetBehaviorVariable(entity.id, "IsAttackRange", true);
    end

    end,
})