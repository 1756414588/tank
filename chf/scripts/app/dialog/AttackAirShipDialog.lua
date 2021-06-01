
------------------------------------------------------------------------------
-- 发起战事
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local AttackAirShipDialog = class("AttackAirShipDialog", Dialog)

function AttackAirShipDialog:ctor(airshipId, freeCount)
	AttackAirShipDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 350)})
	self.m_airshipId = airshipId
	self.m_freeCount = freeCount or 0
end

function AttackAirShipDialog:onEnter()
	AttackAirShipDialog.super.onEnter(self)
	self:setOutOfBgClose(true)
	self:setTitle(CommonText[1003][2])  -- 军团集结

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 320))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)


	local lab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL+2, 
		x = self:getBg():getContentSize().width / 2, 
		y = self:getBg():getContentSize().height - 60, 
		dimensions = cc.size(420, 120),
		align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	lab:setAnchorPoint(cc.p(0.5, 1))

	local ship = AirshipMO.queryShipById(self.m_airshipId)
	local freetime = self.m_freeCount
	local strContent = string.format(CommonText[1049], ship.name, freetime)

	gprint("@^^^^^^^^^^freetime ", freetime)

	if freetime > 0 then
		strContent = strContent .. CommonText[1050][1]
	else
		local prop = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_MASS_AIRSHIP)
		local propCount = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_MASS_AIRSHIP)
		local costCount = 1
		strContent = strContent .. string.format(CommonText[1050][2], costCount, prop.name)

		local tip = UiUtil.label("拥有:"):addTo(self:getBg()):pos(self:getBg():getContentSize().width*0.5 - 60, 100)

		local item = UiUtil.createItemView(ITEM_KIND_PROP, PROP_ID_MASS_AIRSHIP):alignTo(tip, 60)
		item:setScale(0.6)

		UiUtil.createItemDetailButton(item)

		local lbCount = UiUtil.label("*" .. UiUtil.strNumSimplify(propCount), nil, nil, nil, ui.TEXT_ALIGN_LEFT):alignTo(tip, 100)
		lbCount:setAnchorPoint(cc.p(0,0.5))
		if propCount < 1 then
			lbCount:setColor(cc.c3b(255,0,0))
		end
	end

	lab:setString(strContent)

	---取消
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local cancelBtn = MenuButton.new(normal, selected, nil, function ()
		self:pop()
	end):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width * 0.25,25)
	cancelBtn:setLabel(CommonText[1048][1])	

	---出击
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local attackBtn = MenuButton.new(normal, selected, nil, handler(self,self.doAttackHandler)):addTo(self:getBg())
	attackBtn:setPosition(self:getBg():getContentSize().width * 0.75,25)
	attackBtn:setLabel(CommonText[1048][2])		
end

function AttackAirShipDialog:doAttackHandler()
	ManagerSound.playNormalButtonSound()

	local airshipId = self.m_airshipId
	local freetime = self.m_freeCount

	if freetime < 1 then
		local cost = 1
		if UserMO.getResource(ITEM_KIND_PROP, PROP_ID_MASS_AIRSHIP) < cost then
			local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_MASS_AIRSHIP)
			Toast.show(resData.name .. CommonText[223])
			return
		end
	end

	AirshipBO.createAirshipTeam(airshipId,function()
		self:pop(function()
				UiDirector.pop()
				require("app.view.ArmyView").new(nil,4):push()
				Toast.show(CommonText[997][1])
			end)
	end)
end

return AttackAirShipDialog
