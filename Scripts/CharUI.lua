local Mod = GameMain:GetMod("JKL.ShowLawStatsV2");

Mod.CharUI = Mod.CharUI or {}
local CharUI = Mod.CharUI

function CharUI:PerkClicked(context)
    local perk = NpcMgr.ExperienceMgr:GetDef(context.data.data)

    local gongName = nil
    if perk then 
        if perk.Gongs and perk.Gongs.Count > 0 then 
            gongName = perk.Gongs[0]
        end
    end

    local gong = nil 
    if gongName then
        gong = PracticeMgr:GetGongDef(gongName)
    end

    if gong then 
        if context.data.selected then 
            self.SelectedGong = gong
        elseif self.SelectedGong == gong then 
            self.SelectedGong = nil 
            self:HideLaw()
        end
    end

    if self.SelectedGong then 
        self:RefreshLaw()
    end
end

function CharUI:RandomizeClicked(context)
	--[[ --We want to still display law info if random clicked -JKL51
    if self.NPCSelector.selectedIndex == 0 then 
        self.SelectedGong = nil 
        self:HideLaw()
    end
	]]--
	--Show new law match on random clicked --JKL51
	self:RefreshLaw()
end

function CharUI:NPCSwitched(context)
	--[[We do not want to hide law info on char change -JKL51
    if self.NPCSelector.selectedIndex ~= 0 then 
        self:HideLaw()
    elseif self.SelectedGong then
        self:RefreshLaw()
    end
	]]--
	
	--show law info for new character -JKL51
	self:RefreshLaw()
end

function CharUI:RefreshLaw()
    --local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(self.SelectedGong, self.NPCManager.npcs[0]) --Want dynamic index -JKL51
	local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(self.SelectedGong, self.NPCManager.npcs[self.NPCSelector.selectedIndex])
    local format = XT("ความเข้ากันได้：{0:P0}"):gsub("{0:P0}","%%.f %%%%")
    self.MatchLabel.text = string.format(format,lawMatch*100)
    self.MatchLabel:SetBoundsChangedFlag()
    self.MatchLabel:EnsureBoundsCorrect()
    self.MatchLabel.x = (149 - self.MatchLabel.width/2)
    self.MatchLabel.visible = true 
	
	--Add law match calculation text to the newly added 5 match labels -JKL51
	local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(PracticeMgr:GetGongDef("Gong_8_Jin"), self.NPCManager.npcs[self.NPCSelector.selectedIndex]) --Edited by JKL51
    self.MatchLabel_B.text = string.format("เหล็ก: %s %%",string.format("%.0f",lawMatch*100))

	local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(PracticeMgr:GetGongDef("Gong_1_Shui"), self.NPCManager.npcs[self.NPCSelector.selectedIndex]) --Edited by JKL51
	self.MatchLabel_C.text = string.format("น้ำ: %s %%",string.format("%.0f",lawMatch*100))

	local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(PracticeMgr:GetGongDef("Gong_9_Mu"), self.NPCManager.npcs[self.NPCSelector.selectedIndex]) --Edited by JKL51
	self.MatchLabel_D.text = string.format("ไม้: %s %%",string.format("%.0f",lawMatch*100))

	local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(PracticeMgr:GetGongDef("Gong_10_Huo"), self.NPCManager.npcs[self.NPCSelector.selectedIndex]) --Edited by JKL51
	self.MatchLabel_E.text = string.format("ไฟ: %s %%",string.format("%.0f",lawMatch*100))
	
	local lawMatch = CS.XiaWorld.NpcPractice.GetFiveBaseEfficiency(PracticeMgr:GetGongDef("Gong_11_Tu"), self.NPCManager.npcs[self.NPCSelector.selectedIndex]) --Edited by JKL51
	self.MatchLabel_F.text = string.format("ดิน: %s %%",string.format("%.0f",lawMatch*100))
	
	--Add law match calculation text to the newly added 5 match labels --JKL51

    local finalStats = {}
    local neededStats = self.SelectedGong:GetFiveBaseNeed()
    for i=1,neededStats.Length do 
        if neededStats[i-1] ~= -1 then 
            finalStats[i] = neededStats[i-1] / 10
        else
            finalStats[i] = 0.1
        end
    end
    finalStats[6] = 0.1

    self.LawStatHex:UpdateData(finalStats)
    self.LawStats.visible = true
	--JKL51
	self.MatchLabel_B.visible = true
	self.MatchLabel_C.visible = true
	self.MatchLabel_D.visible = true
	self.MatchLabel_E.visible = true
	self.MatchLabel_F.visible = true
	--JKL51	
end

function CharUI:HideLaw()
    self.MatchLabel.visible = false
    self.LawStats.visible = false
end

function CharUI:MarkUp(UIInfo) 
    self.NPCManager = CS.Wnd_NpcGentrate.Instance.Mechine

    self.LawStats = UIPackage.CreateObjectFromURL("ui://0xrxw6g7qfkrgb")
    self.LawStats.x = 171
    self.LawStats.y = 156
    self.LawStats.visible = false
    self.LawStats.m_n89.visible = false 
    self.LawStats.m_n91.visible = false
    self.LawStats.m_n92.visible = false
    self.LawStats.m_n93.visible = false
    self.LawStats.m_n94.visible = false
    self.LawStats.m_n95.visible = false
    self.LawStats.m_n96.visible = false
    self.LawStats.m_FiveBase:SetSize(213, 185)
    UIInfo:AddChild(self.LawStats)

    self.LawStatHex = CS.StarofDavid.NewView(CS.UnityEngine.Color(0.439, 0.788, 0.792, 0.667))
    self.LawStatHex.transform.localPosition = CS.UnityEngine.Vector3.zero
    self.LawStatHex.transform.localScale = CS.UnityEngine.Vector3(80, 80, 80)
    
    if self.LawStatWrapper then 
        self.LawStatWrapper.wrapTarget = nil 
        self.LawStatWrapper:Dispose()
    end
    
    self.LawStatWrapper = CS.FairyGUI.GoWrapper(self.LawStatHex.gameObject)
    self.LawStats.m_FiveBase:SetNativeObject(self.LawStatWrapper)

    self.MatchLabel = UIPackage.CreateObjectFromURL("ui://0xrxw6g7gtsug9")
    self.MatchLabel.visible = false
    self.MatchLabel.y = 150
    UIInfo:AddChild(self.MatchLabel)
	
	--Add more match labels for each of the taiyi laws to be displayed at the top -JKL51
	self.MatchLabel_B = UIPackage.CreateObjectFromURL("ui://0xrxw6g7gtsug9")
	self.MatchLabel_B.x = -110 --jkl51
	self.MatchLabel_B.y = 70 --jkl51
    UIInfo:AddChild(self.MatchLabel_B) --JKL51
	self.MatchLabel_B.text = "เหล็ก: ---%"

	
	self.MatchLabel_C = UIPackage.CreateObjectFromURL("ui://0xrxw6g7gtsug9")
	self.MatchLabel_C.x = -10 --jkl51
	self.MatchLabel_C.y = 70 --jkl51
    UIInfo:AddChild(self.MatchLabel_C) --JKL51
	self.MatchLabel_C.text = "น้ำ: ---%"
	
	self.MatchLabel_D = UIPackage.CreateObjectFromURL("ui://0xrxw6g7gtsug9")
	self.MatchLabel_D.x = 85 --jkl51
	self.MatchLabel_D.y = 70 --jkl51
    UIInfo:AddChild(self.MatchLabel_D) --JKL51
	self.MatchLabel_D.text = "ไม้: ---%"
	
	self.MatchLabel_E = UIPackage.CreateObjectFromURL("ui://0xrxw6g7gtsug9")
	self.MatchLabel_E.x = 190 --jkl51
	self.MatchLabel_E.y = 70 --jkl51
    UIInfo:AddChild(self.MatchLabel_E) --JKL51
	self.MatchLabel_E.text = "ไฟ: ---%"
	
	self.MatchLabel_F = UIPackage.CreateObjectFromURL("ui://0xrxw6g7gtsug9")
	self.MatchLabel_F.x = 270 --jkl51
	self.MatchLabel_F.y = 70 --jkl51
    UIInfo:AddChild(self.MatchLabel_F) --JKL51
	self.MatchLabel_F.text = "ดิน: ---%"
	
	--Add more match labels for each of the taiyi laws to be displayed at the top -JKL51

    UIInfo.m_n143.m_n149.onClickItem:Add(
        function(ctx)
            local success, err = pcall(function()
                self:PerkClicked(ctx)
            end)
            if not success then 
                print(err)
            end
        end
    )
    UIInfo.m_n48.onClick:Add(
        function(ctx)
            local success, err = pcall(function()
                self:RandomizeClicked(ctx)
            end)
            if not success then 
                print(err)
            end
        end
    )

    self.NPCSelector = UIInfo.parent.m_n67
    UIInfo.parent.m_n67.onClickItem:Add(
        function(ctx)
            local success, err = pcall(function()
                self:NPCSwitched(ctx)
            end)
            if not success then 
                print(err)
            end
        end
    )
end

