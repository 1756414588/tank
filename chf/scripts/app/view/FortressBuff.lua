--
-- Author: Xiaohang
-- Date: 2016-06-26 19:46:28
--

--------------------------------------------------------------------
-- 增益tableview
--------------------------------------------------------------------
local EffectTableView = class("EffectTableView", TableView)

function EffectTableView:ctor(size,state,camp)
	EffectTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.state = state
	self.camp = camp
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_effects = FortressMO.getAttrs()
end

function EffectTableView:numberOfCells()
	return self.camp == FortressBO.ATTACK and 5 or 4
end

function EffectTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EffectTableView:createCellAtIndex(cell, index)
	EffectTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = FortressMO.getImage(index):addTo(cell)
		:pos(100, self.m_cellSize.height / 2)

	local effectDB = FortressMO.queryAttrById(index,FortressBO.attrs_[index])
	local nextDb = FortressMO.queryAttrById(index,(FortressBO.attrs_[index] or 0) + 1)
	local title = ui.newTTFLabel({text = effectDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[12]}):addTo(cell)
	local str = nextDb and CommonText[20045] ..nextDb._desc or effectDB._desc
	local des = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 65, color = COLOR[12],
			align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(340, 0)}):addTo(cell)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
	local useBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onUp))
	useBtn.id = effectDB.id
	cell:addButton(useBtn, self.m_cellSize.width - 80, self.m_cellSize.height / 2 - 22)
	if nextDb then
		useBtn.name = nextDb.name
		local t = display.newSprite(IMAGE_COMMON.."icon_coin.png")
			:addTo(cell):pos(self.m_cellSize.width - 100,114)
		UiUtil.label(nextDb.price):addTo(cell):rightTo(t, 5)
		useBtn.price = nextDb.price
	else
		useBtn:hide()
	end

	if self.state == FortressMO.TIME_PREHEAT or self.state == FortressMO.TIME_WAR then
	else 
		useBtn:setEnabled(false)
	end
	return cell
end

function EffectTableView:onUp(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not FortressMO.isOpen_ then 
		Toast.show(CommonText[20062])
		return
	end
	if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then	
		if FortressBO.statusParty_ then
			if not FortressBO.statusParty_[PartyMO.partyData_.partyId] then
				Toast.show(CommonText[20057])
				return
			end
		end
	else
		Toast.show(CommonText[20057])
		return
	end
	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[20044], sender.price, sender.name), function()
				FortressBO.upAttr(sender.id,function()
					self:reloadData()
				end)
		end):push()
	else
		FortressBO.upAttr(sender.id,function()
			self:reloadData()
		end)
	end
end

--------------------------------------------------------------------
-- 增益view
--------------------------------------------------------------------

local FortressBuff = class("FortressBuff", UiNode)

function FortressBuff:ctor(state,camp)
	self.state = state
	self.camp = camp
	FortressBuff.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function FortressBuff:onEnter()
	FortressBuff.super.onEnter(self)
	-- 增益信息
	self:setTitle(CommonText[20021])
	self:showUI()
end

function FortressBuff:fortressUpdate()
	FortressBO.attrs_ = nil
	self.view.state = FortressMO.TIME_PREHEAT
	self:performWithDelay(function()
			FortressBO.fortressAttr(function()
					self.view:reloadData()
				end)
			end, 2)

end

function FortressBuff:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container.status = 1 -- 显示装备
		self.m_container = container
	end

	local container = self.m_container

	container:removeAllChildren()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 40)

	local view = EffectTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 40),self.state,self.camp):addTo(container)
	self.view = view
	self.m_activityHandler = Notify.register(LOCAL_FORTRESS_BUFF, handler(self, self.fortressUpdate))
	view:setPosition(0, 40)
	FortressBO.fortressAttr(function()
			view:reloadData()
		end)

	UiUtil.label(CommonText[20022]):addTo(self):align(display.LEFT_CENTER,50,46)
end

function FortressBuff:onExit()
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

return FortressBuff