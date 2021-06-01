
-- 收藏弹出框

local Dialog = require("app.dialog.Dialog")
local StoreDialog = class("StoreDialog", Dialog)

-- storeType:收藏类型
function StoreDialog:ctor(storeType, x, y, param)
	gprint("StoreDialog x", x, "y", y)
	self.m_storeType = storeType
	self.m_x = x
	self.m_y = y
	self.m_param = param

	StoreDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 400)})
end

function StoreDialog:onEnter()
	StoreDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[313][4]) -- 收藏

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 230))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	if self.m_storeType == STORE_TYPE_RESOURCE then  -- 收藏资源
		local mine = WorldBO.getMineAt(cc.p(self.m_x, self.m_y))
		local sprite = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, mine.type, {level = mine.lv}):addTo(infoBg)
		sprite:setAnchorPoint(cc.p(0.5, 0))
		sprite:setScale(0.9)
		sprite:setPosition(105, 80)

		local resData = UserMO.getResourceData(ITEM_KIND_WORLD_RES, mine.type)
		-- 多少级的什么
		local label = ui.newTTFLabel({text = mine.lv .. CommonText[237][4] .. resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = infoBg:getContentSize().height - 80, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local level = ui.newTTFLabel({text = "LV." .. mine.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 20, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		level:setAnchorPoint(cc.p(0, 0.5))

		self.m_mine = {mineLv = mine.lv, mineId = 0}

	elseif self.m_storeType == STORE_TYPE_PLAYER then -- 收藏玩家
		local man = self.m_param
		-- local mapData = WorldMO.getMapDataAt(self.m_x, self.m_y)

		local sprite = UiUtil.createItemView(ITEM_KIND_PORTRAIT, man.icon):addTo(infoBg)
		sprite:setAnchorPoint(cc.p(0.5, 0))
		sprite:setPosition(105, 80)
		sprite:setScale(0.6)

		local label = ui.newTTFLabel({text = man.nick, font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = infoBg:getContentSize().height - 80, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local level = ui.newTTFLabel({text = "LV." .. man.level, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 20, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		level:setAnchorPoint(cc.p(0, 0.5))

		self.m_man = {icon = man.icon, level = man.level, nick = man.nick, lordId = man.lordId, sex = man.sex}

	end

	-- 坐标(x, y)
	local label = ui.newTTFLabel({text = CommonText[305] .. ": " .. "(" .. self.m_x .. " , " .. self.m_y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = infoBg:getContentSize().height - 80 - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(470, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, 75)

	-- 选择类别
	local label = ui.newTTFLabel({text = CommonText[383] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 36, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_mine_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_mine_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.isMineHandler)):addTo(infoBg)
	btn:setPosition(205, 35)
	self.m_isMine = 0

	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_enemy_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_enemy_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.isEnemyHandler)):addTo(infoBg)
	btn:setPosition(295, 35)
	self.m_enemy = 0

	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_friend_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_friend_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.isfriendHandler)):addTo(infoBg)
	btn:setPosition(385, 35)
	self.m_friend = 0

	if self.m_storeType == STORE_TYPE_RESOURCE then
		-- 返回
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local storeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onReturnCallback)):addTo(self:getBg())
		storeBtn:setPosition(self:getBg():getContentSize().width / 2 - 140, 26)
		storeBtn:setLabel(CommonText[99])
	end

	-- 保存
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local atkBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onStoreCallback)):addTo(self:getBg())
	if self.m_storeType == STORE_TYPE_RESOURCE then
		atkBtn:setPosition(self:getBg():getContentSize().width / 2 + 140, 26)
	else
		atkBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
	end
	atkBtn:setLabel(CommonText[309])
end

function StoreDialog:onReturnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function StoreDialog:onStoreCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	--判断收藏列表是否已满
	if #SocialityMO.myStore_ >= SocialityMO.myStoreMax then
		Toast.show(CommonText[850])
		return 
	end
	local function doneCallback()
		Loading.getInstance():unshow()
		self:pop()
		Toast.show(CommonText[384])  -- 收藏成功
	end

	Loading.getInstance():show()
	SocialityBO.asynRecordStore(doneCallback, WorldMO.encodePosition(self.m_x, self.m_y), self.m_enemy, self.m_friend, self.m_isMine, self.m_storeType,self.m_mine,self.m_man)
end

function StoreDialog:isMineHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_isMine == 0 then
		self.m_isMine = 1
		sender:selected()
	else
		self.m_isMine = 0
		sender:unselected()
	end
end

function StoreDialog:isEnemyHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_enemy == 0 then
		self.m_enemy = 1
		sender:selected()
	else
		self.m_enemy = 0
		sender:unselected()
	end
end

function StoreDialog:isfriendHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_friend == 0 then
		self.m_friend = 1
		sender:selected()
	else
		self.m_friend = 0
		sender:unselected()
	end
end

return StoreDialog
