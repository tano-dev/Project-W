-- File: ReplicatedStorage/Shared/Network/DungeonNetwork.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNet = require(ReplicatedStorage.Shared.Utilities.ByteNet) -- Đường dẫn trỏ tới thư viện ByteNet của bạn

-- Khởi tạo Namespace để đóng gói các Packets (Tránh trùng lặp ID mạng)
local DungeonNetwork = ByteNet.defineNamespace("Dungeon", function()
    return {
        -- [CLIENT -> SERVER] Yêu cầu bắt đầu chuyến đi
        RequestStartRun = ByteNet.definePacket({
            value = ByteNet.string, -- Gửi DungeonId (VD: "Volcanic")
        }),

        -- [CLIENT -> SERVER] Yêu cầu bước qua phòng mới
        RequestEnterRoom = ByteNet.definePacket({
            value = ByteNet.string, -- Gửi NodeId (VD: "2_1")
        }),

        -- =======================================================

        -- [SERVER -> CLIENT] Thông báo ván mới đã bắt đầu
        -- Gửi bằng Struct (Cấu trúc dữ liệu cực nhẹ)
        RunStarted = ByteNet.definePacket({
            value = ByteNet.struct({
                Seed = ByteNet.float64, -- Dùng float64 vì os.time() là một số rất lớn
                DungeonId = ByteNet.string,
            }),
        }), 

        -- [SERVER -> CLIENT] Báo hiệu chuyển cảnh thành công
        RoomTransition = ByteNet.definePacket({
            value = ByteNet.string, -- Gửi RoomType (VD: "Combat", "Boss", "Treasure")
        }),
    }
end)

return DungeonNetwork