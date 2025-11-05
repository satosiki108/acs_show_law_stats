local Mod = GameMain:GetMod("JKL.ShowLawStatsV2");

local needMarkup = true 

function findPropertyPanel(wnd)
    if not wnd.GetChildren then 
        return 
    end

    local children = wnd:GetChildren()

    for i=1,children.Length do 
        local child = children[i-1]
        if child and child.name == "PropertyPanel" then 
            return child 
        end

        local foundPanel = findPropertyPanel(child)
        if foundPanel then 
            return foundPanel
        end
    end

    return nil
end

function Mod:OnRender(dt)
    local charUIExists = CS.Wnd_NpcGentrate.Instance ~= nil and 
    CS.Wnd_NpcGentrate.Instance.isShowing and
    Mod.CharUI
    
    if charUIExists and needMarkup then 
        needMarkup = false 

        local npcPanel = findPropertyPanel(GRoot.inst)        
        Mod.CharUI:MarkUp(npcPanel)
    end
end
