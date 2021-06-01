--
-- Author: gf
-- Date: 2015-11-27 18:13:03
--

TaskGuideMO = {}

TaskGuideMO.guideArrowX = display.cx
TaskGuideMO.guideArrowY = display.cy

--空闲状态指引
TaskGuideMO.showFreeGuideStatus = false

function TaskGuideMO.getGuideStateById(kind,type)
    for index=1,#TaskGuideMO.taskGoConfig do
    	local data = TaskGuideMO.taskGoConfig[index]
    	if data.kind == kind and data.type == type then
    		return data
    	end
    end
    return nil
end


TaskGuideMO.taskGoConfig = {
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_IRON,
        info = {
                text = CommonText.taskGuide[1],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_OIL,
        info = {
                text = CommonText.taskGuide[2],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_COPPER,
        info = {
                text = CommonText.taskGuide[3],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_STONE,
        info = {
                text = CommonText.taskGuide[4],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_SILICON,
        info = {
                text = CommonText.taskGuide[5],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_CHARIOT_B,
        arrow = {
                    x = -145,
                    y = -820,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_WAREHOUSE_A,
        arrow = {
                    x = -145,
                    y = -820,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_WAREHOUSE_B,
        arrow = {
                    x = -145,
                    y = -820,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_REFIT,
        arrow = {
                    x = -145,
                    y = -820,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_SCIENCE,
        arrow = {
                    x = -145,
                    y = -820,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD,
        type = BUILD_ID_WORKSHOP,
        arrow = {
                    x = -145,
                    y = -820,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },    
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_IRON,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_OIL,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_COPPER,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_STONE,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_SILICON,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_COMMAND,
        arrow = {
                    x = -145,
                    y = -870,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_CHARIOT_A,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_CHARIOT_B,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_REFIT,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_SCIENCE,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_WAREHOUSE_A,
        arrow = {
                    x = -145,
                    y = -825,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_WAREHOUSE_B,
        arrow = {
                    x = -145,
                    y = -825,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP,
        type = BUILD_ID_WORKSHOP,
        arrow = {
                    x = -145,
                    y = -875,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_TANK,
        type = 1,
        info = {
                text = CommonText.taskGuide[6],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_COMBAT,
        type = 1,
        info = {
                text = CommonText.taskGuide[7],
                x = 0,
                y = 0,
                posType = 1
        }
    },

    {
        kind = TASK_SCHEDULE_KIND_COMBAT_NO,
        type = 1,
        info = {
                text = CommonText.taskGuide[8],
                x = 0,
                y = 0,
                posType = 1
        }
    },

    {
        kind = TASK_SCHEDULE_KIND_FAME,
        type = 1,
        info = {
                text = CommonText.taskGuide[9],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_RANK,
        type = 1,
        arrow = {
                    x = -95,
                    y = -440,
                    posType = 2,
                    width = 75,
                    height = 65
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_ATTACK_MAN,
        type = 1,
        info = {
                text = CommonText.taskGuide[10],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_ATTACK_MINE,
        type = 1,
        info = {
                text = CommonText.taskGuide[11],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_ATTACK_MINE_LEVEL,
        type = 1,
        info = {
                text = CommonText.taskGuide[12],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_RES,
        type = RESOURCE_ID_IRON,
        info = {
                text = CommonText.taskGuide[13],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_RES,
        type = RESOURCE_ID_OIL,
        info = {
                text = CommonText.taskGuide[14],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_RES,
        type = RESOURCE_ID_COPPER,
        info = {
                text = CommonText.taskGuide[15],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_BUILD_UP_ALL,
        type = 1,
        info = {
                text = CommonText.taskGuide[16],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_EQUIP_UP,
        type = 1,
        info = {
                text = CommonText.taskGuide[17],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_COIN_COST,
        type = 1,
        info = {
                text = CommonText.taskGuide[18],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_SCIENCE_UP,
        type = 1,
        info = {
                text = CommonText.taskGuide[19],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_JJC,
        type = 1,
        info = {
                text = CommonText.taskGuide[20],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_EXPLORE,
        type = EXPLORE_TYPE_EQUIP,
        info = {
                text = CommonText.taskGuide[21],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_EXPLORE,
        type = EXPLORE_TYPE_PART,
        info = {
                text = CommonText.taskGuide[22],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_EXPLORE,
        type = EXPLORE_TYPE_EXTREME,
        info = {
                text = CommonText.taskGuide[23],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_PARTY_COMBAT,
        type = 1,
        info = {
                text = CommonText.taskGuide[24],
                x = 0,
                y = 200,
                posType = 1
        },
        arrow = {
                    x = 354,
                    y = 446,
                    buildId = PARTY_BUILD_ID_TAOC,
                    posType = 6,
                    width = 120,
                    height = 120
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_PARTY_SHOP,
        type = 1,
        info = {
                text = CommonText.taskGuide[25],
                x = 0,
                y = 200,
                posType = 1
        },
        arrow = {
                    x = 354,
                    y = 446,
                    buildId = PARTY_BUILD_ID_SHOP,
                    posType = 6,
                    width = 120,
                    height = 120
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_PARTY_DONOR,
        type = 1,
        info = {
                text = CommonText.taskGuide[26],
                x = 0,
                y = 0,
                posType = 1
        },
        arrow = {
                    x = 354,
                    y = 446,
                    buildId = PARTY_BUILD_ID_HALL,
                    posType = 6,
                    width = 120,
                    height = 120
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_PARTY_COMBAT_AWARD,
        type = 1,
        info = {
                text = CommonText.taskGuide[27],
                x = 0,
                y = 200,
                posType = 1
        },
        arrow = {
                    x = 354,
                    y = 446,
                    buildId = PARTY_BUILD_ID_TAOC,
                    posType = 6,
                    width = 120,
                    height = 120
                }
    },
    {
        kind = TASK_SCHEDULE_KIND_STATION,
        type = 1,
        info = {
                text = CommonText.taskGuide[28],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = TASK_SCHEDULE_KIND_PART_UP,
        type = 1,
        info = {
                text = CommonText.taskGuide[29],
                x = 0,
                y = 0,
                posType = 1
        }
    },
    {
        kind = 500,
        type = 1,
        arrow = {
                    x = 320,
                    y = 90,
                    posType = 2,
                    width = 220,
                    height = 100
                }
    },
    {
        kind = 600,
        type = 1,
        info = {
                    text = CommonText.taskGuide[30],
                    x = 0,
                    y = 0,
                    posType = 1
                },
        arrow = {
                    x = -257,
                    y = 45,
                    posType = 2,
                    width = 70,
                    height = 70
                }
    }
}