
-- 军事矿区资源弹出框

local Dialog = require("app.dialog.Dialog")
local CrossMineDialog = class("CrossMineDialog", Dialog)

function CrossMineDialog:ctor(x, y)
	CrossMineDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 400)})
	
	gprint("CrossMineDialog:ctor ==> x:", x, "y:", y)
	self.m_x = x
	self.m_y = y
end

function CrossMineDialog:onEnter()
	CrossMineDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[10051])  -- 矿点信息

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 230))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local mine = StaffBO.getCrossMineAt(cc.p(self.m_x, self.m_y))
	self.m_mine = mine

	local sprite = UiUtil.createItemSprite(ITEM_KIND_MILITARY_MINE, mine.type):addTo(infoBg)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	-- sprite:setScale(0.9)
	sprite:setPosition(105, 100)

	local resData = UserMO.getResourceData(ITEM_KIND_MILITARY_MINE, mine.type)
	-- 多少级的什么
	local label = ui.newTTFLabel({text = mine.lv .. CommonText[237][4] .. resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = infoBg:getContentSize().height - 80, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local level = ui.newTTFLabel({text = "LV." .. mine.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 20, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	level:setAnchorPoint(cc.p(0, 0.5))

	-- 坐标(x, y)
	local label = ui.newTTFLabel({text = CommonText[305] .. ": " .. "(" .. self.m_x .. " , " .. self.m_y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local mapData = StaffMO.getCrossMapDataAt(self.m_x, self.m_y)
	self.m_mapData = mapData

	-- 侦查
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local storeBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onScoutCallback)):addTo(self:getBg())
	storeBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 26)
	storeBtn:setLabel(CommonText[313][5])
	if mapData and mapData.my then  -- 自己已经占领
		storeBtn:setEnabled(false)
	end

	-- 掠夺
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local scoutBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onPlunderCallback)):addTo(self:getBg())
	scoutBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
	scoutBtn:setLabel(CommonText[10047][2])
	if mapData and mapData.my then
		scoutBtn:setEnabled(false)
	end

	-- 占领
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local atkBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onAttackCallback)):addTo(self:getBg())
	atkBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 26)
	atkBtn:setLabel(CommonText[10047][3])
	if mapData and mapData.my then
		atkBtn:setEnabled(false)
	end
end

--侦察按钮回调
function CrossMineDialog:onScoutCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if not StaffBO.IsCrossServerMineAreaOpen() then
		Toast.show(CommonText[10056][1])  -- 非活动期间，无法侦查
		return
	end

	if self.m_mapData then
		local curTime = ManagerTimer.getTime()
		if curTime <= self.m_mapData.freeTime then  -- 处于保护时间内
			Toast.show(CommonText[10063][3])
			return
		end
	end

	local scout = WorldMO.queryScout(self.m_mine.lv)
	local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

	local function doneCallback(mail)
		Loading.getInstance():unshow()
		self:pop(function()
				require("app.view.ReportScoutView").new(mail):push()
			end)
	end
	local str = resData.name
	if scout.mulit then
		str = str .."("..scout.mulit..CommonText[988] ..")"
	end
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[310], UiUtil.strNumSimplify(scout.scoutCost), str, UserMO.scout_ + 1), function()
			local count = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
			if count < scout.scoutCost then
				Toast.show(resData.name .. CommonText[223])
				return
			end

			Loading.getInstance():show()
			StaffBO.asynSctCrossSeniorMine(doneCallback, self.m_x, self.m_y)
		end):push()
end

--掠夺按钮回调
function CrossMineDialog:onPlunderCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if not StaffBO.IsCrossServerMineAreaOpen() then
		Toast.show(CommonText[10056][2])  -- 非活动期间，无法掠夺
		return
	end

	if self.m_mapData then
		local curTime = ManagerTimer.getTime()
		if curTime <= self.m_mapData.freeTime then  -- 处于保护时间内
			Toast.show(CommonText[10063][3])
			return
		end
	end

	if StaffMO.plunderCount_ <= 0 then  -- 掠夺次数已经用完了
		Toast.show(CommonText[10063][1])
		return
	end

	if not self.m_mapData then
		Toast.show(CommonText[10063][2])  -- 该资源点无玩家开采，请点击占领
		return
	end

    StaffMO.curCrossAttackPos_ = cc.p(self.m_x, self.m_y)
    StaffMO.curCrossAttackType_ = MILITARY_AREA_PLUNDER
	
	self:pop(function()
	        local ArmyView = require("app.view.ArmyView")
	        local view = ArmyView.new(ARMY_VIEW_CORSS_MILITARY_AREA, 1):push()
		end)
end

--占领按钮回调
function CrossMineDialog:onAttackCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if not StaffBO.IsCrossServerMineAreaOpen() then
		Toast.show(CommonText[10056][3])  -- 非活动期间，无法占领
		return
	end

	if self.m_mapData then
		local curTime = ManagerTimer.getTime()
		if curTime <= self.m_mapData.freeTime then  -- 处于保护时间内
			Toast.show(CommonText[10063][3])
			return
		end

		Toast.show(CommonText[10063][4])  -- 该资源已被占领，请点击掠夺
		return
	end
	
    StaffMO.curCrossAttackPos_ = cc.p(self.m_x, self.m_y)
    StaffMO.curCrossAttackType_ = MILITARY_AREA_ATTACK
	
	self:pop(function()
	        local ArmyView = require("app.view.ArmyView")
	        local view = ArmyView.new(ARMY_VIEW_CORSS_MILITARY_AREA, 1):push()
		end)
end

return CrossMineDialog
