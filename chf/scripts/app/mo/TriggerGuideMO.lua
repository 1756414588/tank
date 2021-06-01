--
-- Author: gf
-- Date: 2016-01-15 13:44:42
--

TriggerGuideMO = {}

TriggerGuideMO.showNewer = true

TriggerGuideMO.requestInNewer = false

TriggerGuideMO.currentStateId = 0

TriggerGuideMO.guideArrowX = 0
TriggerGuideMO.guideArrowY = 0


--强制引导
TriggerGuideMO.guideData = {}

--用来记录TD统计引导流程
TriggerGuideMO.tdBeginStateId = 0

TriggerGuideMO.needSaveState = 0

--引导数据
--info 说明框对象  text 内容 xy为坐标，posType为坐标类型
--arrow 指示箭头
--isRequest 本步骤是否是需要请求的步骤 如果是，则需要请求返回才会触发
--save 本步骤是否保存
--commond本步骤是否有特殊操作
--init 本步骤是否有初始化的方法调用 比如本步骤开始之前需要打开某个界面等等
--time 延迟 单位毫秒
--isSwallow 可点击穿透
TriggerGuideMO.guideConfig = {
	
    --世界引导
    {
        id = 10,
        process={
            {
                info = {
                        text = CommonText.triggerGuide[1],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },

            {
            	info = {
                        text = CommonText.triggerGuide[2],
                        x = 0,
                        y = -200,
                        posType = 1
                },
                arrow = {
                	noClick = true,
                    x = 0,
                    y = 50,
                    posType = 1,
                    width = 70,
                    height = 70
                }
            },

            {
            	init = "posToWild",
            	info = {
                        text = CommonText.triggerGuide[3],
                        x = 0,
                        y = -200,
                        posType = 1
                },
                arrow = {
                	noClick = true,
                    x = 0,
                    y = 50,
                    posType = 1,
                    width = 70,
                    height = 70
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[4],
                        x = 0,
                        y = 0,
                        posType = 1
                },
                commond = "returnBase",
                save = true
            }
           
        }
       
    },
    {
        id = 15,
        process={
            {
                commond = "gotoSave",
                isSwallow = true,
                arrow = {
                    x = display.cx,
                    y = 83,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            },
            {
                commond = "gotoSave",
                isSwallow = true,
                save = true,
                arrow = {
                    x = display.cx + 200,
                    y = 83,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            }
        }
    },
    {
        id = 20,
        process={
            {
                init = "returnToBase",
                initParam = -300,
                commond = "openBuildArena",
                arrow = {
                    x = 724,
                    y = 637,
                    posType = 3,
                    buildId = BUILD_ID_ARENA,
                    width = 70,
                    height = 70
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[5],
                        x = 0,
                        y = 0,
                        posType = 1
                },
                commond = "maxFight",
                arrow = {
                    x = 320,
                    y = 90,
                    posType = 2,
                    width = 180,
                    height = 100
                }
            },
            {
                commond = "saveFormation",
                arrow = {
                    x = -120,
                    y = 90,
                    posType = 2,
                    width = 180,
                    height = 100
                }
            },
            {
                init = "switchArenaView",
                info = {
                        text = CommonText.triggerGuide[6],
                        x = 0,
                        y = 0,
                        posType = 1
                }
                
            }
        }
    },

    {
        id = 30,
        process={
            {
                init = "returnToBase",
                initParam = -500,
                commond = "openBuildComponent",
                arrow = {
                    x = 724,
                    y = 637,
                    posType = 3,
                    buildId = BUILD_ID_COMPONENT,
                    width = 70,
                    height = 70
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[7],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },
            {
                commond = "gotoExplore",
                arrow = {
                    x = 115,
                    y = 90,
                    posType = 2,
                    width = 180,
                    height = 100
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[8],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            }
        }
    },

    {
        id = 40,
        process={
            {
                init = "returnToBase",
                initParam = -500,
                commond = "openBuildSchool",
                arrow = {
                    x = 724,
                    y = 637,
                    posType = 3,
                    buildId = BUILD_ID_SCHOOL,
                    width = 70,
                    height = 70
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[9],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },
            {
                commond = "lotteryHero",
                arrow = {
                    x = 240,
                    y = 90,
                    posType = 2,
                    width = 180,
                    height = 100
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[10],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            }
        }
    },
    {
        id = 50,
        process={
            {
                init = "returnToBase",
                initParam = -500,
                commond = "openBuildEquip",
                arrow = {
                    x = 724,
                    y = 637,
                    posType = 3,
                    buildId = BUILD_ID_EQUIP,
                    width = 70,
                    height = 70
                }
            },
            {
                commond = "openBuildEquip1",
                arrow = {
                    x = display.cx - 10,
                    y = display.height - 252,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[11],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },
            {
                commond = "energySpar",
                arrow = {
                    x = 168,
                    y = display.height -  287,
                    posType = 2,
                    width = 180,
                    height = 100
                }
            } 
        }
    },
    {
        id = 60,
        process={
            {
                init = "returnToBase",
                initParam = -500,
                commond = "openBuildComponent",
                arrow = {
                    x = 724,
                    y = 637,
                    posType = 3,
                    buildId = BUILD_ID_COMPONENT,
                    width = 70,
                    height = 70
                }
            },
            {
                commond = "openBuildComponent1",
                arrow = {
                    x = 334,
                    y = 500,
                    pos = {{112,display.height-290},{251,display.height-220},{390,display.height-220},{530,display.height-290},{112,display.height-494},{251,display.height-566},{390,display.height-566},{530,display.height-494}},
                    posType = 10,
                    width = 70,
                    height = 70
                },
                info = {
                        text = CommonText.triggerGuide[12],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },
            {
               commond = "gotoStrength",
                arrow = {
                    x = 320,
                    y = display.cy - 300,
                    posType = 2,
                    width = 180,
                    height = 100
                }
            },
            {
                info = {
                        text = CommonText.triggerGuide[12],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            }
        }
    },
    {
        id = 70,
        process= {
            {
                init = "returnToBase",
                commond = "gotoWarWeapon",
                arrow = {
                    x = display.width - 130,
                    y = 200 * GAME_X_SCALE_FACTOR + 80,
                    posType = 2,
                    width = 55,
                    height = 55
                },
                info = {
                        text = CommonText.triggerGuide[13],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },
            {
                commond = "gotoSave",
                arrow = {
                    x = display.cx,
                    y = display.height - 100 - 100 - 262, -- 262 背景高度
                    posType = 2,
                    width = 55,
                    height = 55
                },
                save = true,
                isSwallow = true
            }
        }
    },
    {
        id = 80,
        process= {
            {
                init = "returnToBase",
                commond = "gotoPlayerView",
                arrow = {
                    x = 45,
                    y = display.height - 42,
                    posType = 2,
                    width = 55,
                    height = 55
                },
                info = {
                        text = CommonText.triggerGuide[14],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },
            {
                commond = "gotoSave",
                arrow = {
                    x = display.cx + 84,
                    y = display.height - 180 + 34 + 23, 
                    posType = 2,
                    width = 55,
                    height = 45
                },
                save = true,
                isSwallow = true
            }
        }
    },
    {
        id = 90,
        process = {
            {
                init = "returnToBase",
                commond = "gotoSave",
                initParam = -760,
                info = {
                    text = CommonText.triggerGuide[15],
                    x = 0,
                    y = -100,
                    posType = 1
                },
                arrow = {
                    x = 195,
                    y = 60, 
                    posType = 1,
                    width = 55,
                    height = 45
                },
                save = true
            }
        }
    },
    { -- 作战实验室
        id = 92,        -- 人员分配
        process = {
            {
                commond = "gotoSave",
                info = {
                        text = CommonText.triggerGuide[16],
                        x = 0,
                        y = 0,
                        posType = 1
                },
                isSwallow = false
            },
            {
                commond = "gotoSave",
                info = {
                        text = CommonText.triggerGuide[17],
                        x = 0,
                        y = 0,
                        posType = 1
                },
                isSwallow = false
            },
            {
                commond = "gotoSave",
                arrow = {
                    x = display.cx - 320 + 114,
                    y = 95,
                    posType = 2,
                    width = 55,
                    height = 55
                },
                info = {
                        text = CommonText.triggerGuide[18],
                        x = 0,
                        y = 0,
                        posType = 1
                },
                isSwallow = false
            },
            {
                init = "switchLaboratoryOpenPerson",
                arrow = {
                    x = 208,
                    y = 138,
                    posType = 1,
                    width = 55,
                    height = 55
                },
                info = {
                        text = CommonText.triggerGuide[19],
                        x = 0,
                        y = 0,
                        posType = 1
                }
            },
            {
                commond = "gotoSave",
                info = {
                        text = CommonText.triggerGuide[20],
                        x = 0,
                        y = 0,
                        posType = 1
                },
                isSwallow = true,
                save = true
            }
        }
    },
    {
        id = 94,
        process = {
            {
                arrow = {
                    x = 228,
                    y = 290,
                    posType = 1,
                    width = 55,
                    height = 55
                },
                isSwallow = true
            },
            {
                commond = "gotoSave",
                arrow = {
                    x = display.cx + 200 ,
                    y = 95,
                    posType = 2,
                    width = 55,
                    height = 55
                },
                isSwallow = false
            },
            {
                init = "switchLaboratoryOpenConstruction",
                commond = "gotoSave",
                arrow = {
                    x = -56 ,
                    y = 147,
                    posType = 1,
                    width = 55,
                    height = 55
                },
                isSwallow = true,
                save = true
            }
        }
    },
    {
        id = 96,
        process = {
            {
                arrow = {
                    x = 228,
                    y = 290,
                    posType = 1,
                    width = 55,
                    height = 55
                },
                isSwallow = true
            },
            {
                commond = "gotoSave",
                arrow = {
                    x = display.cx + 200 ,
                    y = 95,
                    posType = 2,
                    width = 55,
                    height = 55
                },
                isSwallow = false
            },
            {
                init = "switchLaboratoryOpenConstruction",
                commond = "gotoSave",
                arrow = {
                    x = 66 ,
                    y = 147,
                    posType = 1,
                    width = 55,
                    height = 55
                },
                isSwallow = true,
                save = true
            }
        }
    },
    {
        id = 98,
        process = {
            {
                arrow = {
                    x = 228,
                    y = 290,
                    posType = 1,
                    width = 55,
                    height = 55
                },
                isSwallow = true
            },
            {
                commond = "gotoSave",
                arrow = {
                    x = display.cx + 200 ,
                    y = 95,
                    posType = 2,
                    width = 55,
                    height = 55
                },
                isSwallow = false
            },
            {
                init = "switchLaboratoryOpenConstruction",
                commond = "gotoSave",
                arrow = {
                    x = 201 ,
                    y = 147,
                    posType = 1,
                    width = 55,
                    height = 55
                },
                isSwallow = true,
                save = true
            }
        }
    },
    --战术中心
    {
        id = 100,
        process={
            {
                init = "returnToBase",
                initParam = -520,
                commond = "openBuildTactics",
                arrow = {
                    x = 0,
                    y = 0,
                    posType = 3,
                    buildId = BUILD_ID_TACTICCENTER,
                    width = 70,
                    height = 70
                }
            },
        }
    },
    --能源核心
    {
        id = 110,
        process={
            {
                init = "returnToBase",
                initParam = -710,
                commond = "openBuildEngergyCore",
                arrow = {
                    x = 724,
                    y = 637,
                    posType = 3,
                    buildId = BUILD_ID_ENERGYCORE,
                    width = 70,
                    height = 70
                }
            },
        }
    }
}

function TriggerGuideMO.init()
    TriggerGuideMO.showNewer = true

    TriggerGuideMO.requestInNewer = false

    TriggerGuideMO.currentStateId = 0

    TriggerGuideMO.guideArrowX = 0
    TriggerGuideMO.guideArrowY = 0

    TriggerGuideMO.guideData = {}
    TriggerGuideMO.guideData = clone(TriggerGuideMO.guideConfig)
end
