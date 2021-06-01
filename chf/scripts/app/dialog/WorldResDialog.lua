
-- 目标信息弹出框

local Dialog = require("app.dialog.Dialog")
local WorldResDialog = class("WorldResDialog", Dialog)

function WorldResDialog:ctor(x, y, heroData)
	WorldResDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 400)})
	
	gprint("WorldResDialog:ctor ==> x:", x, "y:", y)
	self.m_x = x
	self.m_y = y
	self.heroData = heroData
	UserMO.SynPlugInScoutMineView = self
end

function WorldResDialog:onEnter()
	WorldResDialog.super.onEnter(self)
	PictureValidateBO.getScoutInfo(function ()
	end)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[308])

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 230))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local mine = WorldBO.getMineAt(cc.p(self.m_x, self.m_y))
	self.m_mine = mine

	local sprite = nil
	local hd = nil
	if self.heroData then
		if self.heroData.heroPick == -2 then
			hd = RebelMO.getTeamById(self.heroData.surface)
		else
			local rd = RebelMO.queryHeroById(self.heroData.heroPick)
			hd = HeroMO.queryHero(rd.associate)
		end
		sprite = RebelMO.getImage(self.heroData.heroPick):addTo(infoBg)
	else
		sprite = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, mine.type, {level = mine.lv}):addTo(infoBg)
		local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
		local detailBtn = MenuButton.new(normal, selected, nil, function()
				local DetailTextDialog = require("app.dialog.DetailTextDialog")
				DetailTextDialog.new(DetailText.mineInfo):push()
			end):addTo(infoBg)
		detailBtn:setPosition(infoBg:getContentSize().width - 70, infoBg:height() - 50)
	end
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setScale(0.9)
	sprite:setPosition(105, 80)

	local str = ""
	local lv = 0
	if not self.heroData then
		local resData = UserMO.getResourceData(ITEM_KIND_WORLD_RES, mine.type)
		str = mine.lv .. CommonText[237][4] .. resData.name2
		lv = mine.lv
	else
		if self.heroData.heroPick == -2 then
			sprite:scale(0.6)
			str = hd.name
		else
			str = hd.heroName
		end
		lv = self.heroData.lv
	end
	-- 多少级的什么
	local label = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = infoBg:getContentSize().height - 80, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local level = ui.newTTFLabel({text = "LV." .. lv, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 20, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	level:setAnchorPoint(cc.p(0, 0.5))

	if self.heroData then
		-- 坐标(x, y)
		label = ui.newTTFLabel({text = CommonText[567][4] .. RebelMO.getFight(self.heroData.surface,self.heroData.heroPick), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))
	end

	-- 坐标(x, y)
	local label = ui.newTTFLabel({text = CommonText[305] .. ": " .. "(" .. self.m_x .. " , " .. self.m_y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local mine = WorldMO.getMineAt(self.m_x, self.m_y)
	local qua = 1
	if self.m_mine then
		local has = false
		local armies = ArmyMO.getAllArmies()
		for index = 1, #armies do
			local army = armies[index]
			local armyPos = WorldMO.decodePosition(army.target)
			if armyPos.x == self.m_x and armyPos.y == self.m_y and army.state == ARMY_STATE_COLLECT then
				has = true
				break
			end
		end
		local time = 0
		if mine then 
			time = math.floor((ManagerTimer.getTime() - mine.scoutTime)/60)
			qua = mine.qua 
		end 
		local state = UiUtil.label(CommonText[989][1],nil,COLOR[2]):addTo(infoBg):align(display.LEFT_CENTER, 22, 205)
		state = UiUtil.label("",nil,COLOR[2]):rightTo(state)
		local mb = WorldMO.queryMineQuality(qua,mine and mine.mineLv)
		local t = UiUtil.label(CommonText[20214]..":",nil,COLOR[11]):alignTo(label, -30 ,1)
		if (not mine or time >= mb.scoutTime / 60) and not has then
			state:setString(CommonText[989][3])
			t = UiUtil.label(CommonText[371]):rightTo(t,10)
			t = UiUtil.label(CommonText[158]..":"):alignTo(label, -60, 1)
			t = UiUtil.label(CommonText[371]):rightTo(t,10)
		else
			state:setString(has and CommonText[990] or string.format(CommonText[989][2], time))
			t = UiUtil.label(mb.name,nil,COLOR[mb.icon]):rightTo(t,10)
			local pro = ProgressBar.new(IMAGE_COMMON .. "mine_pro"..qua..".png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "mine_probg.png", bgScale9Size = cc.size(61, 19)})
				:rightTo(t,10)
			local percent = mine and mine.quaExp / mb.upTime or 0
			if qua == 5 then percent = 1 end
			pro:setPercent(percent)
			UiUtil.label(qua == 5 and "Max" or string.format("%d%%", percent*100)):rightTo(pro, 10)
			t = UiUtil.label(CommonText[158]..":"):alignTo(label, -60, 1)
			UiUtil.label(WorldMO.queryMineQuality(qua).yield/10 .."%",nil,COLOR[2]):rightTo(t, 10)
		end
	end

	-- 收藏
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local storeBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onStoreCallback)):addTo(self:getBg())
	storeBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 26)
	storeBtn:setLabel(CommonText[313][4])
	storeBtn:setEnabled(not self.heroData)

	-- 侦查
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local scoutBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onScoutCallback)):addTo(self:getBg())
	scoutBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
	scoutBtn:setLabel(CommonText[313][5])

	-- 攻击
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local atkBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onAttackCallback)):addTo(self:getBg())
	atkBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 26)
	atkBtn:setLabel(CommonText[313][6])

	local status = WorldBO.getPositionStatus(cc.p(self.m_x, self.m_y))
	if status[ARMY_STATE_COLLECT] then
		atkBtn:setEnabled(false)
	else
		local partyMine = WorldMO.getPartyMineAt(self.m_x, self.m_y)
		if partyMine and PartyBO.getMyParty() then
			atkBtn:setEnabled(false)
		end
	end
end

function WorldResDialog:onStoreCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop(function()
			local StoreDialog = require("app.dialog.StoreDialog")
			StoreDialog.new(STORE_TYPE_RESOURCE, self.m_x, self.m_y):push()
		end)
end

function WorldResDialog:onScoutCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Mtime=ManagerTimer.getTime()
	local s=UserMO.prohibitedTime-Mtime
	if s>0 then
		local freeTime=UiUtil.strBuildTime(s, "hms")
		Toast.show("侦察功能冷却中,还有"..freeTime.."恢复")
		self:pop()
	else
		local scout = WorldMO.queryScout(self.heroData and self.heroData.lv or self.m_mine.lv,self.heroData)
		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

		local str = resData.name
		if scout.mulit then
			str = str .."(".. scout.mulit ..CommonText[988] ..")"
		end
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[310], UiUtil.strNumSimplify(scout.scoutCost), str, UserMO.scout_ + 1), function()
			local count = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
			if count < scout.scoutCost then
				Toast.show(resData.name .. CommonText[223])
				UserMO.scoutValidate=true
				return
			end
			--获取是否需要验证
			PictureValidateBO.getScoutInfo(function ()
				gprint("PictureValidateBO.validate==",PictureValidateBO.validate)
				if PictureValidateBO.validate == 1 then
					local PictureValidateDialog=require("app.dialog.PictureValidateDialog")
					--拉取图片信息
					--local isFlush = true
					local k1 = nil
					local k2 = nil
					PictureValidateBO.getValidatePic(true,function ()
						gprint("PictureValidateBO.validateKeyWord1=======",PictureValidateBO.validateKeyWord1)
						gprint("PictureValidateBO.validateKeyWord2=======",PictureValidateBO.validateKeyWord2)
						gdump(PictureValidateBO.validatePic,"得到的图片")
						if PictureValidateBO.validateKeyWord1 >100 then
							k1 = PictureValidateMO.getSpeciesById(PictureValidateBO.validateKeyWord1)
						else
							k1 = PictureValidateMO.getGenusById(PictureValidateBO.validateKeyWord1)
						end

						if PictureValidateBO.validateKeyWord2 >100 then
							k2 = PictureValidateMO.getSpeciesById(PictureValidateBO.validateKeyWord2)
						else
							k2 = PictureValidateMO.getGenusById(PictureValidateBO.validateKeyWord2)
						end
						gprint("k1====",k1)
						gprint("k2====",k2)
						local validate=PictureValidateDialog.new(k1, k2, function()
							Loading.getInstance():show()
							WorldBO.asynScoutPos(handler(self, self.doneCallback), self.m_x, self.m_y)
						end)
						validate:push()
					end)
				else
					self:doSocket()
				end
			end)
		end):push()
	end
end

function WorldResDialog:doSocket()
	Loading.getInstance():show()
	WorldBO.asynScoutPos(handler(self, self.doneCallback), self.m_x, self.m_y)
end

function WorldResDialog:doneCallback(mail)
	Loading.getInstance():unshow()
	if self.m_mine then
		local mine = WorldMO.getMineAt(self.m_x, self.m_y)
		if not mine then
			local data = {
				mineId = 0,
				mineLv = 2,
				pos = WorldMO.encodePosition(self.m_x, self.m_y),
				qua = 1,
				quaExp = 0,
				scoutTime = ManagerTimer.getTime(),
			}
			WorldMO.setMineAt(self.m_x, self.m_y, data)
		end
	end
	self:pop(function()
			require("app.view.ReportScoutView").new(mail):push()
		end)
end

function WorldResDialog:onAttackCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local num = UserMO.getResource(ITEM_KIND_POWER)
	if num < 1 then  -- 能量不足
		require("app.dialog.BuyPawerDialog").new():push()
		local resData = UserMO.getResourceData(ITEM_KIND_POWER)
		Toast.show(resData.name .. CommonText[223])
		return
	end
	
	WorldMO.curAttackPos_ = cc.p(self.m_x, self.m_y)
	
	self:pop(function()
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_FOR_WORLD):push()
		end)
end

function WorldResDialog:onExit()
	WorldResDialog.super.onEnter(self)
	UserMO.SynPlugInScoutMineView = nil
end



return WorldResDialog
