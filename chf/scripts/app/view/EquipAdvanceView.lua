--
-- Author: xiaoxing
-- Date: 2016-11-29 15:18:25
--
-- 装备进阶view

local EquipAdvanceView = class("EquipAdvanceView", UiNode)

function EquipAdvanceView:ctor(keyId)
	EquipAdvanceView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)

	self.m_keyId = keyId -- 装备的keyId

end

function EquipAdvanceView:onEnter()
	EquipAdvanceView.super.onEnter(self)
	
	-- 装备升级
	self:setTitle(CommonText[7] .. CommonText[5001])
	self.container = display.newNode():size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180):addTo(self)
	self:showUI()
end

function EquipAdvanceView:showUI()
	local container = self.container
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 620))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - infoBg:getContentSize().height / 2 + 75)
	--获取当前点击的部件
	local equip = EquipMO.getEquipByKeyId(self.m_keyId)
	local equipDB = EquipMO.queryEquipById(equip.equipId)

	-- --详情按钮
	-- local detail_normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	-- local detail_selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	-- local detailBtn = MenuButton.new(detail_normal, detail_selected, nil, handler(self, self.onAdvanceDetail)):addTo(infoBg)
	-- detailBtn:setPosition(infoBg:getContentSize().width - 50,infoBg:getContentSize().height - 20 - detailBtn:getContentSize().height / 2)

	--显示的装备
	local beganView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(infoBg)
	beganView:setPosition(130,infoBg:getContentSize().height - 105)
	UiUtil.createItemDetailButton(beganView)

	--显示箭头
	local arrow = display.newSprite(IMAGE_COMMON .. "advance_arrow.png"):addTo(infoBg)
	arrow:setAnchorPoint(cc.p(0,0.5))
	arrow:setPosition(beganView:getPositionX() + 120,beganView:getPositionY())

	if equipDB.transform > 0 then
		local endView = UiUtil.createItemView(ITEM_KIND_EQUIP, equipDB.transform, {equipLv = EquipMO.getAdvanceLv(self.m_keyId), star = equip.starLv}):addTo(infoBg)
		endView:setPosition(130 + 300,infoBg:getContentSize().height - 105)
		UiUtil.createItemDetailButton(endView)

		--part的名字
		local beganName = ui.newTTFLabel({text = UserMO.getResourceData(ITEM_KIND_EQUIP,equip.equipId).name2,font = 22,size = FONT_SIZE_SMALL,x = beganView:getPositionX(), y = beganView:getPositionY() - beganView:getContentSize().height/2,color = COLOR[equipDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		beganName:setAnchorPoint(cc.p(0.5,1))
		beganName:setScale(0.8)

		local endName = ui.newTTFLabel({text = UserMO.getResourceData(ITEM_KIND_EQUIP,equipDB.transform).name2,font = 22,size = FONT_SIZE_SMALL,x = endView:getPositionX(), y = endView:getPositionY() - endView:getContentSize().height/2,color = COLOR[equipDB.quality + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		endName:setAnchorPoint(cc.p(0.5,1))
		endName:setScale(0.8)
	else
		UiUtil.label(CommonText[5024],nil,COLOR[6]):addTo(infoBg):pos(370,infoBg:getContentSize().height - 105)
		return
	end
	--分节线
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(554, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 203)

	if equipDB.quality == 5 then
		local desc = ui.newTTFLabel({text = CommonText[5007], font = G_FONT, size = FONT_SIZE_MEDIUM, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 240, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
		return
	end
	-- 进阶消耗
	local label = ui.newTTFLabel({text = CommonText[5002], font = G_FONT, size = FONT_SIZE_SMALL, x = 74, y = infoBg:getContentSize().height - 227, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	-- 进阶note
	local label = ui.newTTFLabel({text = CommonText[20153], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	--需要消耗的材料
	local x,y,ex,ey = 110,infoBg:height() - 295, 275, 112
	for k,v in ipairs(json.decode(equipDB.cost)) do
		local tx,ty = x + (k-1)%2*ex,y - math.floor((k-1)/2)*ey
		local view = UiUtil.createItemView(v[1], v[2]):addTo(infoBg):pos(tx,ty):scale(0.82)
		UiUtil.createItemDetailButton(view)
		local propDB = UserMO.getResourceData(v[1], v[2])
		local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1]):addTo(infoBg):align(display.LEFT_CENTER,tx+65,ty+32)
		t = UiUtil.label(UiUtil.strNumSimplify(v[3])):alignTo(t, -32, 1)
		local own = UserMO.getResource(v[1],v[2])
		UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<v[3] and 6 or 2]):rightTo(t)
	end

	UiUtil.label(CommonText[20155][1],nil,nil,cc.size(510,0),ui.TEXT_ALIGN_LEFT):addTo(infoBg)
		:align(display.LEFT_TOP, (infoBg:width() - 510)/2,70)

	--点击进阶按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local advanceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAdvanceCallback)):addTo(container)
    advanceBtn:setPosition(container:width() / 2, 80)
    advanceBtn:setLabel(CommonText[5001])
    advanceBtn.equip = equip
end

function EquipAdvanceView:onAdvanceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function getResult(part)
		self.container:removeAllChildren()
		-- self:showUI()
		self:pop()
	end
	EquipBO.equipUp(sender.equip,getResult)
end

function EquipAdvanceView:onAdvanceDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	DetailTextDialog.new(DetailText.equipAdvance):push()
end

return EquipAdvanceView
