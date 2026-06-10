-- File: Shared/Components/UpgradeTemplate.luau

-- ==========================================
-- 1. ĐIỀU KIỆN THAY ĐỔI TỈ LỆ (CONDITIONS)
-- Dùng để làm hệ thống ép đồ thông minh. Thay vì tỉ lệ chết (fix rate), 
-- tỉ lệ sẽ tăng/giảm tùy thuộc vào tình trạng hiện tại của món vũ khí.
-- ==========================================
export type UpgradeCondition = {
    Type: string,           -- Tên chỉ số/Trạng thái dùng để kiểm tra.
                            -- Các loại hợp lệ: "Purity", "Corruption", "Rarity", 
                            -- "OnLessUpgradeAttempts", "OnMoreUpgradeAttempts", "NotUpgraded"
                            
    RatePerPoint: number?,  -- Mức độ thay đổi tỉ lệ trên mỗi điểm của chỉ số (Dùng cho Type là Purity/Corruption/Rarity).
                            -- VD: 0.05 (Tăng 5% cho mỗi 1 điểm Purity) hoặc -0.1 (Giảm 10% cho mỗi 1 điểm Rarity).
                            
    MaxCap: number?,        -- Giới hạn tối đa/tối thiểu của mức thay đổi này để tránh việc tỉ lệ lệch quá xa.
                            -- VD: 0.3 (Chỉ cho phép tăng tối đa 30% dù chỉ số gốc có cao đến mấy).
                            
    TargetValue: number?,   -- Dành cho các điều kiện so sánh. 
                            -- VD: Nếu Type = "OnLessUpgradeAttempts" thì TargetValue = 3 (Chỉ áp dụng khi đồ đập dưới 3 lần).
    
    BonusRate: number?,     -- Lượng tỉ lệ thưởng/phạt CỨNG nếu đạt điều kiện so sánh. 
                            -- VD: Đạt điều kiện "NotUpgraded" -> Thưởng thẳng 0.2 (20%).
}

-- ==========================================
-- 2. VÒNG QUAY CHỈ SỐ (STAT ROLL)
-- Khối định nghĩa một dòng chỉ số có thể rớt ra khi nâng cấp.
-- ==========================================
export type StatRollEntry = {
    StatName: string,       -- Tên chỉ số sẽ được cộng/trừ. 
                            -- VD: "Damage", "MagicDamage", "CritRate", "Purity", "Corruption".
    
    Min: number,            -- Mức cộng tối thiểu. VD: 5
    Max: number,            -- Mức cộng tối đa. VD: 15 (Hệ thống sẽ random từ 5 đến 15).
    
    LevelScale: {           -- (Tùy chọn) Tính năng scale chỉ số dựa trên cấp độ của vũ khí.
        Min: number, 
        Max: number
    }?, 
    
    Weight: number,         -- Trọng số quay Gacha. 
                            -- [QUAN TRỌNG]: Nếu Weight = 0 -> Chỉ số này BẮT BUỘC rớt (100% trúng) mà không tiêu tốn lượt Roll.
                            -- Nếu Weight > 0 -> Sẽ vào chung một rổ (Pool) để quay xí ngầu cạnh tranh với các dòng khác.
}

-- ==========================================
-- 3. KỊCH BẢN KẾT QUẢ (POOL OUTCOME)
-- Đại diện cho một "tương lai" có thể xảy ra khi đập viên đá này.
-- ==========================================
export type PoolOutcome = {
    Weight: number,                  -- Tỉ lệ ra kịch bản này so với các kịch bản khác trong cùng bảng (SuccessPool/FailPool).
                                     -- VD: Kịch bản "Siêu phẩm" Weight=10, kịch bản "Bình thường" Weight=90.
                                     
    Rolls: number?,                  -- Hệ thống Đa Mục Tiêu (Multi-Roll). Xác định số lượng dòng chỉ số sẽ rớt ra từ StatPools.
                                     -- [QUAN TRỌNG]: 
                                     -- Rolls = 0 hoặc nil: Sẽ nhận TẤT CẢ các dòng trong StatPools.
                                     -- Rolls = N: Sẽ quay N lần. Mỗi lần trúng 1 dòng sẽ loại dòng đó ra khỏi rổ (Không cộng dồn trùng lặp).
    
    -- [PHẦN THƯỞNG / HÌNH PHẠT VỀ CHỈ SỐ LÕI]
    StatPools: {StatRollEntry}?,     -- Kho chứa các dòng chỉ số để hệ thống quay (Dựa trên thông số Rolls ở trên).

    -- ==========================================
    -- [THAY ĐỔI TRẠNG THÁI BỀN VỮNG - STATE]
    -- ==========================================
    -- ApplyStates: Dán bùa chú/nhãn mác vào vũ khí. Tồn tại âm thầm trong mảng `ItemData.State`.
    -- Các giá trị hợp lệ:
    -- Bùa Tiêu Hao (Tự động xóa sau khi phát huy tác dụng):
    --      "NukeProtection"          : Cứu 1 đòn vỡ đồ (DestroyItem). Dùng xong là mất bùa.
    --      "AntiSlotGone"            : Giúp ép xịt lần tới không bị tính lượt (UpgradeCount).
    --      "AntiPurity"              : Đỡ 1 cú trừ điểm Purity (Sẽ chặn roll < 0 của Purity về 0).
    --      "AntiCorruption"          : Đỡ 1 cú cộng điểm Corruption (Sẽ chặn roll > 0 của Corruption về 0).
    --      "AlwaysSuccess"           : Bùa hộ mệnh 100% thành công cho lần đập đồ kế tiếp.
    -- Nhãn Đánh Dấu (Tồn tại vĩnh viễn):
    --      "AntiNuke"                : Món đồ VIP miễn nhiễm vĩnh viễn với việc bị vỡ.
    --      "RarityAscended"          : Mộc chứng nhận: "Đã từng được thăng bậc" (Để khóa không cho thăng 2 lần).
    --      "RarityDescended"         : Mộc chứng nhận: "Đã từng bị rớt bậc".
    --      "SayNoWithHolies"         : Từ chối buff Holy.
    --      "SayNoWithUpgrades"       : Khóa cường hóa (Không cho ép thêm).
    --      "UpgradeExtended"         : Mở rộng slot ép đồ Cấp 1 (MaxUpgrades + 1).
    --      "GreatUpgradeExtended"    : Mở rộng slot ép đồ Cấp 2 (MaxUpgrades + 1, yêu cầu Cấp 1).
    --      "UltimateUpgradeExtended" : Mở rộng slot ép đồ Cấp 3 (MaxUpgrades + 1, yêu cầu Cấp 2).
    ApplyStates: {string}?,          
    
    -- ==========================================
    -- [HIỆU ỨNG TỨC THỜI - SPECIAL EFFECTS]
    -- ==========================================
    -- SpecialEffects: Kích hoạt LỆNH THỰC THI NGAY LẬP TỨC khi kịch bản này xảy ra.
    -- Các giá trị hợp lệ:
    --      "DestroyItem"            : Phá hủy và xóa vĩnh viễn món đồ (Sẽ bị chặn nếu có bùa NukeProtection/AntiNuke).
    --      "UpRarity"               : Tự động thăng phẩm chất (Rarity) lên 1 bậc (Ví dụ: Rare -> Epic).
    --      "DownRarity"             : Tự động giáng phẩm chất xuống 1 bậc (Không tụt dưới Common).
    --      "ResetUpgrades"          : Cuộn giấy Tẩy Tủy! Xóa toàn bộ chỉ số cộng thêm, nhưng giữ lại base stats và Purity/Corruption.
    --      "ResetUpgradeSlots"      : Cuộn giấy Reset Slot! Đưa số lượt ép (UpgradeCount) về lại 0.
    --      "ResetPurity"            : Xóa trắng điểm Tinh Khiết (Đưa về 0).
    --      "ResetCorruption"        : Thanh tẩy điểm Tha Hóa (Đưa về 0).
    --      "ResetFailedUpgrades"    : Reset thẳng biến theo dõi FailedAttempts trong NBT về 0.
    --      "ClearAllFailedUpgrades" : Cuộn giấy Hoàn Hồn! Hoàn trả TOÀN BỘ slot bị mất do ép xịt.
    --      "ClearOneFailedUpgrade"  : Cuộn giấy Trắng (Clean Slate)! Cứu lại 1 slot ép xịt duy nhất.
    SpecialEffects: {string}?,       

    -- ==========================================
    -- [GIAO DIỆN & PHẢN HỒI CHO NGƯỜI CHƠI]
    -- ==========================================
    Message: string,                 -- Dòng chữ hiện lên màn hình để báo cáo kết quả.
                                     -- VD: "Cây kiếm của bạn đã tỏa sáng rực rỡ!" hoặc "Vũ khí đã tan thành tro bụi..."
    MessageColor: Color3,            -- Mã màu (Color3) của dòng thông báo trên để UI in chữ (Xanh lá = tốt, Đỏ = xịt).
}

-- ==========================================
-- 4. BỘ LUẬT NÂNG CẤP TỔNG (UPGRADE LOGIC)
-- Khối dữ liệu gốc nằm bên trong mỗi viên đá/cuộn giấy nâng cấp (Material).
-- ==========================================
export type UpgradeLogic = {
    AcceptTypes: {string},           -- Bộ lọc thông minh: Viên đá này dùng được cho loại đồ nào?
                                     -- VD: {"Weapon"} (Áp dụng cho mọi vũ khí: Sword, Axe, Staff...). 
                                     -- VD: {"Sword", "Katana"} (Chỉ giới hạn 2 loại này). Dùng {"All"} nếu cho phép mọi thứ.
                                     
    UpgradeCountCost: number,        -- Đập viên đá này tốn bao nhiêu slot của món đồ (Thường là 1). Đá tẩy tủy có thể là 0.

    -- [TỈ LỆ THÀNH CÔNG]
    BaseSuccessRate: number,         -- Tỉ lệ thành công gốc (Scale từ 0.0 đến 1.0). VD: 0.6 là 60%.
    Conditions: {UpgradeCondition}?, -- Các Modifier (Bùa chú, Điều kiện) làm tăng/giảm cái tỉ lệ gốc ở trên.

    -- [BẢNG KẾT QUẢ ĐẦU RA]
    SuccessPool: {PoolOutcome},      -- Nếu Đổ xí ngầu = THÀNH CÔNG, quay tiếp bảng này để xem kết quả ngon cỡ nào.
    FailPool: {PoolOutcome}?,        -- Nếu Đổ xí ngầu = THẤT BẠI, quay bảng này để xem hình phạt (Mất trắng, hay Vỡ đồ).
}

return {}