--
-- Author: Gss
-- Date: 2018-09-18 16:40:06
--

-- 奖励
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,data)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_data = data
	self.m_cellSize = cc.size(size.width, 200)
	armature_add(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")
end

function ContentTableView:numberOfCells()
	return #self.m_data
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_data[index]

	local qeAreaInfo = LaboratoryMO.getLaboratoryLurkArea(data.areaId)

	local t = display.newSprite(IMAGE_COMMON .."info_bg_12.png"):addTo(cell):align(display.LEFT_TOP, 20, self.m_cellSize.height - 20)
	UiUtil.label(qeAreaInfo.name):addTo(t):align(display.LEFT_CENTER, 55, t:height()/2)

	local awardDB = PbProtocol.decodeArray(data["award"])
	for k,v in ipairs(awardDB) do
		local itemView = UiUtil.createItemView(v.type, v.id,{count = v.count})
		itemView:setPosition(30 + itemView:getContentSize().width / 2 + (k - 1) * 100,self.m_cellSize.height - 130)
		itemView:setScale(0.9)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)
		local propDB = UserMO.getResourceData(v.type, v.id)
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 6, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	local titleSize = data.awardLevel == 1 and 3 or 2
	local _scale = 3.0
	local _sizeIndex = 0

	local function armatureShow()
		_sizeIndex = _sizeIndex + 1
		if _sizeIndex >= titleSize then
			local armature = armature_create("ui_flash", self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 20, function (movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:removeSelf()
					end
			 end):addTo(cell, 12)
			armature:getAnimation():playWithIndex(0)
		end
	end

	for index = 1 , titleSize do
		local spItem = display.newSprite(IMAGE_COMMON .. "word_" .. (index - 1) .. ".png"):addTo(cell, 10)
		spItem:setScale(_scale)
		spItem:setVisible(false)
		local _y = self.m_cellSize.height / 2 + 60

		local _x = CalculateX(titleSize, index, spItem:width() - 10, 1.2)
		local _x1 = self.m_cellSize.width - 100 - _x
		
		local _x_ = CalculateX(titleSize, index, spItem:width() * _scale, 1.2)
		local _x2_ = self.m_cellSize.width * 0.5 - _x_ 

		spItem:setPosition( _x2_ , _y)

		local spwArray = cc.Array:create()
		spwArray:addObject(CCScaleTo:create(0.3, 0.5))
		spwArray:addObject(CCMoveTo:create(0.3, cc.p(_x1, _y)))

		spItem:runAction(transition.sequence({cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
			spItem:setVisible(true)
		end),cc.Spawn:create(spwArray),cc.CallFunc:create(function ()
			armatureShow()
		end)}))
	end

	-- for index = 1 , 3 do
	-- 	local spItem = display.newSprite(IMAGE_COMMON .. "word_" .. (index - 1) .. ".png"):addTo(cell)
	-- 	spItem:setPosition(self.m_cellSize.width - 80 - (index - 1)*50, self.m_cellSize.height / 2 - 20)
	-- 	spItem:setScale(0.8)
	-- end

	return cell
end

function ContentTableView:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/ui_flash.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_flash.plist", IMAGE_ANIMATION .. "effect/ui_flash.xml")
end
------------------------------------------------------------------------------
-- 作战室领奖显示界面
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local LaboratoryAwardDialog = class("LaboratoryAwardDialog", Dialog)

function LaboratoryAwardDialog:ctor(data, callBack)
	LaboratoryAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.m_data = data
	self.m_callBack = callBack
end

function LaboratoryAwardDialog:onEnter()
	LaboratoryAwardDialog.super.onEnter(self)
	self:setTitle(CommonText[269])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(self:getBg())
	frame:setPreferredSize(cc.size(500, self:getBg():height()-160))
	frame:setCapInsets(cc.rect(130, 40, 1, 1))
	frame:align(display.CENTER_TOP,self:getBg():width()/2,self:getBg():height()-70)

	local view = ContentTableView.new(cc.size(490, self:getBg():height()-192),self.m_data)
		:addTo(self:getBg()):pos(45,100)
	view:reloadData()

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local exchangeBtn = MenuButton.new(normal ,selected, nil, function ()
		if self.m_callBack then self.m_callBack() end
		self:pop()
	end):addTo(self:getBg())
	exchangeBtn:setPosition(self:getBg():getContentSize().width / 2, 66)
	exchangeBtn:setLabel(CommonText[1])
end

function LaboratoryAwardDialog:CloseAndCallback()
	if self.m_callBack then self.m_callBack() end
end

function LaboratoryAwardDialog:onExit()
	LaboratoryAwardDialog.super.onExit(self)
end

return LaboratoryAwardDialog
