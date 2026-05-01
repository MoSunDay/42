local TrialOfAwakening = {}

TrialOfAwakening.id = "trial_of_awakening"
TrialOfAwakening.name = "觉醒者试炼"
TrialOfAwakening.description = "古老的新手试炼场，觉醒者证明自己力量的第一站"
TrialOfAwakening.isDungeon = true
TrialOfAwakening.level = {min = 1, max = 3}

TrialOfAwakening.width = 2400
TrialOfAwakening.height = 2400
TrialOfAwakening.tileSize = 64
TrialOfAwakening.season = "summer"
TrialOfAwakening.backgroundColor = {0.4, 0.35, 0.3}

TrialOfAwakening.areas = {
    {
        id = "entrance_hall",
        name = "入口大厅",
        index = 1,
        x = 400,
        y = 400,
        width = 600,
        height = 500,
        backgroundColor = {0.5, 0.45, 0.4},
        spawnPoint = {x = 500, y = 450},
        exitPoint = {x = 850, y = 500},
        enemies = {
            {type = "slime", x = 650, y = 550, weakened = true, hpMultiplier = 0.7},
            {type = "slime", x = 700, y = 600, weakened = true, hpMultiplier = 0.7}
        },
        npcs = {
            {
                id = "elder_adrian",
                type = "quest_giver",
                x = 520,
                y = 400
            }
        },
        tutorial = {
            triggerOnEnter = true,
            tutorialId = "basic_combat",
            canSkip = true
        },
        rewards = {
            firstClear = {
                {tier = 1, count = 10}
            }
        },
        dialogue = {
            onEnter = {
                speaker = "村长·艾德里安",
                text = "欢迎来到试炼场，觉醒者。击败这些史莱姆，证明你的力量！"
            }
        }
    },
    {
        id = "mist_corridor",
        name = "迷雾回廊",
        index = 2,
        x = 1000,
        y = 400,
        width = 700,
        height = 500,
        backgroundColor = {0.35, 0.4, 0.45},
        spawnPoint = {x = 1050, y = 500},
        exitPoint = {x = 1600, y = 500},
        enemies = {
            {type = "bat", x = 1200, y = 500},
            {type = "bat", x = 1300, y = 550},
            {type = "bat", x = 1250, y = 620},
            {type = "skeleton", x = 1450, y = 550}
        },
        objects = {
            {
                type = "chest",
                x = 1350,
                y = 700,
                contents = {
                    {itemType = "potion", name = "小治疗药剂", healAmount = 30, count = 2}
                }
            },
            {
                type = "note",
                x = 1100,
                y = 600,
                text = "当生命值低于一半时，记得使用防御来减少伤害！"
            }
        },
        tutorial = {
            triggerOnLowHP = 0.5,
            tutorialId = "defense_mechanic",
            canSkip = true
        },
        rewards = {
            firstClear = {
                {tier = 1, count = 10}
            }
        },
        dialogue = {
            onEnter = {
                speaker = "系统",
                text = "迷雾中传来蝙蝠的尖啸声...小心行事！"
            },
            onDiscoverNote = {
                speaker = "古老笔记",
                text = "当生命值低于一半时，记得使用防御来减少伤害！"
            }
        }
    },
    {
        id = "spirit_crystal_chamber",
        name = "灵晶之室",
        index = 3,
        x = 1700,
        y = 400,
        width = 600,
        height = 600,
        backgroundColor = {0.3, 0.35, 0.5},
        spawnPoint = {x = 1750, y = 500},
        exitPoint = {x = 2000, y = 800},
        enemies = {
            {type = "goblin", x = 1900, y = 550},
            {type = "goblin", x = 1950, y = 650}
        },
        npcs = {
            {
                id = "spirit_guide_lina",
                type = "tutorial",
                x = 1800,
                y = 450
            }
        },
        objects = {
            {
                type = "crystal_altar",
                x = 1950,
                y = 500,
                description = "灵晶祭坛 - 力量的源泉"
            }
        },
        tutorial = {
            triggerOnEnter = true,
            tutorialId = "spirit_crystal_system",
            canSkip = true
        },
        rewards = {
            firstClear = {
                {tier = 1, count = 20},
                {tier = 2, count = 2}
            },
            guaranteedDrop = {
                {tier = 1, count = 5}
            }
        },
        dialogue = {
            onEnter = {
                speaker = "灵晶向导·琳娜",
                text = "欢迎来到灵晶之室！让我为你介绍灵晶的奥秘..."
            }
        }
    },
    {
        id = "shadow_passage",
        name = "暗影密道",
        index = 4,
        x = 1700,
        y = 1000,
        width = 600,
        height = 700,
        backgroundColor = {0.2, 0.18, 0.25},
        spawnPoint = {x = 2000, y = 1050},
        exitPoint = {x = 1950, y = 1550},
        waves = {
            {
                enemies = {
                    {type = "wolf", x = 1850, y = 1150},
                    {type = "wolf", x = 1900, y = 1200}
                }
            },
            {
                enemies = {
                    {type = "skeleton", x = 1850, y = 1350},
                    {type = "skeleton", x = 1900, y = 1400}
                }
            }
        },
        objects = {
            {
                type = "chest",
                x = 1800,
                y = 1500,
                contents = {
                    {itemType = "potion", name = "中治疗药剂", healAmount = 60, count = 1}
                }
            }
        },
        tutorial = {
            triggerOnWaveComplete = true,
            tutorialId = "multi_enemy_strategy",
            canSkip = true
        },
        rewards = {
            firstClear = {
                {tier = 1, count = 15},
                {tier = 2, count = 1}
            }
        },
        dialogue = {
            onEnter = {
                speaker = "系统",
                text = "前方传来低沉的呼吸声...准备迎接连续的战斗！"
            },
            onWaveStart = {
                [1] = {speaker = "系统", text = "第一波敌人出现了！"},
                [2] = {speaker = "系统", text = "第二波敌人逼近！坚持下去！"}
            }
        }
    },
    {
        id = "trial_sanctuary",
        name = "试炼圣殿",
        index = 5,
        x = 1000,
        y = 1200,
        width = 700,
        height = 700,
        backgroundColor = {0.25, 0.2, 0.35},
        spawnPoint = {x = 1900, y = 1550},
        boss = {
            id = "trial_guardian",
            type = "boss",
            x = 1350,
            y = 1500
        },
        objects = {
            {
                type = "throne",
                x = 1350,
                y = 1400,
                description = "试炼守护者的王座"
            }
        },
        rewards = {
            firstClear = {
                {tier = 2, count = 2},
                {tier = 3, count = 1}
            }
        },
        dialogue = {
            onEnter = {
                speaker = "试炼守护者",
                text = "...你来到了最终试炼。让我看看你的力量是否名副其实..."
            },
            onBossDefeat = {
                speaker = "试炼守护者",
                text = "...你通过了试炼，觉醒者。这只是开始...更大的威胁正在逼近...带上这些灵晶，变强吧..."
            }
        },
        onClear = {
            showCredits = false,
            unlockMaps = {"generated_01_woods"},
            teleportToMap = "newbie_village",
            teleportPosition = {x = 400, y = 400}
        }
    }
}

TrialOfAwakening.transitions = {
    {fromArea = 1, toArea = 2, fromX = 850, fromY = 500, toX = 1050, toY = 500},
    {fromArea = 2, toArea = 3, fromX = 1600, fromY = 500, toX = 1750, toY = 500},
    {fromArea = 3, toArea = 4, fromX = 2000, fromY = 800, toX = 2000, toY = 1050},
    {fromArea = 4, toArea = 5, fromX = 1950, fromY = 1550, toX = 1900, toY = 1550}
}

TrialOfAwakening.startArea = 1
TrialOfAwakening.startPosition = {x = 500, y = 450}

function TrialOfAwakening.getArea(index)
    return TrialOfAwakening.areas[index]
end

function TrialOfAwakening.getAreaCount()
    return #TrialOfAwakening.areas
end

function TrialOfAwakening.getTransition(fromIndex, direction)
    for _, transition in ipairs(TrialOfAwakening.transitions) do
        if transition.fromArea == fromIndex then
            return transition
        end
    end
    return nil
end

function TrialOfAwakening.getFirstClearReward(areaIndex)
    local area = TrialOfAwakening.areas[areaIndex]
    if area and area.rewards and area.rewards.firstClear then
        return area.rewards.firstClear
    end
    return nil
end

function TrialOfAwakening.getGuaranteedDrop(areaIndex)
    local area = TrialOfAwakening.areas[areaIndex]
    if area and area.rewards and area.rewards.guaranteedDrop then
        return area.rewards.guaranteedDrop
    end
    return nil
end

return TrialOfAwakening
