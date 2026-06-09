-- File: Shared/Components/UpgradeTemplate.luau

-- ==========================================
-- 1. ĐIỀU KIỆN THAY ĐỔI TỈ LỆ (CONDITIONS)
-- Dùng để làm hệ thống ép đồ thông minh. Thay vì tỉ lệ chết (fix rate), 
-- tỉ lệ sẽ tăng/giảm tùy thuộc vào tình trạng hiện tại của món vũ khí.
-- ==========================================
export type UpgradeCondition = {
    Type: string,           -- [Sửa nhẹ từ StatName thành Type để bao quát hơn] 
                            -- Các loại: "Purity", "Corruption", "Rarity", "OnLessUpgradeAttempts", "NotUpgraded"...
                            
    RatePerPoint: number?,  -- Mức độ thay đổi tỉ lệ trên mỗi điểm của chỉ số. 
                            -- VD: 0.05 (Tăng 5% cho mỗi 1 điểm Purity) hoặc -0.1 (Giảm 10% cho mỗi 1 điểm Rarity).
                            
    MaxCap: number?,        -- Giới hạn tối đa/tối thiểu của mức thay đổi này để tránh việc tỉ lệ lên quá 100% hoặc xuống âm.
                            -- VD: 0.3 (Chỉ cho phép tăng tối đa 30% dù Purity có cao đến mấy).
                            
    TargetValue: number?,   -- [Bổ sung] Dành cho các điều kiện so sánh. VD: OnLessUpgradeAttempts thì TargetValue = 3 (Dưới 3 lần ép).
    BonusRate: number?,     -- [Bổ sung] Lượng tỉ lệ thưởng cứng nếu đạt điều kiện. VD: NotUpgraded thưởng hẳn 0.2 (20%).
}

-- ==========================================
-- 2. VÒNG QUAY CHỈ SỐ (STAT ROLL)
-- Khi kịch bản ép đồ đã được chốt, hệ thống sẽ vào đây để quay xem
-- món đồ được cộng thêm chính xác bao nhiêu điểm sát thương/phòng thủ.
-- ==========================================
export type StatRollEntry = {
    StatName: string,       -- Tên chỉ số sẽ được cộng/trừ. VD: "Damage", "TrueDamage", ...
    
    Min: number,            -- Mức cộng tối thiểu. VD: 5
    Max: number,            -- Mức cộng tối đa. VD: 15 (Hệ thống sẽ random từ 5 đến 15).
    
    LevelScale: {           -- (Tùy chọn) Dành cho việc chỉ số tăng mạnh hơn dựa trên cấp độ của vũ khí hoặc người chơi.
        Min: number, 
        Max: number
    }?, 
    
    Weight: number,         -- Trọng số của dòng chỉ số này. 
                            -- VD: Dòng "Damage" có Weight 100, dòng "CritRate" có Weight 10 -> Cực kỳ khó ra CritRate.
}

-- ==========================================
-- 3. KỊCH BẢN KẾT QUẢ (POOL OUTCOME)
-- Đại diện cho một "tương lai" có thể xảy ra khi đập viên đá này vào vũ khí.
-- ==========================================
export type PoolOutcome = {
    Weight: number,                  -- Tỉ lệ ra kịch bản này so với các kịch bản khác cùng Pool.
                                     -- VD: Kịch bản "Tăng siêu mạnh" Weight=10, kịch bản "Tăng cùi" Weight=90.
    Rolls: number?,                    -- Số lần roll chỉ số trong StatPools. (0 = all, 1 = roll 1 lần, 2 = roll 2 lần, ...)
                                        -- VD: Rolls=2 nghĩa là sẽ roll 2 dòng chỉ số nếu trúng kịch bản này.
    -- [PHẦN THƯỞNG / HÌNH PHẠT VỀ CHỈ SỐ]
    StatPools: {StatRollEntry}?,     -- Nếu kịch bản này trúng, hệ thống sẽ tiếp tục roll các dòng chỉ số trong này để cộng vào đồ.

    -- ==========================================
    -- [THAY ĐỔI TRẠNG THÁI & HIỆU ỨNG CỨNG]
    -- ==========================================
    
    -- ApplyStates: Lưu bùa chú vào vũ khí, tồn tại âm thầm và phát huy tác dụng ở các lần ép sau.
    -- Các giá trị hợp lệ (Ghi chú chính xác theo ITEM_STATES):
    --      "AntiNuke"          : Đỡ 1 đòn vỡ đồ (DestroyItem) ở lần ép xịt tương lai.
    --      "AntiSlotGone"      : Ép xịt ở lần tới sẽ không bị trừ lượt ép (UpgradeCount).
    --      "AntiPurity"        : Chống bị trừ điểm Tinh Khiết (Purity) nếu lần tới ép xịt.
    --      "AntiCorruption"    : Chống bị cộng điểm Tha Hóa (Corruption) nếu lần tới ép xịt.
    --      "AlwaysSuccess"     : Bùa hộ mệnh 100% thành công cho lần đập đồ kế tiếp.
    --      "SayNoWithHolies"   : (State mở rộng hệ thống - Từ chối buff Holy).
    --      "SayNoWithUpgrades" : (State mở rộng hệ thống - Khóa cường hóa).
    --      "RarityAscended"    : Thăng 1 bậc phẩm chất (Rarity) cho món đồ (VD: Rare -> Epic).
    --      "RarityDescended"   : Giáng 1 bậc phẩm chất (Không rớt dưới 1).
    ApplyStates: {string}?,          
    
    -- SpecialEffects: Kích hoạt LỆNH THỰC THI NGAY LẬP TỨC khi kịch bản này xảy ra.
    -- Các giá trị hợp lệ:
    --      "DestroyItem"         : Phá hủy và xóa vĩnh viễn món đồ khỏi túi (Thường để ở FailPool).
    --      "UpRarity"            : Tự động tăng phẩm chất (Rarity) của món đồ lên 1 bậc.
    --      "DownRarity"          : Tự động giảm phẩm chất (Rarity) của món đồ xuống 1 bậc (Không rớt dưới 1).
    --      "ResetUpgrades"       : Tẩy tủy! Trừ toàn bộ chỉ số đã được cộng thêm từ trước đến nay.
    --      "ResetUpgradeSlots"   : Hồi phục toàn bộ số lượt đã ép (Đưa UpgradeCount về 0).
    --      "ResetPurity"         : Đưa điểm Tinh Khiết về 0.
    --      "ResetCorruption"     : Thanh tẩy toàn bộ điểm Tha Hóa (Corruption về 0).
    --      "ResetFailedUpgrades" : Xóa bộ đếm số lần ép xịt trong NBT.
    --      "ClearAllFailedUpgrades" : Tẩy tủy! Trừ toàn bộ các lần ép xịt.
    --      "ClearOneFailedUpgrade" : Tẩy 1 lần ép xịt duy nhất.
    SpecialEffects: {string}?,       

    -- ==========================================
    -- [GIAO DIỆN & PHẢN HỒI CHO NGƯỜI CHƠI]
    -- ==========================================
    Message: string,                 -- Dòng chữ hiện lên màn hình khi kịch bản này xảy ra.
                                     -- VD: "Cây kiếm của bạn đã tỏa sáng rực rỡ!"
    MessageColor: Color3,            -- Màu sắc của dòng thông báo trên để UI hiển thị cho trực quan.
}
-- ==========================================
-- 4. BỘ LUẬT NÂNG CẤP TỔNG (UPGRADE LOGIC)
-- Khối dữ liệu gốc nằm bên trong mỗi viên đá/cuộn giấy nâng cấp (Material).
-- ==========================================
export type UpgradeLogic = {
    AcceptTypes: {string},           -- Quy định loại đồ nào được phép xài viên đá này. 
                                     -- VD: {"Weapon", "Armor"} (Không xài được cho Accessory). Dùng {"All"} nếu xài được hết.
                                     
    UpgradeCountCost: number,        -- Ép viên đá này tốn bao nhiêu slot của món đồ. 
                                     -- Đa số là 1. Đá tẩy tủy hoặc đá xịn có thể là 0.

    -- [TỈ LỆ THÀNH CÔNG]
    BaseSuccessRate: number,         -- Tỉ lệ thành công gốc (Từ 0.0 đến 1.0). VD: 0.6 là 60%.
    Conditions: {UpgradeCondition}?, -- Danh sách các điều kiện làm thay đổi cái tỉ lệ gốc ở trên.

    -- [BẢNG KẾT QUẢ]
    SuccessPool: {PoolOutcome},      -- Nếu thuật toán phán quyết là THÀNH CÔNG, quay random trong mảng này để ra kết quả tốt.
    FailPool: {PoolOutcome}?,        -- Nếu thuật toán phán quyết là THẤT BẠI, quay random trong mảng này để ra kết quả xấu (hoặc vỡ đồ).
}

return {}