-- 勋章界面
local LvLock = json.decode(UserMO.querySystemId(18))
local MedalBaseView = class("MedalBaseView", UiNode)

function MedalBaseView:ctor(buildingId, enterStyle)
	enterStyle = enterStyle or UI_ENTER_NONE
	MedalBaseView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
end

function MedalBaseView:onEnter()
	MedalBaseView.super.onEnter(self)
	self:setTitle(CommonText[20163][1])

	self.m_partHandler = Notify.register(LOCLA_MEDAL_EVENT, handler(self, self.onMedalUpdate))

	--详情
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTextDialog").new(DetailText.medalInfo):push() 
		end):addTo(self:getBg(),2):pos(590,self:getBg():height()-135)
	self:showUI()
end

function MedalBaseView:onExit()
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
end

function MedalBaseView:showUI(tRank)
	if not self.container then
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 + container:getContentSize().height / 2)
		self.container = container
	end

	local container = self.container
	self.container:removeAllChildren()

	self:showMedal(tRank)

	-- 展厅
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local showBtn = MenuButton.new(normal, selected, nil, handler(self, self.onShowCallback)):addTo(container)
	showBtn:setLabel(CommonText[20179][1])
	showBtn:setPosition(110, 40)
	self.m_showBtn = showBtn

	-- 配件探险
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_5_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_5_selected.png')
	local warehouseBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCombatCallback)):addTo(container)
	warehouseBtn:setLabel(CommonText[20163][1] ..CommonText[44])
	warehouseBtn:setPosition(container:width()/2, 40)

	-- 仓库
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local warehouseBtn = MenuButton.new(normal, selected, nil, handler(self, self.onWarehouseCallback)):addTo(container)
	warehouseBtn:setLabel(CommonText[169])
	warehouseBtn:setPosition(container:getContentSize().width - 110, 40)
	self.m_warehouseBtn = warehouseBtn
	self:onUpdateTip()
end

function MedalBaseView:showMedal(tRank)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self.container)
	bg:setPreferredSize(cc.size(self.container:width() - 10, self.container:height() - 140))
	bg:pos(self.container:width()/2,self.container:height() - bg:height()/2)
	display.newSprite(IMAGE_COMMON.."renwu.png"):addTo(bg):center()
	local ey = 112
	self.equips = MedalMO.getPosMedal(1)
	self.unequips = MedalMO.getPosMedal(0)
	for m,n in pairs(self.unequips) do
		table.sort(n,MedalMO.sortMedal)
	end
	local t = self:showItem(bg,9,240,bg:height() - 70)
	self:showItem(bg,10,bg:width() - t:x(),t:y())
	ey = ey / 2
	t = self:showItem(bg,1,110,t:y() - ey)
	self:showItem(bg,2,bg:width() - t:x(),t:y())
	ey = ey * 2 + 10
	for i=1,3 do
		t = self:showItem(bg,i*2+1,70,t:y() - ey)
		self:showItem(bg,i*2+2,bg:width() - t:x(),t:y())
	end
	--属性
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(bg)
		:align(display.LEFT_CENTER, 15, 120)
	-- 增加属性
	local title = ui.newTTFLabel({text = CommonText[160], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)
	local attrList = {ATTRIBUTE_INDEX_ATTACK+1,ATTRIBUTE_INDEX_HP+1,ATTRIBUTE_INDEX_FRIGHTEN,ATTRIBUTE_INDEX_FORTITUDE,ATTRIBUTE_INDEX_BURST+1,ATTRIBUTE_INDEX_TENACITY+1}
	-- 配件的各个属性值
	local attrs = MedalBO.getEquipAttr(1)
	local x,y,ex,ey = 50,75,190,45
	for k,v in ipairs(attrList) do
		local attr = attrs[v] or AttributeBO.getAttributeData(v, 0)
		local tx, ty = x + math.floor((k-1)/2)*ex,y - (k-1)%2*ey
		local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = attr.attrName}):addTo(bg):pos(tx,ty)
		local name = ui.newTTFLabel({text = attr.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		name:setAnchorPoint(cc.p(0, 0.5))
		name:setColor(COLOR[11])
		name:setPosition(itemView:getPositionX() + 30, itemView:getPositionY())
		local value = ui.newTTFLabel({text = "+" .. attr.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		value:setAnchorPoint(cc.p(0, 0.5))
	end
	--强度
	local strengthLabel = display.newSprite(IMAGE_COMMON .. "label_medal_strength.png"):addTo(bg)
		:align(display.LEFT_CENTER, 400, 120)
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs.strengthValue or 0), font = "fnt/num_2.fnt"}):rightTo(strengthLabel, 10)
	if tRank and attrs.strengthValue and attrs.strengthValue > 0 then
		UserBO.asynSetData(nil, 9, attrs.strengthValue)
	end
end

function MedalBaseView:clickCall(tag, sender)
	if sender.data then
		if sender.data == 0 then
		else
			require("app.dialog.MedalDialog").new(sender.data.keyId):push()
		end
	else
		Toast.show(string.format(CommonText[20176], LvLock[tag][2]))
	end
end

function MedalBaseView:showItem(bg,pos,x,y)
	local t = nil
	if UserMO.level_ < LvLock[pos][2] then
		t = display.newSprite(IMAGE_COMMON .. "item_bg_1.png")
		display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(t):center()
		display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(t):center()
		UiUtil.label("LV."..LvLock[pos][2],22):addTo(t):pos(t:width()/2,15)
	else
		if self.equips[pos] then
			local data = self.equips[pos][1]
			t = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON,data.medalId,{data = data})
			t.data = data
			local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(t)
			lockIcon:setScale(0.5)
			lockIcon:setPosition(t:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, t:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
			lockIcon:setVisible(data.locked)
		else
			t = display.newSprite(IMAGE_COMMON .. "item_bg_1.png")
			display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(t):center()
			t.data = 0
			if self.unequips[pos] then
				display.newSprite(IMAGE_COMMON.."icon_plus.png"):addTo(t):center()
				t.data = self.unequips[pos][1]
			end
		end
		-- 红点提示
		local hasBigState = MedalBO.checkListUpMedalsAtPos(self.equips[pos], self.unequips[pos])
		if hasBigState then
			local tipstate = display.newSprite(IMAGE_COMMON .. "icon_red_point.png"):addTo(t, 10)
			tipstate:setScale(0.75)
			tipstate:setPosition(t:width() - tipstate:width() * 0.5 ,t:height() - tipstate:height() * 0.5)
		end
	end
	if t.data then
		UiUtil.label(RomeNum[pos]):addTo(t):align(display.LEFT_BOTTOM,5,5)
	end
	t:addTo(bg,0,pos):pos(x,y)
	local normal = display.newNode():size(t:width(),t:height())
	normal:setAnchorPoint(cc.p(0.5, 0.5))
	normal = TouchButton.new(normal, nil, nil, nil, handler(self, self.clickCall)):addTo(t,0,pos):center()
	normal.data = t.data
	return t
end

function MedalBaseView:onShowCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.MedalShowView").new():push()
end

function MedalBaseView:onCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local CombatLevelView = require("app.view.CombatLevelView")
	CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_MEDAL)):push()
end

function MedalBaseView:onWarehouseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.MedalWarehouseView").new():push()
end

function MedalBaseView:onMedalUpdate()
	self:showUI(1)
	self:onUpdateTip()
end

function MedalBaseView:onUpdateTip()
	local medals = MedalMO.getFreeMedals()
	if #medals > 0 then
		UiUtil.showTip(self.m_warehouseBtn, #medals)
	else
		UiUtil.unshowTip(self.m_warehouseBtn)
	end

	local shows = MedalMO.getAllShowMedals(true)
	if shows > 0 then
		UiUtil.showTip(self.m_showBtn, shows)
	else
		UiUtil.unshowTip(self.m_showBtn)
	end
end

function MedalBaseView:refreshUI()
	self:showUI()
	self:onUpdateTip()
end

return MedalBaseView
