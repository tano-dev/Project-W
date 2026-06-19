-- File: Client/Managers/ClientDungeonManager.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonNetwork = require(ReplicatedStorage.Shared.Network.DungeonNetwork)

-- Client cũng có thể lấy file Thuật toán này xài ké Server!
local DungeonGenerator = require(ReplicatedStorage.Shared.Utilities.DungeonGenerator)

local UIController = require(game.StarterPlayer.StarterPlayerScripts.Client.Controllers.UIController)
local Store = require(game.StarterPlayer.StarterPlayerScripts.Client.State.ClientStore)

local ClientDungeonManager = {}

function ClientDungeonManager:Start()
    
    -- [BYTENET] NHẬN TÍN HIỆU GAME BẮT ĐẦU TỪ SERVER
    DungeonNetwork.RunStarted.listen(function(payload)
        -- payload.Seed và payload.DungeonId
        
        print("Đang vẽ lại bản đồ từ Server Seed: ", payload.Seed)
        
        -- Client dùng con chip xử lý của mình để tính toán bản đồ (Tránh lag Server)
        local localMapData = DungeonGenerator:GenerateMap(payload.DungeonId, payload.Seed)
        
        -- Lưu biểu đồ hoàn chỉnh vào State của Client để vẽ Minimap
        Store.dispatch("SetDungeonMap", localMapData)
        
        UIController:ShowScreen("MinimapScreen")
    end)

    -- [BYTENET] NHẬN TÍN HIỆU ĐÃ VÀO PHÒNG
    DungeonNetwork.RoomTransition.listen(function(roomType)
        UIController:HideScreen("MinimapScreen")

        if roomType == "Combat" or roomType == "Boss" or roomType == "Elite" then
            UIController:ShowScreen("CombatHUD")
        elseif roomType == "Shop" then
            UIController:ShowScreen("ShopUI")
        elseif roomType == "Treasure" then
            UIController:ShowScreen("ExplorationHUD")
        end
        
        -- VFXSystem:PlayScreenFade()
    end)
end

-- HÀM GỌI TỪ NÚT BẤM TRÊN MINIMAP UI
function ClientDungeonManager:RequestMoveToNode(nodeId: string)
    -- [BYTENET] Gửi mệnh lệnh lên Server
    DungeonNetwork.RequestEnterRoom.send(nodeId)
end

return ClientDungeonManager