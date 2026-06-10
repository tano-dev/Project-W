local EnchantsEffects = {

            -- Hệ thống Combat sẽ gọi hàm này mỗi khi chém trúng quái
        Effects = {
            OnHit = {
                Target = "Enemy", -- Có thể là "Enemy", "Self", hoặc "All", ...
                TargetConditions = {[[conditions for enchants to works? like hasEffect= {Poison,....}]]},
                SelfConditions = {},
                
            },
        },
    }
            
return EnchantsEffects