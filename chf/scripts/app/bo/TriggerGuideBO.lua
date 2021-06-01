--
-- Author: gf
-- Date: 2016-01-13 11:53:58
--


TriggerGuideBO = {}

local storge_file = "triggerGuideState"



function TriggerGuideBO.init()
    
end

function TriggerGuideBO.getNewerFile()
    return storge_file .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
end

function TriggerGuideBO.getState()
    --读取本地文件
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. TriggerGuideBO.getNewerFile()
    local data
    if io.exists(path) then
        data = json.decode(io.readfile(path))
    end
    return data
end

function TriggerGuideBO.guideIsDone(stateId)
	local data = TriggerGuideBO.getState()
	if data and #data > 0 then
		for index=1,#data do
			if stateId == data[index] then
				return true
			end
		end
	end
	return false
end


--保存引导阶段
function TriggerGuideBO.saveGuideState(doneCallback,stateId)
	local data = TriggerGuideBO.getState()
	if not data then data = {} end
	data[#data + 1] = stateId

    local path = CCFileUtils:sharedFileUtils():getCachePath() .. TriggerGuideBO.getNewerFile()
    io.writefile(path, json.encode(data), "w+b")

    if doneCallback then doneCallback() end
end


function TriggerGuideBO.getGuideStateById(stateId)
    for index=1,#TriggerGuideMO.guideData do
    	local newerData = TriggerGuideMO.guideData[index]
    	if newerData.id == stateId then
    		return newerData
    	end
    end
    return nil
end

--触发引导
function TriggerGuideBO.showNewerGuide()
    -- gprint("TriggerGuideBO.showNewerGuide()")
    gprint(TriggerGuideMO.needSaveState,"TriggerGuideMO.needSaveState")
    if TriggerGuideMO.requestInNewer == true then
        if TriggerGuideMO.needSaveState > 0 then
            TriggerGuideBO.saveGuideState(nil,TriggerGuideMO.needSaveState)
            TriggerGuideMO.needSaveState = 0
        end
        TriggerGuideMO.requestInNewer = false
        Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
    end
end



function TriggerGuideBO.doGuideCommond(process)
    local commond = process.commond
    if commond == "returnBase" then
        UiDirector.popMakeUiTop("HomeView")
        local homeView = UiDirector.getUiByName("HomeView")
        if homeView then homeView:showChosenIndex(MAIN_SHOW_BASE) end
        
        TriggerGuideBO.showNewerGuide()

        Loading.getInstance():show()
        TriggerGuideBO.asynGetTipFriends(function(mans)
            Loading.getInstance():unshow()
            if not mans or #mans == 0 then return end
            require("app.dialog.FriendsTuijianDialog").new(mans):push()
            end)
    elseif commond == "openBuildArena" then
        local arenaView = require("app.view.ArenaView").new():push()
        arenaView.m_pageView:setPageIndex(2)
        --触发引导
        TriggerGuideBO.showNewerGuide()
        --勋章开启
        -- Notify.notify("MEDAL_OPEN")
    elseif commond == "maxFight" then
        local maxBtn = UiDirector.getUiByName("ArenaView").armySettingView.maxBtn
        local fun = maxBtn:getTagCallback()
        fun(nil,maxBtn)
        --触发引导
        TriggerGuideBO.showNewerGuide()
    elseif commond == "saveFormation" then
        local saveBtn = UiDirector.getUiByName("ArenaView").armySettingView.saveBtn
        local fun = saveBtn:getTagCallback()
        fun(nil,saveBtn)
    elseif commond == "openBuildComponent" then
        require("app.view.ComponentView").new():push()
        TriggerGuideBO.showNewerGuide()
    elseif commond == "gotoExplore" then
        local componentView = UiDirector.getUiByName("ComponentView")
        componentView:onCombatCallback()
        TriggerGuideBO.showNewerGuide()
    elseif commond == "openBuildSchool" then
        require("app.view.NewSchoolView").new(BUILD_ID_SCHOOL):push()
        TriggerGuideBO.showNewerGuide()
    elseif commond == "lotteryHero" then
        local lotteryHeroView = require("app.view.LotteryHeroView").new():push()
        lotteryHeroView.m_pageView:setPageIndex(2)
        TriggerGuideBO.showNewerGuide()
    elseif commond == "openBuildEquip" then
        require("app.view.EquipView").new():push()
        TriggerGuideBO.showNewerGuide()
    elseif commond == "openBuildEquip1" then
        local lotteryHeroView = require("app.view.EnergySparView").new():push()
        TriggerGuideBO.showNewerGuide()
    elseif commond == "energySpar" then
        local lotteryHeroView = require("app.dialog.EnergyInsetDialog").new():push()
        TriggerGuideBO.showNewerGuide()
    elseif commond == "openBuildComponent1" then
        local index = UiDirector.getUiByName("ComponentView"):getCurrGuideID()
        if index == 0 then
            return   
        else
            local ComponentConfig = {
                {text ="", pos = PART_POS_HP},  -- 生命
                {text ="", pos = PART_POS_ATTACK},  -- 攻击
                {text ="", pos = PART_POS_DEFEND},  -- 防护
                {text ="", pos = PART_POS_IMPALE},  -- 穿刺
                {text ="", pos = PART_POS_IMPALE_DEFEND}, -- 穿刺防护
                {text ="", pos = PART_POS_ATTACK_HP}, -- 攻击生命
                {text ="", pos = PART_POS_ATTACK_IMPALE}, -- 攻击穿刺
                {text ="", pos = PART_POS_HP_DEFEND}, -- 生命防护
                }
            local config = ComponentConfig[index]
            local itemView = nil
            if PartBO.hasPartAtPos(1, config.pos) then
                local part = PartBO.getPartAtPos(1, config.pos)
                part_keyId = part.keyId
                require("app.dialog.ComponentDialog").new(part.keyId):push()
                TriggerGuideBO.showNewerGuide()
            end
        end
    elseif commond == "GuidOver" then
        return
    elseif commond == "gotoStrength" then
        local lotteryHeroView = require("app.view.ComponentStrengthView")
        lotteryHeroView.new(COMPONENT_VIEW_FOR_CUILIAN, part_keyId):push()
        TriggerGuideBO.showNewerGuide()
        part_keyId = nil
    elseif commond == "gotoWarWeapon" then
        if UiDirector.getTopUiName() ~= "WarWeaponView" then
            require("app.view.WarWeaponView").new():push()
        end
        TriggerGuideBO.showNewerGuide()
    elseif commond == "gotoPlayerView" then
        require("app.view.PlayerView").new():push()
        TriggerGuideBO.showNewerGuide()
    elseif commond == "gotoSave" then
        TriggerGuideBO.showNewerGuide()
    elseif commond == "openBuildTactics" then --战术中心
        require("app.view.TacticView").new(BUILD_ID_TACTICCENTER):push()
        -- TriggerGuideBO.showNewerGuide()
    elseif commond == "openBuildEngergyCore" then --能源核心
        require("app.view.EnergyCoreView").new(BUILD_ID_ENERGYCORE):push()
        -- TriggerGuideBO.showNewerGuide()
    end
end


function TriggerGuideBO.doInitCommond(commond,cb,param)
    if commond == "posToWild" then
        local resDataPos = TriggerGuideBO.findNeerBy(WorldMO.pos_)
        gdump(resDataPos,"resDataPos===")
        local homeView = UiDirector.getUiByName("HomeView")
        homeView.m_mainUIs[homeView.m_curShowIndex]:onLocate(resDataPos.x,resDataPos.y)
    elseif commond == "returnToBase" then
        UiDirector.popMakeUiTop("HomeView")
        local homeView = UiDirector.getUiByName("HomeView")
        if homeView then 
            homeView:showChosenIndex(MAIN_SHOW_BASE) 
        end
        if param then
            homeView.m_mainUIs[homeView.m_curShowIndex]:setContentOffset(cc.p(param,0))
        end
    elseif commond == "switchArenaView" then
        local arenaView = UiDirector.getUiByName("ArenaView")
        arenaView.m_pageView:setPageIndex(1)
    elseif commond == "switchLaboratoryOpenPerson" then
        local laboratory = UiDirector.getUiByName("LaboratoryView")
        laboratory:TriggerGuideOpenPerson()
    elseif commond == "switchLaboratoryOpenConstruction" then
        local laboratory = UiDirector.getUiByName("LaboratoryView")
        laboratory:TriggerGuideConstruction()
    end
    if cb then cb() end
end



function TriggerGuideBO.doState(process)
    if process.time then
        local time = process.time / 1000
        scheduler.performWithDelayGlobal(function()
            TriggerGuideBO.doNext(process)
            end, time)
    else
        TriggerGuideBO.doNext(process)
    end
    
end

function TriggerGuideBO.doNext(process)
    if process.isRequest then
        TriggerGuideMO.requestInNewer = true
    else
        --如果此步有特殊步骤则执行
        if process.commond then
            TriggerGuideMO.requestInNewer = true
            TriggerGuideBO.doGuideCommond(process)
        else
            gprint("LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT")
            Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
        end
    end
end


function TriggerGuideBO:getCurrentNewerData()
    local newerData = TriggerGuideBO.getGuideStateById(TriggerGuideMO.currentStateId)
    if not TriggerGuideBO.guideIsDone(TriggerGuideMO.currentStateId) and newerData and #newerData.process > 0 then
        return newerData
    end 
    return nil
end



function TriggerGuideBO.findNeerBy(findPos)
	function findRes(findPos,delta)
		local startX = findPos.x - delta
		if startX < 0 then startX = 0 end
		if startX > (WORLD_SIZE_WIDTH - delta) then startX = WORLD_SIZE_WIDTH - delta end

		local endX = startX + delta + delta
		if endX >= WORLD_SIZE_WIDTH then endX = WORLD_SIZE_WIDTH - 1 end

		local startY = findPos.y - delta
		if startY < 0 then startY = 0 end
		if startY > (WORLD_SIZE_HEIGHT - delta) then startY = WORLD_SIZE_HEIGHT - delta end

		local endY = startY + delta + delta
		if endY >= WORLD_SIZE_HEIGHT then endY = WORLD_SIZE_HEIGHT -1 end

		-- gprint('findPos:', findPos.x, findPos.y, "start:", startX, startY, "end:", endX, endY)
		
		-- local res = {}
		-- local players = {}
		for indexX = startX, endX do
			for indexY = startY, endY do
				if indexX ~= WorldMO.pos_.x and indexY ~= WorldMO.pos_.y then  -- 剔除玩家自己
					local tilePos = cc.p(indexX, indexY)
					local mine = WorldBO.getMineAt(tilePos)
					if mine then  -- 是矿
						-- local mine = clone(mine)
						-- mine.pos = WorldMO.encodePosition(indexX, indexY)
						return {x = indexX,y = indexY}
						-- res[mine.type][#res[mine.type] + 1] = mine -- 框
					-- else
					-- 	local mapData = WorldMO.getMapDataAt(tilePos.x, tilePos.y)
					-- 	if mapData and not mapData.free then  -- 是玩家
					-- 		if not players[mapData.lv] then players[mapData.lv] = {} end
					-- 		players[mapData.lv][#players[mapData.lv] + 1] = mapData
					-- 		-- players[#players + 1] = mapData
					-- 	end
					end
				end
			end
		end
		return nil
	end

	local delta = 1
	
	local resData = findRes(findPos,delta)
	while not resData do 
		delta = delta + 1
		resData = findRes(findPos,delta)
	end
	return resData
	
end


function TriggerGuideBO.showLevelUpGuide()
    if UserMO.level_ == 15 then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_ARENA):push()
    elseif UserMO.level_ == 18 then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_COMPONENT):push()
    elseif UserMO.level_ == 24 then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_SCHOOL):push()
    elseif UserMO.level_ == 55 then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_EQUIP):push()
    elseif UserMO.level_ == 75 then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_COMPONENT):push()
    elseif UserMO.level_ == 20 then
        TriggerGuideMO.currentStateId = 80
        Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
    elseif UserMO.level_ == 70 then
         Notify.notify("MEDAL_OPEN")
    elseif UserMO.level_ == 65 then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_LABORATORY):push()
    elseif UserMO.level_ == 45 then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_TACTICCENTER):push()
    elseif UserMO.level_ == UserMO.querySystemId(80) then
        require("app.dialog.FunOpenDialog").new(BUILD_ID_ENERGYCORE):push()
    end

    if UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ == UserMO.querySystemId(48) then
        WarWeaponBO.GetSecretWeaponInfo(function ()
            TriggerGuideMO.currentStateId = 70
            Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
            Notify.notify(LOCAL_HOME_LIMIT_ITEM)
        end)
    end
end




function TriggerGuideBO.asynGetTipFriends(doneCallback)
    local function parseResult(name, data)
        local mans
        if table.isexist(data, "man") then
            mans = PbProtocol.decodeArray(data["man"])
        else
            mans = {}
        end
        if doneCallback then doneCallback(mans) end
    end
    SocketWrapper.wrapSend(parseResult, NetRequest.new("GetTipFriends"))
end


function TriggerGuideBO.asynAddTipFriends(doneCallback,lordIds)
    local function parseResult(name, data)
        SocialityBO.getFriend()
        if doneCallback then doneCallback() end
    end
    SocketWrapper.wrapSend(parseResult, NetRequest.new("AddTipFriends",{lordId = lordIds}))
end