--
-- Author: gf
-- Date: 2015-09-26 09:42:04
--

NewerBO = {}

local storge_file = "newerState"



function NewerBO.init()
    NewerMO.currentStateId = NewerBO.getState()
    
    if UserMO.level_ > 2 then
        NewerBO.asynDoneGuide()
    end
end

function NewerBO.getNewerFile()
    return storge_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
end

function NewerBO.getState()
    --读取本地文件
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. NewerBO.getNewerFile()
    local localState = 0
    if io.exists(path) then
        localState = io.readfile(path)
    end
    return tonumber(localState)
end



--完成引导
function NewerBO.asynDoneGuide(doneCallback)
    --判断条件
    -- gdump(WorldMO.pos_.x,"xxxxxxxxxxxxxxxxxxx")
    -- gdump(WorldMO.pos_.y,"yyyyyyyyyyyyyyyyyyy")
    if WorldMO.pos_.x < 0 or WorldMO.pos_.y < 0 then
        local function parseResult(name, data)
            gdump(data, "[WorldBO] done guide")

            WorldMO.updatePos(data.pos)
            WorldMO.currentPos_ = cc.p(WorldMO.pos_.x, WorldMO.pos_.y)
            
            if doneCallback then doneCallback() end
        end

        SocketWrapper.wrapSend(parseResult, NetRequest.new("DoneGuide"))
    end 
end

--领取新手礼包
function NewerBO.asynGetGuideGift(doneCallback)
    local function parseResult(name, data)
       --加入背包
        if table.isexist(data, "award") then
            local awards = PbProtocol.decodeArray(data["award"])
            --加入背包
            local ret = CombatBO.addAwards(awards)
            UiUtil.showAwards(ret)

            --TK统计
            for index=1,#awards do
                local award = awards[index]
                if award.type == ITEM_KIND_RESOURCE then
                    TKGameBO.onGetResTk(award.id,award.count,TKText[36],TKGAME_USERES_TYPE_CONSUME)
                elseif award.type == ITEM_KIND_COIN then
                    TKGameBO.onReward(award.count, TKText[36])
                end
            end
        end

        -- 更新引导领取礼包状态
        UserMO.newerGift_ = data.newerGift
        
        UserMO.newState = 1
        NewerBO.saveGuideState(nil,110)
        NewerBO.showNewerGuide()
        if doneCallback then doneCallback() end
    end

    SocketWrapper.wrapSend(parseResult, NetRequest.new("GetGuideGift"))
end

--保存引导阶段
function NewerBO.saveGuideState(doneCallback,stateId)
    --TK统计 引导完成
    TKGameBO.onCompleted(TKText[39] .. stateId)

    local path = CCFileUtils:sharedFileUtils():getCachePath() .. NewerBO.getNewerFile()
    io.writefile(path, stateId, "w+b")

    if doneCallback then doneCallback() end
end


function NewerBO.getGuideStateById(stateId)
    for index=1,#NewerMO.guideData do
    	local newerData = NewerMO.guideData[index]
    	if newerData.pre == stateId then
    		return newerData
    	end
    end
    return nil
end

--触发引导
function NewerBO.showNewerGuide()
    -- gprint("NewerBO.showNewerGuide()")
    if NewerMO.requestInNewer == true then
        if NewerMO.needSaveState > 0 then
            NewerBO.saveGuideState(nil,NewerMO.needSaveState)
            NewerMO.needSaveState = 0
        end
        NewerMO.requestInNewer = false
        Notify.notify(LOCAL_SHOW_NEWER_GUIDE_EVENT)
    end
end

function NewerBO.doCombat(combatId)
    CombatMO.curChoseBattleType_ = COMBAT_TYPE_COMBAT
    local function doneDoCombat(result, atkFormat, defFormat, combatData)
        Loading.getInstance():unshow()
        if CombatMO.curSkipBattle_ then -- 省流量不看战斗
            local BattleBalanceView = require("app.view.BattleBalanceView")
            BattleBalanceView.new():push()
        else
            BattleMO.reset()
            BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
            BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
            BattleMO.setFightData(CombatMO.curBattleFightData_)

            require("app.view.BattleView").new():push()
        end
    end

    local formation = TankBO.getMaxFightFormation(nil, false)
    if not TankBO.hasFightFormation(formation) then
        -- 阵型为空，请设置阵型
        Toast.show(CommonText[193])
        return
    end

    Loading.getInstance():show()
    CombatBO.asynDoCombat(doneDoCombat, CombatMO.curChoseBattleType_, combatId, formation)
end

function NewerBO.doGuideCommond(process)
    local commond = process.commond
    if commond == "playBattle" then
        -- gdump("播放演示战斗")
        NewerBO.initDemoBattle()
        require("app.view.BattleView").new():push()
    elseif commond == "clickCombat" then --选中关卡
        NewerBO.doCombat(process.commondParam)
        --触发引导
        -- NewerBO.showNewerGuide()
    elseif commond == "doCombat" then --选中关卡
        local CombatFightDialog = UiDirector.getUiByName("CombatFightDialog")
        CombatFightDialog:onChallengeCallback()
        NewerBO.showNewerGuide()
    elseif commond == "maxFight" then --最大战力
        local maxBtn = UiDirector.getUiByName("ArmyView").armySettingView.maxBtn
        local fun = maxBtn:getTagCallback()
        fun(nil,maxBtn)
        NewerBO.showNewerGuide()
    elseif commond == "clickHead" then --点击角色头像
        require("app.view.PlayerView").new():push():ShowBlackShade()
        NewerBO.showNewerGuide()
    elseif commond == "upTongShuai" then --升级统率
        local function doneUpCommand(success)
            if success then
                ManagerSound.playSound("command_up")
                Toast.show(CommonText[374][1])  -- 统帅提升成功
            else
                Toast.show(CommonText[374][1]) -- 统帅提升失败
            end
            Loading.getInstance():unshow()
            Notify.notify(LOCAL_PROSPEROUS_EVENT)
        end
        Loading.getInstance():show()
        UserBO.asynUpCommand(doneUpCommand, false)
    elseif commond == "upSkillTab" then
        local PlayerView = UiDirector.getUiByName("PlayerView")
        PlayerView.m_pageView:setPageIndex(PLAYER_VIEW_SKILL)
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "upSkill" then
        local PlayerView = UiDirector.getUiByName("PlayerView")
        PlayerView:onChosenSkill({skillId = 1})
    elseif commond == "openCombat" then --点击关卡
        require("app.view.CombatSectionView").new():push()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "openCombat1" then --点击新手试练地
        local CombatLevelView = require("app.view.CombatLevelView")
        CombatLevelView.new(COMBAT_TYPE_COMBAT, 101):push()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "openBuildEquip" then --打开装备工厂
        require("app.view.EquipView").new(UI_ENTER_FADE_IN_GATE):push():ShowBlackShade()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "equipAll" then --一键装备
        local EquipView = UiDirector.getUiByName("EquipView")
        EquipView:doAllEquip(EquipView.m_chosenPosition)
    elseif commond == "openBuildChariotA" then --打开第一战车工厂
        require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_A):push():ShowBlackShade()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "clickTankProduct" then --坦克生产标签页
        local ChariotInfoView = UiDirector.getUiByName("ChariotInfoView")
        ChariotInfoView.m_pageView:setPageIndex(CHARIOT_FOR_PRODUCT)
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "clickTank" then --点击轻型坦克
        local ChariotInfoView = UiDirector.getUiByName("ChariotInfoView")
        local container = ChariotInfoView.m_pageView:getContainerByIndex(2)
        container.showStatus = 2 -- 显示具体的某个用于生产的tank
        container.productTankId = 1
        ChariotInfoView:showProduct(container)
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "productTank" then
        local ChariotInfoView = UiDirector.getUiByName("ChariotInfoView")
        Loading.getInstance():show()
        TankBO.asynProduct(function()
                Loading.getInstance():unshow()
                ManagerSound.playSound("tank_create")
                if ChariotInfoView.m_pageView then
                    ChariotInfoView.m_pageView:setPageIndex(3)
                end
            end,
            ChariotInfoView.m_build.buildingId, 1, 100)

    elseif commond == "speedTank" then
        local ChariotInfoView = UiDirector.getUiByName("ChariotInfoView")
        local container = ChariotInfoView.m_pageView:getContainerByIndex(3)
        local schedulerId = FactoryBO.orderProduct(BUILD_ID_CHARIOT_A)[1]
        require("app.dialog.UpgradeAccelDialog").new(ITEM_KIND_TANK, 1, {buildingId = BUILD_ID_CHARIOT_A, schedulerId = schedulerId}):push()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "speedTankConfirm" then
        local UpgradeAccelDialog = UiDirector.getUiByName("UpgradeAccelDialog")
        UpgradeAccelDialog:onAccelCallback()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "openBuildIron" then
        local BuildingQueueView = require("app.view.BuildingQueueView")
        local config = HomeBuildWildConfig[1]
        local viewFor = 0
        if config.tag == 0 then
            viewFor = BUILDING_FOR_WILD_COMMON
        elseif config.tag == 1 then
            viewFor = BUILDING_FOR_WILD_STONE
        elseif config.tag == 2 then
            viewFor = BUILDING_FOR_WILD_SILICON
        end
        BuildingQueueView.new(viewFor, 1):push():ShowBlackShade()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "buildIron" then
        -- local BuildingQueueView = UiDirector.getUiByName("BuildingQueueView")
        local function doneBuildUpgrade() -- 城外的建造建筑
            Loading.getInstance():unshow()
            ManagerSound.playSound("build_create")
            UiDirector.pop()
            --触发引导
            NewerBO.showNewerGuide()
        end

        Loading.getInstance():show()
        BuildBO.asynBuildUpgrade(doneBuildUpgrade, BUILD_ID_IRON, 0, 2, 1)

    elseif commond == "openBuildCommand" then
        require("app.view.CommandInfoView").new():push():ShowBlackShade()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "openTaskView" then
        require("app.view.TaskView").new():push():ShowBlackShade()
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "finishTask" then
        Loading.getInstance():show()
        TaskBO.asynTaskAward(function()
            Loading.getInstance():unshow()
            ManagerSound.playSound("task_done")
            --触发引导
            NewerBO.showNewerGuide()
        end,TASK_TYPE_MAJOR,1001,TASK_GET_AWARD_TYPE_NOMAL)
    elseif commond == "openGuideGift" then --打开新手礼包
        require("app.dialog.NewerGiftDialog").new():push()
    elseif commond == "toWildMap" then --前往野外
        UiDirector.clear()
        Notify.notify(LOCAL_SHOW_WILD_EVENT)
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "toWorldMap" then --前往世界地图
        UiDirector.clear()
        Notify.notify(LOCAL_LOCATION_EVENT)
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "toBaseMap" then --前往基地
        UiDirector.popMakeUiTop("HomeView")
        local homeView = UiDirector.getUiByName("HomeView")
        if homeView then homeView:showChosenIndex(MAIN_SHOW_BASE) end
        --触发引导
        NewerBO.showNewerGuide()
    elseif commond == "openbuildScienceCommand" then -- 进入科技馆 建造
        require("app.view.ScienceView").new(BUILD_ID_SCIENCE, SCIENCE_FOR_BUILD):push()
        NewerBO.showNewerGuide()
    elseif commond == "upScienceBuildCommand" then -- 建造科技馆 建筑
        local view = UiDirector.getUiByName("ScienceView")
        if view then
            view:doCommand("build")
        end
        NewerBO.showNewerGuide()
    elseif commond == "openUpScienceCommand" then -- 进入科技馆 技能
        local view = require("app.view.ScienceView").new(BUILD_ID_SCIENCE, SCIENCE_FOR_STUDY):push()
        NewerBO.showNewerGuide()
    elseif commond == "upScienceSkill" then
        local function doUpScience(data)
            Loading.getInstance():unshow()
        end
        Loading.getInstance():show()
        ScienceBO.asynUpgrade(doUpScience, 100) -- 升级维护小队
        NewerBO.showNewerGuide()
    elseif commond == "doLotteryCommand" then
        require("app.view.LotteryTreasureView").new(nil, true):push()
        NewerBO.showNewerGuide()
    elseif commond == "openCombatAwardBoxCommand" then -- 打开关卡奖励箱
        local combatview = UiDirector.getUiByName("CombatLevelView")
        if combatview then
            combatview:onOpenBoxCallback(nil , {index = 1})
        end
        NewerBO.showNewerGuide()
    elseif commond == "closeCombatAwardBoxCommand" then -- 关闭奖励箱
        local combatview = UiDirector.getUiByName("SectionAwardDialog")
        if combatview then

            UiDirector.popName(nil,"SectionAwardDialog")
        end
        NewerBO.showNewerGuide()
    elseif commond == "doLotteryKillCommand" then
        local lotteryview = UiDirector.getUiByName("LotteryTreasureView")
        if lotteryview then
            lotteryview:onNewerInterface(process.commondParam)
        end
        NewerBO.showNewerGuide()
    elseif commond == "donext" then
        NewerBO.showNewerGuide()
    end
end

function NewerBO.doInitCommond(commond,cb,param)
    if commond == "openCombatLevelView" then
        local view = UiDirector.getUiByName("CombatLevelView")
        if not view then
            local CombatLevelView = require("app.view.CombatLevelView")
            CombatLevelView.new(COMBAT_TYPE_COMBAT, 101):push()
        end
    elseif commond == "returnToBase" then
        UiDirector.popMakeUiTop("HomeView")
        if param then
            local HomeView = UiDirector.getUiByName("HomeView")
            HomeView.m_mainUIs[HomeView.m_curShowIndex]:setContentOffset(cc.p(param,0))
            -- print("homeview X:",HomeView.m_mainUIs[HomeView.m_curShowIndex]:getContentOffset().x)
        end
    elseif commond == "openPlayerView" then
        require("app.view.PlayerView").new():push()
    elseif commond == "openLotteryView" then
        local lotteryview = UiDirector.getUiByName("LotteryTreasureView")
        if not lotteryview then
            require("app.view.LotteryTreasureView").new(nil, true):push()
        end
    elseif commond == "enterScienceStudyView" then
        local scienceview = UiDirector.getUiByName("ScienceView")
        if not scienceview then 
             require("app.view.ScienceView").new(BUILD_ID_SCIENCE, SCIENCE_FOR_STUDY):push()
        end
    elseif commond == "openCG" then
        local size = cc.size(display.width, display.height)
        UiDirector.push(require("app.view.NewerCGGuideView").new(size))
        return
    end
    if cb then cb() end
end



function NewerBO.doState(process)
    if process.time then
        local time = process.time / 1000
        scheduler.performWithDelayGlobal(function()
            NewerBO.doNext(process)
            end, time)
    else
        NewerBO.doNext(process)
    end
    
end

function NewerBO.doNext(process)
    if process.isRequest then
        NewerMO.requestInNewer = true
    else
        --如果此步有特殊步骤则执行
        if process.commond then
            NewerMO.requestInNewer = true
            NewerBO.doGuideCommond(process)
        else
            gprint("LOCAL_SHOW_NEWER_GUIDE_EVENT")
            Notify.notify(LOCAL_SHOW_NEWER_GUIDE_EVENT)
        end
    end
end


function NewerBO:getCurrentNewerData()
    local newerData = NewerBO.getGuideStateById(NewerMO.currentStateId)

    if newerData and #newerData.process > 0 then
        return newerData
    else
        NewerMO.currentStateId = NewerBO.getState()
        local newerData = NewerBO.getGuideStateById(NewerMO.currentStateId)
        if newerData and #newerData.process > 0 then
            return newerData
        end
    end 
    return nil
end

function NewerBO.initDemoBattle()
    CombatMO.curBattleNeedShowBalance_ = false
    CombatMO.curBattleCombatUpdate_ = 0
    CombatMO.curBattleAward_ = nil
    CombatMO.curBattleStatistics_ = {}

    CombatMO.curChoseBattleType_ = COMBAT_TYPE_GUIDE
    CombatMO.curChoseBtttleId_ = 0
    CombatMO.curBattleStar_ = 3
    -- 获得战斗的数据
    local combatData = CombatBO.codeGuideRecord()

    -- 设置先手
    CombatMO.curBattleOffensive_ = combatData.offsensive

    CombatMO.curBattleAtkFormat_ = combatData.atkFormat
    CombatMO.curBattleDefFormat_ = combatData.defFormat
    CombatMO.curBattleFightData_ = combatData

    BattleMO.reset()
    BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
    BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
    BattleMO.setFightData(CombatMO.curBattleFightData_)
    local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)
end


---触发引导
local newerState_combat = "newerState_combat"

function NewerBO.getCombatNewerState()
    --读取本地文件
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. newerState_combat
    local data = nil
    if io.exists(path) then
        data = json.decode(io.readfile(path)) 
    end
    return data
end

function NewerBO.combatNewerIsDone(combatId)
    local data = NewerBO.getCombatNewerState()
    if not data then return false end
    for index=1,#data do
        if data[index] == combatId then
            return true
        end
    end
    return false
end

--保存引导阶段
function NewerBO.saveCombatState(doneCallback,combatId)
    local data = NewerBO.getCombatNewerState()
    if not data then data = {} end
    data[#data + 1] = combatId
    local json = json.encode(data)

    local path = CCFileUtils:sharedFileUtils():getCachePath() .. newerState_combat
    io.writefile(path, json, "w+b")

    if doneCallback then doneCallback() end
end


function NewerBO.getLevelUpToast(level)
    local msgList = {}
    local msg

    local lordData = UserMO.queryLordByLevel(level)
    local lordDataPre = UserMO.queryLordByLevel(level - 1)

    msg = {iconSrc = "image/item/t_hero.jpg", content = string.format(CommonText[904][1],lordData.tankCount-lordDataPre.tankCount)}
    msgList[#msgList + 1] = msg

    msg = {iconSrc = "image/item/buff_hit_add.jpg", content = CommonText[904][2]}
    msgList[#msgList + 1] = msg

    local rankData = UserMO.queryRankByLevel(level)
    if rankData then
        msg = {iconSrc = "image/item/rank_17.jpg", content = string.format(CommonText[904][3],rankData.name)}
        msgList[#msgList + 1] = msg
    end

    if BUILD_OPEN_LV[level] then
        local build = BuildMO.queryBuildById(BUILD_OPEN_LV[level])
        msg = {iconSrc = "image/item/t_up.jpg", content = string.format(CommonText[904][4],build.name)}
        msgList[#msgList + 1] = msg
    end
    return msgList
end