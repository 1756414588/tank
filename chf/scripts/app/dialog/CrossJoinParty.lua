--
-- Author: xiaoxing
-- Date: 2016-11-23 16:05:57
--
local ItemTableView = class("ItemTableView", TableView)

function ItemTableView:ctor(size,kind)
	ItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.kind = kind
	self.m_cellSize = cc.size(self:getViewSize().width, 60)
end

function ItemTableView:onEnter()
	ItemTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_JOIN_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function ItemTableView:numberOfCells()
	return #self.m_list
end

function ItemTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemTableView:createCellAtIndex(cell, index)
	ItemTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_list[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	local lab = self.kind == 1 and os.date("%H:%M", data.time) or "LV." .. data.partyLv
	local l = ui.newTTFLabel({text = lab, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 80, y = self.m_cellSize.height/2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	lab = self.kind == 1 and data.name or data.partyName
	l = ui.newTTFLabel({text = lab, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):alignTo(l, 115)
	if self.kind == 2 then
		l:hide()
		UiUtil.label(data.partyName,nil,COLOR[2]):alignTo(l, 16, 1)
		UiUtil.label(data.serverName):alignTo(l, -16, 1)
	end
	lab = self.kind == 1 and "LV."..data.lv or data.memberNum
	l = ui.newTTFLabel({text = lab, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):alignTo(l, 115)
	lab = self.kind == 1 and data.fight or data.totalFight
	if lab == 0 then 
		UiUtil.label(CommonText[20052]):alignTo(l, 115)
	else
		ui.newBMFontLabel({text = UiUtil.strNumSimplify(lab), font = "fnt/num_2.fnt"}):alignTo(l, 115)
	end
	return cell
end

function ItemTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarParties(function()
		Loading.getInstance():unshow()
		end, sender.page)
end

function ItemTableView:onExit()
	ItemTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

function ItemTableView:updateUI(data)
	self.m_list = data
	self:reloadData()
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local CrossJoinParty = class("CrossJoinParty", Dialog)

function CrossJoinParty:ctor(kind)
	CrossJoinParty.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.kind = kind
end

function CrossJoinParty:onEnter()
	CrossJoinParty.super.onEnter(self)
	
	self:setTitle(self.kind == 1 and CommonText[30066][1] or CommonText[798][1])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	
	local signLab = ui.newTTFLabel({text = self.kind == 1 and CommonText[30066][2] or CommonText[30069][1], font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[11], x = 40, y = btm:getContentSize().height - 70}):addTo(btm)

	local signValue = ui.newTTFLabel({text = 0, font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[2], x = signLab:getPositionX() + signLab:getContentSize().width / 2, y = btm:getContentSize().height - 70}):addTo(btm)
	
	local infoLabel = UiUtil.label(CommonText[30069][self.kind == 1 and 2 or 3]):addTo(btm):align(display.LEFT_CENTER,270,signLab:y())
	local info = UiUtil.label("",nil,COLOR[2]):rightTo(infoLabel)
	self.info = info
	self.num = signValue
	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - (self.kind == 1 and 110 or 150)))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:align(display.CENTER_BOTTOM, btm:getContentSize().width / 2, 20)

	if self.kind == 2 then
		signLab:y(signLab:y() - 40)
		signValue:y(signValue:y() - 40)
		infoLabel:y(infoLabel:y() - 40)
		info:y(info:y() - 40)
		local bg = UiUtil.sprite9("info_bg_27.png",80,15,480,20,516,56)
			:addTo(btm):pos(btm:width()/2,btm:height() - 55)
		--tab按钮
	    self.btn1 = UiUtil.button("btn_56_normal.png", "btn_56_selected.png", nil, handler(self,self.showIndex),string.format(CommonText[30070],"A"))
	   		:addTo(bg,0,1):pos(90,bg:height()/2+2)
	  	self.btn2 = UiUtil.button("btn_57_normal.png", "btn_57_selected.png", nil, handler(self,self.showIndex),string.format(CommonText[30070],"B"))
	  	 	:addTo(bg,0,2):alignTo(self.btn1, 108)
	 	self.btn3 = UiUtil.button("btn_57_normal.png", "btn_57_selected.png", nil, handler(self,self.showIndex),string.format(CommonText[30070],"C"))
	 		:addTo(bg,0,3):alignTo(self.btn2, 116)
	  	self.btn3:setScaleX(-1)
	  	self.btn3.m_label:setScaleX(-1)
	  	self.btn4 = UiUtil.button("btn_56_normal.png", "btn_56_selected.png", nil, handler(self,self.showIndex),string.format(CommonText[30070],"D"))
	  	 	:addTo(bg,0,4):alignTo(self.btn3, 108)
  	 	self.btn4:setScaleX(-1)
  	 	self.btn4.m_label:setScaleX(-1)
	end

	local posX = {80,195,310,425}
	local lab = CommonText[801]
	if self.kind == 1 then
		lab = CommonText[799]
	end
	for index=1,#lab do
		local title = ui.newTTFLabel({text = lab[index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = cc.c3b(115,115,115), align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
	end

	local view = ItemTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.kind):addTo(tableBg)
	view:setPosition(0, 25)
	self.view = view
	local l = {"A","B","C","D"}
	if self.kind == 1 then
		CrossPartyBO.getMyPartyInfo(function(data,group)
				self.num:setString(#data)
				self.info:setString(group == 0 and CommonText[20052] or string.format(CommonText[30070],l[group]))
				view:updateUI(data)
			end)
	else
	  	self:showIndex(1)
	end
end

function CrossJoinParty:showIndex(tag,sender)
	if tag == self.tag then return end
	for i=1,4 do
		if i == tag then
			self["btn"..i]:selected()
		else
			self["btn"..i]:unselected()
		end
	end
	self.tag = tag
	CrossPartyBO.getPartyInfo(tag,function(data,num)
			data = data or {}
			self.num:setString(#data)
			self.view:updateUI(data)
			self.info:setString(num)
		end)
end

return CrossJoinParty