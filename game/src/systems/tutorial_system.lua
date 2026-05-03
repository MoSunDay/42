local TutorialSystem = {}

local TUTORIALS = {
    basic_combat = {
        id = "basic_combat",
        title = "基础战斗",
        pages = {
            {
                title = "欢迎来到战斗教学",
                content = "在这个世界中，你需要通过战斗来获得灵晶和经验。",
                highlight = nil
            },
            {
                title = "攻击",
                content = "点击「攻击」按钮对敌人造成伤害。\n你的攻击力越高，造成的伤害越大！",
                highlight = "attack_button"
            },
            {
                title = "开始战斗",
                content = "现在，试着击败面前的史莱姆吧！\n点击敌人选中目标，然后点击攻击。",
                highlight = nil
            }
        },
        skipable = true
    },
    
    defense_mechanic = {
        id = "defense_mechanic",
        title = "防御机制",
        pages = {
            {
                title = "防御的重要性",
                content = "当生命值较低时，防御可以大幅减少受到的伤害！",
                highlight = nil
            },
            {
                title = "如何防御",
                content = "点击「防御」按钮进入防御状态。\n防御时，受到的伤害减少25%！",
                highlight = "defend_button"
            },
            {
                title = "最佳时机",
                content = "建议在生命值低于50%时使用防御，\n等待合适时机再进行反击！",
                highlight = nil
            }
        },
        skipable = true
    },
    
    spirit_crystal_system = {
        id = "spirit_crystal_system",
        title = "灵晶系统",
        pages = {
            {
                title = "灵晶的奥秘",
                content = "灵晶是这个世界力量的结晶，\n可以用来强化装备属性。",
                highlight = nil
            },
            {
                title = "灵晶等级",
                content = "灵晶分为四个等级：\n碎片(10点) → 晶体(50点) → 宝石(200点) → 核心(1000点)\n等级越高，价值越大！",
                highlight = nil
            },
            {
                title = "获得灵晶",
                content = "击败敌人有几率获得灵晶！\n更强的敌人会掉落更高等级的灵晶。",
                highlight = nil
            },
            {
                title = "强化装备",
                content = "收集灵晶后，可以强化装备！\n每次强化都会提升装备的基础属性。",
                highlight = nil
            }
        },
        skipable = true
    },
    
    multi_enemy_strategy = {
        id = "multi_enemy_strategy",
        title = "多敌人战斗",
        pages = {
            {
                title = "面对多个敌人",
                content = "在某些区域，你会遇到多波敌人的攻击！\n需要合理安排战斗策略。",
                highlight = nil
            },
            {
                title = "战斗策略",
                content = "1. 优先击败攻击力高的敌人\n2. 适时使用防御恢复状态\n3. 保持生命值在安全范围",
                highlight = nil
            },
            {
                title = "波次战斗",
                content = "完成一波敌人后，可能会有新的一波出现！\n做好准备，迎接挑战！",
                highlight = nil
            }
        },
        skipable = true
    },
    
    boss_battle = {
        id = "boss_battle",
        title = "Boss战",
        pages = {
            {
                title = "Boss遭遇",
                content = "你即将面对试炼守护者！\nBoss比普通敌人强大得多。",
                highlight = nil
            },
            {
                title = "Boss特点",
                content = "Boss拥有更高的生命值和攻击力，\n有时还会使用特殊技能！",
                highlight = nil
            },
            {
                title = "战胜Boss",
                content = "保持耐心，合理使用防御，\n注意自己的生命值，你一定能获胜！",
                highlight = nil
            },
            {
                title = "丰厚奖励",
                content = "击败Boss后会获得丰厚的灵晶奖励！\n准备好迎接挑战了吗？",
                highlight = nil
            }
        },
        skipable = true
    }
}

function TutorialSystem.create()
    return {
        completedTutorials = {},
        currentTutorial = nil,
        currentPage = 1,
        is_active = false,
        highlightElement = nil,
        onCompleteCallback = nil,
        onSkipCallback = nil,
    }
end

function TutorialSystem.start_tutorial(state, tutorialId)
    local tutorial = TUTORIALS[tutorialId]
    if not tutorial then
        return false
    end
    
    if state.completedTutorials[tutorialId] then
        return false
    end
    
    state.currentTutorial = tutorial
    state.currentPage = 1
    state.is_active = true
    state.highlightElement = tutorial.pages[1].highlight
    
    return true
end

function TutorialSystem.next_page(state)
    if not state.is_active or not state.currentTutorial then return end
    
    if state.currentPage < #state.currentTutorial.pages then
        state.currentPage = state.currentPage + 1
        state.highlightElement = state.currentTutorial.pages[state.currentPage].highlight
    else
        TutorialSystem.complete_tutorial(state)
    end
end

function TutorialSystem.prev_page(state)
    if not state.is_active or not state.currentTutorial then return end
    
    if state.currentPage > 1 then
        state.currentPage = state.currentPage - 1
        state.highlightElement = state.currentTutorial.pages[state.currentPage].highlight
    end
end

function TutorialSystem.skip_tutorial(state)
    if not state.currentTutorial then return end
    
    if not state.currentTutorial.skipable then
        return false
    end
    
    state.completedTutorials[state.currentTutorial.id] = true
    state.is_active = false
    
    if state.onSkipCallback then
        state.onSkipCallback(state.currentTutorial.id)
    end
    
    state.currentTutorial = nil
    state.currentPage = 1
    state.highlightElement = nil
    
    return true
end

function TutorialSystem.complete_tutorial(state)
    if not state.currentTutorial then return end
    
    state.completedTutorials[state.currentTutorial.id] = true
    state.is_active = false
    
    if state.onCompleteCallback then
        state.onCompleteCallback(state.currentTutorial.id)
    end
    
    state.currentTutorial = nil
    state.currentPage = 1
    state.highlightElement = nil
end

function TutorialSystem.is_tutorial_active(state)
    return state.is_active
end

function TutorialSystem.get_current_page(state)
    if not state.currentTutorial then return nil end
    return state.currentTutorial.pages[state.currentPage]
end

function TutorialSystem.get_current_highlight(state)
    return state.highlightElement
end

function TutorialSystem.is_first_page(state)
    return state.currentPage == 1
end

function TutorialSystem.is_last_page(state)
    if not state.currentTutorial then return true end
    return state.currentPage == #state.currentTutorial.pages
end

function TutorialSystem.can_skip(state)
    return state.currentTutorial and state.currentTutorial.skipable
end

function TutorialSystem.get_progress(state)
    if not state.currentTutorial then return 0, 0 end
    return state.currentPage, #state.currentTutorial.pages
end

function TutorialSystem.is_completed(state, tutorialId)
    return state.completedTutorials[tutorialId] == true
end

function TutorialSystem.set_on_complete_callback(state, callback)
    state.onCompleteCallback = callback
end

function TutorialSystem.set_on_skip_callback(state, callback)
    state.onSkipCallback = callback
end

function TutorialSystem.get_all_tutorials()
    return TUTORIALS
end

function TutorialSystem.serialize(state)
    return {
        completedTutorials = state.completedTutorials
    }
end

function TutorialSystem.deserialize(state, data)
    if not data then return end
    state.completedTutorials = data.completedTutorials or {}
end

return TutorialSystem
