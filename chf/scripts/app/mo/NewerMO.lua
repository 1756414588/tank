--
-- Author: gf
-- Date: 2015-09-26 09:41:56
--

NewerMO = {}

NewerMO.showNewer = true

NewerMO.requestInNewer = false

NewerMO.currentStateId = 0

NewerMO.guideArrowX = 0
NewerMO.guideArrowY = 0

--新手礼包奖励ID
NewerMO.giftAwardId = 38


NewerMO.guideData = {}

--用来记录TD统计引导流程
NewerMO.tdBeginStateId = 0

NewerMO.needSaveState = 0

--等级提升信息提示
BUILD_OPEN_LV = {
    [10] = BUILD_ID_PARTY,
    [15] = BUILD_ID_ARENA,
    [18] = BUILD_ID_COMPONENT,
    [24] = BUILD_ID_SCHOOL,
    [30] = BUILD_ID_MILITARY,
    [45] = BUILD_ID_TACTICCENTER,
    [65] = BUILD_ID_LABORATORY,
    [80] = BUILD_ID_ENERGYCORE
}

-- ADA_WIDTH 用于适配
-- ADA_WIDTH_S 宽度差 当X > 0   +ADA_WIDTH_S  当 x < 0  -ADA_WIDTH_S
-- ADA_WIDTH_C 宽度比 主要用于主界面(homeview)
local ADA_WIDTH_S = display.cx - 320
local ADA_WIDTH_C = display.width / 640


--引导数据
--info 说明框对象  text 内容 xy为坐标，posType为坐标类型
--arrow 指示箭头
--isRequest 本步骤是否是需要请求的步骤 如果是，则需要请求返回才会触发
--save 本步骤是否保存
--commond本步骤是否有特殊操作
--init 本步骤是否有初始化的方法调用 比如本步骤开始之前需要打开某个界面等等
--time 延迟 单位毫秒
NewerMO.guideConfig = {
	-- {
 --        id = 1,
 --        pre = 0,
 --        process={
 --            {
 --                init = "openCombatLevelView",
 --                info = {
 --                        text = "警报！警报！前方遇到敌军主力部队，请求派遣我军精英部队前往支援！",
 --                        x = 0,
 --                        y = 0,
 --                        posType = 1
 --                }
 --            },
 --            {
 --                info = {
 --                        text = "收到！那就让他们见识一下我军新型坦克的威力！新来的指挥官，请一同前往观战！",
 --                        x = 0,
 --                        y = 0,
 --                        posType = 1,
 --                        picType = 2
 --                },
 --                commond = "playBattle",
 --                save = true
 --            }
 --        }
       
 --    },

     --打副本第一关卡
    {
        id = 1,
        pre = 0,
        process={
            {
                init = "openCG",
            }
        }
    },
    -- 进入探宝
    {
        id = 10,
        pre = 5,
        process={
            {
                statid = ST_P_10,
                init = "returnToBase",

                commond = "doLotteryCommand",
                save = true,
                arrow = {
                    x = -40 - ADA_WIDTH_S,
                    y = 278,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            }
        }   
    },
    {
        id = 15,
        pre = 10,
        process={
            {
                -- 击杀第一个
                statid = ST_P_13,
                init = "openLotteryView",
                save = true,
                commond = "doLotteryKillCommand",
                commondParam = 2,
                -- swallow = true,
                -- time = 2000,
                -- delay = 1000,
                arrow = {
                    x = 176 + ADA_WIDTH_S,
                    y = display.height - 486,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            }
        }
    },
    {
        id = 20,
        pre = 15,
        process={
            {
                -- 击杀第二个
                statid = ST_P_15,
                init = "openLotteryView",
                save = true,
                commond = "doLotteryKillCommand",
                commondParam = 3,
                delay = 2500,
                -- swallow = true,
                -- time = 2000,
                arrow = {
                    x = 323 + ADA_WIDTH_S,
                    y = display.height - 483,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            }
        }
    },
    {
        id = 30,
        pre = 20,
        process={
            {
                -- 击杀第三个
                statid = ST_P_17,
                init = "openLotteryView",
                save = true,
                commond = "doLotteryKillCommand",
                commondParam = 4,
                delay = 2500,
                -- swallow = true,
                -- time = 2000,
                arrow = {
                    x = 478 + ADA_WIDTH_S,
                    y = display.height - 592,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            }
        }
    },
    {
        id = 40,
        pre = 30,
        process={
            {
                -- 总结探宝
                statid = ST_P_20,
                init = "openLotteryView",
                commond = "donext",
                delay = 1500,
                info = {
                        text = CommonText.newer[1],
                        x = 0,
                        y = 0,
                        posType = 1
                },
            },
            {
                statid = ST_P_25,
                save = true,
                commond = "donext",
                arrow = {
                    x = 50 + ADA_WIDTH_S,
                    y = display.height - 60,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            }
        }
    },
    {
        id = 50,
        pre = 40,
        process={
            {
                -- 进入第一大关第一小关
                statid = ST_P_30,
                init = "returnToBase",
                commond = "openCombat1",
                arrow = {
                    x = 185 * ADA_WIDTH_C,
                    y = 50,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            },
            {
                -- 点击开始战斗
                statid = ST_P_31,
                info = {
                        text = CommonText.newer[2],
                        x = 0,
                        y = 0,
                        posType = 1,
                        picType = 1
                }
            },
            {
                -- 点击开始战斗
                statid = ST_P_32,
                save = true,
                commond = "clickCombat",
                commondParam = 101,
                arrow = {
                    x = 463,
                    y = 189,
                    posType = 4,
                    combatId = 101,
                    width = 70,
                    height = 70
                },
                action = {
                    x = -20,
                    y = 70,
                    posType = 4,
                    combatId = 101,
                    name = "gongchengshi_papa",
                }
            }
        }
    },
    --去科技观建造 
    {
        id = 60,
        pre = 50,
        process={
            {
                statid = ST_P_37,
                init = "openCombatLevelView",
                info = {
                            text = CommonText.newer[3],
                            x = 0,
                            y = 0,
                            posType = 1,
                            picType = 3
                    },
            },
            {
                statid = ST_P_39,
                save = true,
                commond = "donext",
                arrow = {
                    x = 50 * ADA_WIDTH_C,
                    y = display.height - 60,
                    posType = 2,
                    width = 100,
                    height = 75
                }
            }
        }
    },
    {
        id = 70,
        pre = 60,
        process= {
            {
                statid = ST_P_40,
                init = "returnToBase",
                initParam = -200,
                commond = "openbuildScienceCommand",
                arrow = {
                    x = -8,
                    y = 263,
                    posType = 1 ,
                    width = 100,
                    height = 75
                }
            },
            {
                statid = ST_P_45,
                commond = "upScienceBuildCommand",
                save = true,
                -- time = 2000,
                arrow = {
                    x = -140 - ADA_WIDTH_S,
                    y = display.height - 827 ,
                    posType = 2 ,
                    width = 100,
                    height = 75
                }
            }
        }
    },
    -- 升级科技
    {
        id = 80,
        pre = 70,
        process={
            {
                statid = ST_P_50,
                init = "returnToBase",
                initParam = -200,
                delay = 1000,
                -- time = 1000,
                commond = "openUpScienceCommand",
                arrow = {
                    x = -8,
                    y = 263,
                    posType = 1 ,
                    width = 100,
                    height = 75
                }
            },
            -- {
            --     commond = "donext",
            --     arrow = {
            --         x = 246 + ADA_WIDTH_S,
            --         y = display.height - 125 ,
            --         posType = 2 ,
            --         width = 100,
            --         height = 75
            --     }
            -- },
            {
                statid = ST_P_55,
                save = true,
                commond = "upScienceSkill",
                arrow = {
                    x = -87 - ADA_WIDTH_S,
                    y = display.height - 245 ,
                    posType = 2 ,
                    width = 100,
                    height = 75
                }
            }
        }
    },
    {
        id = 90,
        pre = 80,
        process={
             {
                statid = ST_P_57,
                init = "enterScienceStudyView",
                info = {
                        text = CommonText.newer[4],
                        x = 0,
                        y = 0,
                        posType = 1
                },
            },
            {
                statid = ST_P_59,
                commond = "donext",
                save = true,
                arrow = {
                    x = 51 + ADA_WIDTH_S,
                    y = display.height - 58 ,
                    posType = 2 ,
                    width = 100,
                    height = 75
                }
            }
        }
    },
    {
        id = 100,
        pre = 90,
        process={
            {
                statid = ST_P_60,
                init = "returnToBase",
                commond = "openCombat1",
                arrow = {
                    x = 185 * ADA_WIDTH_C,
                    y = 50,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            },
            {
                statid = ST_P_62,
                commond = "openCombatAwardBoxCommand",
                arrow = {
                    x = 100 + ADA_WIDTH_S + 343,
                    y = 70,
                    posType = 2,
                    width = 70,
                    height = 70
                }
            },
            {
                statid = ST_P_64,
                info = {
                        text = CommonText.newer[5],
                        x = 0,
                        y = 0,
                        posType = 1
                },
            },
            {
                statid = ST_P_66,
                commond = "closeCombatAwardBoxCommand",
                save = true,
                arrow = {
                    x = 234,
                    y = 154,
                    posType = 1,
                    width = 70,
                    height = 70
                }
            }
        }
    },
    -- 完成引导
    {
        id = 110,
        pre = 100,
        process={
            {
                statid = ST_P_68,
                save = true,
                init = "openCombatLevelView",
                commond = "openGuideGift",
                info = {
                    text = CommonText.newer[6],
                    x = 0,
                    y = 0,
                    posType = 1
                }
            }
        }
    }

    -- --打副本第一关卡
    -- {
    --     id = 10,
    --     pre = 0,
    --     process={
    --         {
    --             -- statid = ST_P_6,
    --             init = "returnToBase",
    --             info = {
    --                     text = "进入关卡",--CommonText.newer[1],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 101,
    --             arrow = {
    --                 x = 463,
    --                 y = 189,
    --                 posType = 4,
    --                 combatId = 101,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --     }
       
    -- },
    --打副本第二关卡
    -- {
    --     id = 20,
    --     pre = 10,
    --     process={
    --         {
    --             statid = ST_P_11,
    --             init = "openCombatLevelView",
    --             info = {
    --                     text = CommonText.newer[2],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1

    --             },
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 102,
    --             arrow = {
    --                 x = 142,
    --                 y = 261,
    --                 posType = 4,
    --                 combatId = 102,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --     }
       
    -- },
    -- --升级统率
    -- {
    --     id = 30,
    --     pre = 20,
    --     process={
    --         {
    --             statid = ST_P_16,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[3],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             }
    --         },
    --         --点击角色头像
    --         {
    --             statid = ST_P_18,
    --             info = {
    --                     text = CommonText.newer[4],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "clickHead",
    --             time = 100,
    --             arrow = {
    --                 x = 50 * ADA_WIDTH_C,
    --                 y = -30,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
                
    --         },
    --         --升级统率
    --         {
    --             statid = ST_P_20,
    --             info = {
    --                     text = CommonText.newer[5],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "upTongShuai",
    --             arrow = {
    --                 x = -86 - ADA_WIDTH_S,
    --                 y = -731,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
                
    --         }
    --     }
       
    -- },

    -- --升级技能
    -- {
    --     id = 40,
    --     pre = 30,
    --     process={
    --         {
    --             statid = ST_P_22,
    --             init = "openPlayerView",
    --             info = {
    --                     text = CommonText.newer[6],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "upSkillTab",
    --             arrow = {
    --                 x = 244 + ADA_WIDTH_S,
    --                 y = -126,
    --                 posType = 2,
    --                 width = 160,
    --                 height = 60
    --             }
                
    --         },
    --         -- {
    --         --     commond = "upSkillTab",
    --         --     arrow = {
    --         --         x = 244,
    --         --         y = -126,
    --         --         posType = 2,
    --         --         width = 160,
    --         --         height = 60
    --         --     }
    --         -- },
    --         --升级第一个技能
    --         {
    --             statid = ST_P_24,
    --             info = {
    --                     text = CommonText.newer[7],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "upSkill",
    --             arrow = {
    --                 x = -86 - ADA_WIDTH_S,
    --                 y = -248,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         -- {
    --         --     save = true,
    --         --     commond = "upSkill",
    --         --     arrow = {
    --         --         x = -86,
    --         --         y = -248,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         -- {
    --         --     info = {
    --         --             text = "指挥官，去战斗吧，检验我们提升的战斗力是否货真价实！",
    --         --             x = 0,
    --         --             y = 0,
    --         --             posType = 1
    --         --     }
    --         -- }
    --     }
       
    -- },

    -- --打第三个关卡
    -- {
    --     id = 50,
    --     pre = 40,
    --     process={
    --         -- {
    --         --     init = "returnToBase",
    --         --     info = {
    --         --             text = "让敌人尝尝炮弹的滋味吧！",
    --         --             x = 0,
    --         --             y = 0,
    --         --             posType = 1
    --         --     }
    --         -- },
    --         --点击关卡
    --         {
    --             statid = ST_P_26,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[8],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openCombat1",
    --             arrow = {
    --                 x = 185 * ADA_WIDTH_C,
    --                 y = 50,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         --点击新手试练地
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openCombat1",
    --         --     arrow = {
    --         --         x = 320,
    --         --         y = -470,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击第三个关卡
    --         -- {
    --         --     info = {
    --         --             text = "全军出击！",
    --         --             x = 0,
    --         --             y = 0,
    --         --             posType = 1
    --         --     }
                
    --         -- },
    --         {
    --             statid = ST_P_28,
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 103,
    --             arrow = {
    --                 x = 317,
    --                 y = 367,
    --                 posType = 4,
    --                 combatId = 103,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         --敌军阵形界面
    --         -- {
    --         --     commond = "doCombat",
    --         --     time = 100,
    --         --     arrow = {
    --         --         x = 128,
    --         --         y = -405,
    --         --         posType = 1,
    --         --         width = 220,
    --         --         height = 100
    --         --     }
    --         -- },
    --         -- --最大战力
    --         -- {
    --         --     commond = "maxFight",
    --         --     arrow = {
    --         --         x = 320,
    --         --         y = 90,
    --         --         posType = 2,
    --         --         width = 220,
    --         --         height = 100
    --         --     }
    --         -- },
    --         --出战
    --         -- {
    --         --     save = true,
    --         --     isRequest = true,
    --         --     arrow = {
    --         --         x = -115,
    --         --         y = 90,
    --         --         posType = 2,
    --         --         width = 220,
    --         --         height = 100
    --         --     }
    --         -- }
    --     }
       
    -- },

    -- --打副本第四关卡
    -- {
    --     id = 60,
    --     pre = 50,
    --     process={
    --         {
    --             statid = ST_P_32,
    --             init = "openCombatLevelView",
    --             info = {
    --                     text = CommonText.newer[9],
    --                     x = 0,
    --                     y = -150,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 104,
    --             arrow = {
    --                 x = 431,
    --                 y = 543,
    --                 posType = 4,
    --                 combatId = 104,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         -- {
    --         --     -- time = 100,
    --         --     save = true,
    --         --     commond = "clickCombat",
    --         --     commondParam = 104,
    --         --     arrow = {
    --         --         x = 431,
    --         --         y = 543,
    --         --         posType = 4,
    --         --         combatId = 104,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- }
           
    --     }
       
    -- },
    -- --一键装备
    -- {
    --     id = 70,
    --     pre = 60,
    --     process={
    --         {
    --             statid = ST_P_37,
    --             init = "returnToBase",
    --             initParam = -900,
    --             info = {
    --                     text = CommonText.newer[10],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openBuildEquip",
    --             arrow = {
    --                 x = 724,
    --                 y = 637,
    --                 posType = 3,
    --                 buildId = BUILD_ID_EQUIP,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         --点击装备工厂
    --         -- {
    --         --     info = {
    --         --             text = "获得的新装备，记得来这里使用！",
    --         --             x = 0,
    --         --             y = 200,
    --         --             posType = 1
    --         --     },
                
    --         -- },
    --         -- {
    --         --     commond = "openBuildEquip",
    --         --     arrow = {
    --         --         x = 724,
    --         --         y = 637,
    --         --         posType = 3,
    --         --         buildId = BUILD_ID_EQUIP,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击一键装备
    --         {
    --             statid = ST_P_42,
    --             info = {
    --                     text = CommonText.newer[11],
    --                     x = 0,
    --                     y = -200,
    --                     posType = 1
    --             },
    --             -- isRequest = true,
    --             commond = "equipAll",
    --             save = true,
    --             arrow = {
    --                 x = -130 - ADA_WIDTH_S,
    --                 y = -475,
    --                 posType = 2,
    --                 width = 157,
    --                 height = 75
    --             }
    --         }
    --     }
       
    -- },
    -- --打第五个关卡
    -- {
    --     id = 80,
    --     pre = 70,
    --     process={
    --         {
    --             statid = ST_P_44,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[12],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openCombat1",
    --             arrow = {
    --                 x = 185 * ADA_WIDTH_C,
    --                 y = 50,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         --点击关卡
    --         -- {
    --         --     commond = "openCombat",
    --         --     arrow = {
    --         --         x = 185,
    --         --         y = 50,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击新手试练地
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openCombat1",
    --         --     arrow = {
    --         --         x = 320,
    --         --         y = -470,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击第五个关卡
    --         {
    --             statid = ST_P_46,
    --             info = {
    --                     text = CommonText.newer[13],
    --                     x = 0,
    --                     y = -200,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 105,
    --             arrow = {
    --                 x = 211,
    --                 y = 500,
    --                 posType = 4,
    --                 combatId = 105,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         -- {
    --         --     -- time = 100,
    --         --     save = true,
    --         --     commond = "clickCombat",
    --         --     commondParam = 105,
    --         --     arrow = {
    --         --         x = 211,
    --         --         y = 500,
    --         --         posType = 4,
    --         --         combatId = 105,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- }
           
    --     }
       
    -- },
    -- --打副本第六关卡
    -- {
    --     id = 90,
    --     pre = 80,
    --     process={
    --         {
    --             statid = ST_P_51,
    --             init = "openCombatLevelView",
    --             info = {
    --                     text = CommonText.newer[14],
    --                     x = 0,
    --                     y = -150,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 106,
    --             arrow = {
    --                 x = 431,
    --                 y = 543,
    --                 posType = 4,
    --                 combatId = 106,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         -- {
    --         --     -- time = 100,
    --         --     save = true,
    --         --     commond = "clickCombat",
    --         --     commondParam = 106,
    --         --     arrow = {
    --         --         x = 431,
    --         --         y = 543,
    --         --         posType = 4,
    --         --         combatId = 106,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- }
            
            
    --     }
       
    -- },

    -- --生产坦克
    -- {
    --     id = 100,
    --     pre = 90,
    --     process={
    --         {
    --             statid = ST_P_56,
    --             init = "returnToBase",
    --             initParam = -300,
    --             info = {
    --                     text = CommonText.newer[15],
    --                     x = 0,
    --                     y = -200,
    --                     posType = 1
    --             },
    --             commond = "openBuildChariotA",
    --             arrow = {
    --                 x = 0,
    --                 y = 0,
    --                 posType = 3,
    --                 buildId = BUILD_ID_CHARIOT_A,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         --生产标签
    --         {
    --             statid = ST_P_58,
    --             commond = "clickTankProduct",
    --             arrow = {
    --                 x = 240 + ADA_WIDTH_S,
    --                 y = -125,
    --                 posType = 2,
    --                 width = 150,
    --                 height = 70
    --             }
    --         },

    --         --点击轻型坦克
    --         {
    --             statid = ST_P_59,
    --             commond = "clickTank",
    --             arrow = {
    --                 x = -95 - ADA_WIDTH_S,
    --                 y = -245,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },

    --         --确认生产
    --         {
    --             statid = ST_P_60,
    --             info = {
    --                     text = CommonText.newer[16],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             -- isRequest = true,
    --             save = true,
    --             commond = "productTank",
    --             arrow = {
    --                 x = -150 - ADA_WIDTH_S,
    --                 y = -876,
    --                 posType = 2,
    --                 width = 210,
    --                 height = 90
    --             }
    --         },
    --         -- {
    --         --     isRequest = true,
    --         --     arrow = {
    --         --         x = -150,
    --         --         y = -876,
    --         --         posType = 2,
    --         --         width = 210,
    --         --         height = 90
    --         --     }
    --         -- },
    --         --加速生产队列1
    --         {
    --             statid = ST_P_62,
    --             info = {
    --                     text = CommonText.newer[17],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "speedTank",
    --             arrow = {
    --                 x = -87 - ADA_WIDTH_S,
    --                 y = -232,
    --                 posType = 2,
    --                 width = 90,
    --                 height = 90
    --             }
    --         },
    --         -- {
    --         --     commond = "speedTank",
    --         --     arrow = {
    --         --         x = -87,
    --         --         y = -232,
    --         --         posType = 2,
    --         --         width = 90,
    --         --         height = 90
    --         --     }
    --         -- },
    --         --加速生产队列2
    --         {
    --             statid = ST_P_64,
    --             time = 100,
    --             commond = "speedTankConfirm",
    --             arrow = {
    --                 x = 205,
    --                 y = 275,
    --                 posType = 1,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         --花费金币弹出
    --         {
                
    --             statid = ST_P_65,
    --             isRequest = true,
    --             arrow = {
    --                 x = 133,
    --                 y = -106,
    --                 posType = 1,
    --                 width = 220,
    --                 height = 100
    --             }
    --         }
    --         -- {
    --         --     save = true,
    --         --     isRequest = true,
    --         --     arrow = {
    --         --         x = 133,
    --         --         y = -106,
    --         --         posType = 1,
    --         --         width = 220,
    --         --         height = 100
    --         --     }
    --         -- },
            
    --     }
       
    -- },

    -- --打第七个关卡
    -- {
    --     id = 110,
    --     pre = 100,
    --     process={
    --         {
    --             statid = ST_P_66,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[18],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openCombat1",
    --             arrow = {
    --                 x = 185 * ADA_WIDTH_C,
    --                 y = 50,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         --点击关卡
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openCombat",
    --         --     arrow = {
    --         --         x = 185,
    --         --         y = 50,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击新手试练地
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openCombat1",
    --         --     arrow = {
    --         --         x = 320,
    --         --         y = -470,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击第7个关卡
    --         {
    --             statid = ST_P_68,
    --             info = {
    --                     text = CommonText.newer[19],
    --                     x = 0,
    --                     y = -200,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 107,
    --             arrow = {
    --                 x = 211,
    --                 y = 500,
    --                 posType = 4,
    --                 combatId = 107,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         -- {
    --         --     -- time = 100,
    --         --     save = true,
    --         --     commond = "clickCombat",
    --         --     commondParam = 107,
    --         --     arrow = {
    --         --         x = 211,
    --         --         y = 500,
    --         --         posType = 4,
    --         --         combatId = 107,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- }
            
    --     }
       
    -- },

    -- --打副本第八关卡
    -- {
    --     id = 120,
    --     pre = 110,
    --     process={
    --         {
    --             statid = ST_P_73,
    --             init = "openCombatLevelView",
    --             info = {
    --                     text = CommonText.newer[20],
    --                     x = 0,
    --                     y = -150,
    --                     posType = 1
    --             },
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 108,
    --             arrow = {
    --                 x = 431,
    --                 y = 543,
    --                 posType = 4,
    --                 combatId = 108,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         -- {
    --         --     -- time = 100,
    --         --     save = true,
    --         --     commond = "clickCombat",
    --         --     commondParam = 108,
    --         --     arrow = {
    --         --         x = 431,
    --         --         y = 543,
    --         --         posType = 4,
    --         --         combatId = 108,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
            
    --     }
       
    -- },

    -- --建造资源单位
    -- {
    --     id = 130,
    --     pre = 120,
    --     process={
    --         {
    --             statid = ST_P_78,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[21],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             time = 100,
    --             commond = "toWildMap",
    --             arrow = {
    --                 x = 75 * ADA_WIDTH_C,
    --                 y = 55,
    --                 posType = 2,
    --                 width = 100,
    --                 height = 75
    --             }
    --         },
    --         --点击基地
    --         -- {
    --         --     info = {
    --         --             text = "资源是军队发展的保证",
    --         --             x = 0,
    --         --             y = 0,
    --         --             posType = 1
    --         --     },
    --         --     time = 100,
    --         --     arrow = {
    --         --         x = 75,
    --         --         y = 55,
    --         --         posType = 2,
    --         --         width = 100,
    --         --         height = 75
    --         --     }
    --         -- },
    --         -- {
    --         --     time = 100,
    --         --     arrow = {
    --         --         x = 75,
    --         --         y = 55,
    --         --         posType = 2,
    --         --         width = 100,
    --         --         height = 75
    --         --     }
    --         -- },
    --         --点击空地
    --         {
    --             statid = ST_P_80,
    --             info = {
    --                     text = CommonText.newer[22],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openBuildIron",
    --             arrow = {
    --                 x = 75,
    --                 y = 55,
    --                 posType = 5,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openBuildIron",
    --         --     arrow = {
    --         --         x = 75,
    --         --         y = 55,
    --         --         posType = 5,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         {
    --             statid = ST_P_82,
    --             -- moveCancel = true,
    --             commond = "buildIron",
    --             -- time = 100,
    --             save = true,
    --             arrow = {
    --                 x = -90 - ADA_WIDTH_S,
    --                 y = -190,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         {
    --             statid = ST_P_83,
    --             time = 100,
    --             commond = "toWorldMap",
    --             arrow = {
    --                 x = 75 * ADA_WIDTH_C,
    --                 y = 55,
    --                 posType = 2,
    --                 width = 100,
    --                 height = 75
    --             }
    --         },
    --         {
    --             statid = ST_P_84,
    --             time = 100,
    --             commond = "toBaseMap",
    --             arrow = {
    --                 x = 75 * ADA_WIDTH_C,
    --                 y = 55,
    --                 posType = 2,
    --                 width = 100,
    --                 height = 75
    --             }
    --         }
            
    --     }
       
    -- },

    -- --升级司令部
    -- {
    --     id = 140,
    --     pre = 130,
    --     process={
    --         {
    --             statid = ST_P_85,
    --             init = "returnToBase",
    --             initParam = -600,
    --             info = {
    --                     text = CommonText.newer[23],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openBuildCommand",
    --             arrow = {
    --                 x = 424,
    --                 y = 637,
    --                 posType = 3,
    --                 buildId = BUILD_ID_COMMAND,
    --                 width = 70,
    --                 height = 70
    --             }
                
    --         },
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openBuildCommand",
    --         --     arrow = {
    --         --         x = 724,
    --         --         y = 637,
    --         --         posType = 3,
    --         --         buildId = BUILD_ID_COMMAND,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
                
    --         -- },
    --         {
    --             statid = ST_P_87,
    --             info = {
    --                     text = CommonText.newer[24],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             isRequest = true,
    --             save = true,
    --             arrow = {
    --                 x = -145 - ADA_WIDTH_S,
    --                 y = -870,
    --                 posType = 2,
    --                 width = 220,
    --                 height = 100
    --             }
    --         }
    --         -- {
    --         --     isRequest = true,
    --         --     save = true,
    --         --     arrow = {
    --         --         x = -145,
    --         --         y = -820,
    --         --         posType = 2,
    --         --         width = 220,
    --         --         height = 100
    --         --     }
    --         -- }
    --     }
       
    -- },

    -- --完成任务
    -- {
    --     id = 150,
    --     pre = 140,
    --     process={
    --         {
    --             statid = ST_P_89,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[25],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openTaskView",
    --             arrow = {
    --                 x = -257 * ADA_WIDTH_C,
    --                 y = 45,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openTaskView",
    --         --     arrow = {
    --         --         x = -257,
    --         --         y = 45,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         {
    --             statid = ST_P_91,
    --             info = {
    --                     text = CommonText.newer[26],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "finishTask",
    --             save = true,
    --             arrow = {
    --                 x = -105 - ADA_WIDTH_S,
    --                 y = -250,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --         -- {
    --         --     -- moveCancel = true,
    --         --     -- isRequest = true,
    --         --     commond = "finishTask",
    --         --     save = true,
    --         --     arrow = {
    --         --         x = -105,
    --         --         y = -300,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- }
            
    --     }
       
    -- },

    --  --打第九个关卡
    -- {
    --     id = 160,
    --     pre = 150,
    --     process={
    --         {
    --             statid = ST_P_93,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[27],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openCombat1",
    --             arrow = {
    --                 x = 185 * ADA_WIDTH_C,
    --                 y = 50,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             }
    --         },
    --         --点击关卡
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openCombat",
    --         --     arrow = {
    --         --         x = 185,
    --         --         y = 50,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击新手试练地
    --         -- {
    --         --     -- time = 100,
    --         --     commond = "openCombat1",
    --         --     arrow = {
    --         --         x = 320,
    --         --         y = -470,
    --         --         posType = 2,
    --         --         width = 70,
    --         --         height = 70
    --         --     }
    --         -- },
    --         --点击第九个关卡
    --         {
    --             -- time = 100,
    --             statid = ST_P_95,
    --             save = true,
    --             commond = "clickCombat",
    --             commondParam = 109,
    --             arrow = {
    --                 x = 211,
    --                 y = 500,
    --                 posType = 4,
    --                 combatId = 109,
    --                 width = 70,
    --                 height = 70
    --             }
    --         }
    --     }
       
    -- },

    -- {
    --     id = 170,
    --     pre = 160,
    --     process={
    --         {
    --             statid = ST_P_99,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[28],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             -- save = true
    --             commond = "openGuideGift"
    --         }
            
    --     }
       
    -- },
    -- {
    --     id = 180,
    --     pre = 170,
    --     process={
    --         {
    --             statid = ST_P_101,
    --             init = "returnToBase",
    --             info = {
    --                     text = CommonText.newer[29],
    --                     x = 0,
    --                     y = 0,
    --                     posType = 1
    --             },
    --             commond = "openTaskView",
    --             arrow = {
    --                 x = -257 * ADA_WIDTH_C,
    --                 y = 45,
    --                 posType = 2,
    --                 width = 70,
    --                 height = 70
    --             },
    --             save = true
    --         }
    --     }
       
    -- }

}

function NewerMO.init()
    NewerMO.showNewer = true

    NewerMO.requestInNewer = false

    NewerMO.currentStateId = 0

    NewerMO.guideArrowX = 0
    NewerMO.guideArrowY = 0

    NewerMO.guideActionX = 0
    NewerMO.guideActionY = 0

    NewerMO.guideLockTouch = false

    NewerMO.guideData = {}
    NewerMO.guideData = clone(NewerMO.guideConfig)
end
