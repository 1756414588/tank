
------------------------------------------------------------------------------
-- 联系人TableView
------------------------------------------------------------------------------

local AirshipAppointTableView = class("AirshipAppointTableView", TableView)

function AirshipAppointTableView:ctor(size,data,select)
	AirshipAppointTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 145)
	self.m_list = data
	self.m_select = select
	-- for k,v in pairs(self.m_list) do
	-- 	if v.checked == nil then
	-- 		v.checked = false
	-- 	end
	-- end
end

function AirshipAppointTableView:numberOfCells()
	return #self.m_list
end

function AirshipAppointTableView:cellSizeForIndex(index)
	return self.m_cellSize
end


function AirshipAppointTableView:createCellAtIndex(cell, index)
	AirshipAppointTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 50, self.m_cellSize.height - 4))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local contact = self.m_list[index]

	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, contact.icon):addTo(cell)
	itemView:setScale(0.5)
	itemView:setPosition(115, self.m_cellSize.height / 2)

	-- 名称
	local label = ui.newTTFLabel({text = contact.nick, font = G_FONT, size = FONT_SIZE_SMALL, x = 190, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()
		if isChecked and self.m_mode == CONTACT_MODE_SINGLE then  -- 一次只能选中一个
			for idx = 1, self:numberOfCells() do
				if idx ~= index then
					local cell = self:cellAtIndex(idx)
					if cell then
						cell.checkBox:setChecked(false)
					end
					self.m_list[idx].checked = false
				else
					self.m_list[idx].checked = true
				end
			end
		end
		self:dispatchEvent({name = "AIR_CHOSEN_EVENT", lordId = contact.lordId})
	end

	local checkBox = CellCheckBox.new(nil, nil, onCheckedChanged)
	checkBox:setChecked(contact.checked)
	cell:addButton(checkBox, self.m_cellSize.width - 90, self.m_cellSize.height / 2 - 20)
	cell.checkBox = checkBox

	return cell
end

------------------------------------------------------------------------------
-- 飞艇任命候选人弹出框
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local AirshipAppointDialog = class("AirshipAppointDialog", Dialog)

function AirshipAppointDialog:ctor(mineIndex, airshipdata, callback)
	AirshipAppointDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_LEFT_TO_RIGHT, {scale9Size = cc.size(588, 860)})
	-- body
	self.mineIndex = mineIndex
	self.airshipdata = airshipdata
	self.callback = callback
	self.ourCandidate = nil
	self.newLordId = 0
	self.oldLordId = 0
	self.outShip = 0
end

function AirshipAppointDialog:onEnter()
	AirshipAppointDialog.super.onEnter(self)

	self:setTitle(CommonText[1012][1]) -- 飞艇任命候选人

	local filter = {}
	self.oldLordId = 0
	for index = 1 , #self.airshipdata do
		local data = self.airshipdata[index]
		local shipid = data.shipid
		local commander = data.commanderid
		if index == self.mineIndex then
			self.outShip = shipid
			self.oldLordId = commander
		else
			filter[commander] = shipid
		end
	end

	self.newLordId = self.oldLordId

	-- 筛选掉已经有飞艇的人(排除当前选中拥有的)
	self.ourCandidate = clone(PartyMO.partyData_.partyMember)
	for index = #self.ourCandidate , 1,-1 do
		local people = self.ourCandidate[index]
		people.checked = false			
		if self.oldLordId == people.lordId then
			people.checked = true
		end
		if filter[people.lordId] then
			table.remove(self.ourCandidate,index)
		end
	end

	self:ShowUI()
end

function AirshipAppointDialog:ShowUI()
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = AirshipAppointTableView.new(cc.size(self:getBg():getContentSize().width - 20, self:getBg():getContentSize().height - 190), self.ourCandidate):addTo(self:getBg())
	view:addEventListener("AIR_CHOSEN_EVENT", handler(self, self.choose))
	view:setPosition(10, 130)
    view:reloadData()

    local btn = UiUtil.button("btn_10_normal.png", "btn_10_selected.png", nil, handler(self, self.ok),CommonText[1]):addTo(self:getBg())
    btn:setPosition(self:getBg():getContentSize().width * 0.5, 80)
end

function AirshipAppointDialog:choose(event)
	self.newLordId = event.lordId
end

function AirshipAppointDialog:ok(tag,sender)
	ManagerSound.playNormalButtonSound()
	if self.newLordId == 0 then
		Toast.show(CommonText[1012][2])
		return
	end
	
	if self.newLordId == self.oldLordId then
		self:pop()
		return
	end

	local oldNick = ""
	local newNick = ""

	for i,v in ipairs(self.ourCandidate) do
		if v.lordId == self.newLordId then
			newNick = v.nick
		elseif v.lordId == self.oldLordId then
			oldNick = v.nick
		end
	end
	local str = string.format(CommonText[1044], oldNick, newNick)

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(str, function()
		Loading.getInstance():unshow()
		AirshipBO.AppointAirshipCommander(self.outShip, self.newLordId, function(data)
			if self.callback then self.callback(data.airship_id,data.lordId) end
		end)
	end):push()
end

return AirshipAppointDialog