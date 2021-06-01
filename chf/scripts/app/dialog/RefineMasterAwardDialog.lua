--
-- Author: Your Name
-- Date: 2017-06-02 13:52:50
--
local Dialog = require("app.dialog.Dialog")

local MasterAwardTableView = class("MasterAwardTableView", TableView)

function MasterAwardTableView:ctor(size, awards, tag)
	MasterAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_awards = awards
	self.tag = tag
	local height = size.height
	if self.m_awards and #self.m_awards > 0 then
		height = height + math.ceil(#self.m_awards / 5) * 95
	end
	
	self.m_cellSize = cc.size(size.width, height)
end

function MasterAwardTableView:onEnter()
	MasterAwardTableView.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")
end

function MasterAwardTableView:numberOfCells()
	return 1
end

function MasterAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MasterAwardTableView:createCellAtIndex(cell, index)
	MasterAwardTableView.super.createCellAtIndex(self, cell, index)
	for num =1,#self.m_awards do
		local itemView = UiUtil.createItemView(self.m_awards[num].type,self.m_awards[num].id,{count = self.m_awards[num].count}):addTo(cell)
		local resData = UserMO.getResourceData(self.m_awards[num].type,self.m_awards[num].id)
		local name = ui.newTTFLabel({text = resData.name.."*"..self.m_awards[num].count, font = G_FONT, size = 14, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		itemView:setScale(0.8)

		-- if num <= 5 then
		-- 	itemView:setPosition((num - 1) * 110 + 80,self:getBg():height() - itemView:height() / 2 - 20)
		-- 	name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
		-- else
		-- 	itemView:setPosition((num - 6) * 110 + 80,self:getBg():height() / 2 - itemView:height() / 2 + 20)
		-- 	name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
		-- end

		itemView:setPosition(5 + ((num - 1) % 5 + 1 - 0.5) * ((self.m_cellSize.width - 10) / 5) ,
							 self.m_cellSize.height - itemView:height() / 2 - math.floor((num - 1) / 5) * 110)
		name:setPosition(itemView:x(), itemView:y() - 60)

		local info = ActivityCenterMO.getConsumeById(self.tag)
		local propDB = json.decode(info.displaylist)
		for idx=1,#propDB do
			if (propDB[idx][1] == self.m_awards[num].type) and (propDB[idx][2] == self.m_awards[num].id) then
				local light = armature_create("clds_gaoji_tx", itemView:x(),itemView:y())
			    light:getAnimation():playWithIndex(0)
			    light:addTo(cell,-1)
			end
		end
	end

	return cell
end

function MasterAwardTableView:onExit()
	MasterAwardTableView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")
end

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

local RefineMasterAwardDialog = class("RefineMasterAwardDialog", Dialog)

function RefineMasterAwardDialog:ctor(data,type,rhand)
	RefineMasterAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(610, 300)})
	if type == 100 then
		RefineMasterAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(610, 340)})
	end
	self.m_data = data.awards
	self.ret = data.ret
	self.type = type
	self.rhand = rhand
	self.tag = 1
	if self.type == 10 then
		self.tag = 2
	elseif self.type == 100 then
		self.tag = 3
	end
	self.isShow = false
end

function RefineMasterAwardDialog:onEnter()
	RefineMasterAwardDialog.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.plist", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.xml")
	armature_add(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")

	self:setOutOfBgClose(false)
	self:setInOfBgClose(false)

	if self.tag == 3 then
		self:showUI(2)
	else
		self:showUI()
	end
end

function RefineMasterAwardDialog:showUI(kind)
	self.isShow = false
	self.myindex = 0
	self.effectShow_ = nil
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local lottery1Btn = MenuButton.new(normal, selected, nil, function ()
		if self.isShow == false then
			UiUtil.showAwards(self.ret)
		end
		self:pop()
	end):addTo(container)
	lottery1Btn:setPosition(self:getBg():width() / 4,lottery1Btn:height() / 4)
	lottery1Btn:setLabel(CommonText[1023])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local lottery10Btn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(container,0,1)
	lottery10Btn:setPosition(self:getBg():width() / 4 * 3,lottery10Btn:height() / 4)
	lottery10Btn:setLabel(CommonText[1024][self.tag])
	self.lotteryBtn = lottery10Btn
	if self.m_data and #self.m_data > 0 then
		if kind == 2 then
			self:showAwards()
			return
		end
		self:show()
		-- self.lotteryBtn:setEnabled(false)
		self.lotteryBtn:setLabel(CommonText[1032])
		self.lotteryBtn:setTag(2)
	end
end


function RefineMasterAwardDialog:show()

	self.myindex = self.myindex +1
	local itemView = UiUtil.createItemView(self.m_data[self.myindex].type,self.m_data[self.myindex].id,{count = self.m_data[self.myindex].count}):addTo(self.m_contentNode)
	local resData = UserMO.getResourceData(self.m_data[self.myindex].type,self.m_data[self.myindex].id)
	local name = ui.newTTFLabel({text = resData.name.."*"..self.m_data[self.myindex].count, font = G_FONT, size = 14, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_contentNode)
	name:setVisible(false)
	self.curName = name
	if #self.m_data == 1 then
		itemView:setPosition(self:getBg():width() / 2,self:getBg():height() / 2)
		name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
	else
		if self.myindex <= 5 then
			itemView:setPosition((self.myindex - 1) * 110 + 80,self:getBg():height() - itemView:height() / 2 - 20)
			name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
		else
			itemView:setPosition((self.myindex - 6) * 110 + 80,self:getBg():height() / 2 - itemView:height() / 2 + 20)
			name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
		end
	end
	itemView:setScale(0)

	local info = ActivityCenterMO.getConsumeById(self.tag)
	local propDB = json.decode(info.displaylist)
	for index=1,#propDB do
		if propDB[index][1] == self.m_data[self.myindex].type and propDB[index][2] == self.m_data[self.myindex].id then
			local light = armature_create("clds_gaoji_tx", itemView:x(),itemView:y())
		    light:getAnimation():playWithIndex(0)
		    light:addTo(self.m_contentNode,-1)
		end
	end

	local l1 = cc.CallFuncN:create(function(sender) 
		if not self.effectShow_ then
			local armature = armature_create("cuilian_huode_guangxiao", itemView:x(), itemView:y(), function(movementType, movementID, armature)
					if movementType == MovementEventType.COMPLETE then
						armature:setVisible(false)
						self.curName:setVisible(true)
						if self.myindex < #self.m_data then
							self:show()
						else
							self.lotteryBtn:setLabel(CommonText[1024][self.tag])
							self:performWithDelay(function ()
								self.isShow = true
								UiUtil.showAwards(self.ret)
							end, 0.1)
							-- self.lotteryBtn:setEnabled(true)
							-- self.lotteryBtn:setLabel(CommonText[1032])
							self.lotteryBtn:setTag(1)
						end
					end
				end):addTo(self.m_contentNode,999)
			self.effectShow_ = armature
		end
		local armature = self.effectShow_
		armature:setPosition(itemView:x(), itemView:y())
		armature:setVisible(true)
		armature:setScale(0.6)
		armature:getAnimation():playWithIndex(0)
		end)
	local l2 = cc.ScaleTo:create(0.3,0.8)
	local spwArray = cc.Array:create()
	spwArray:addObject(l1)
	spwArray:addObject(l2)
	local l3 = cc.Spawn:create(spwArray)
	itemView:runAction(l3)
end

function RefineMasterAwardDialog:lotteryHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local cost = ActivityCenterMO.getConsumeById(self.tag)
	function doLottery()
		if cost.price > UserMO.getResource(ITEM_KIND_CHAR,17) then
			Toast.show(CommonText[1025])
			return
		end
		ActivityCenterBO.RefineMasterLottery(function(data)
				Loading.getInstance():unshow()
				self.m_data = data.awards
				self.ret = data.ret
				-- self:showUI()
				if self.tag == 3 then
					self:showUI(2)
				else
					self:showUI()
				end
				self.rhand()
			end, self.type)
	end

	if tag == 1 then
		doLottery()
	else
		self:showUI(tag)
	end
	-- doLottery()
end

function RefineMasterAwardDialog:showAwards()
	self.isShow = true
	UiUtil.showAwards(self.ret)

	local function showTen()
		for index =1,#self.m_data do
			local itemView = UiUtil.createItemView(self.m_data[index].type,self.m_data[index].id,{count = self.m_data[index].count}):addTo(self.m_contentNode)
			local resData = UserMO.getResourceData(self.m_data[index].type,self.m_data[index].id)
			local name = ui.newTTFLabel({text = resData.name.."*"..self.m_data[index].count, font = G_FONT, size = 14, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_contentNode)
			itemView:setScale(0.8)

			if #self.m_data == 1 then
				itemView:setPosition(self:getBg():width() / 2,self:getBg():height() / 2)
				name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
			else
				if index <= 5 then
					itemView:setPosition((index - 1) * 110 + 80,self:getBg():height() - itemView:height() / 2 - 20)
					name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
				else
					itemView:setPosition((index - 6) * 110 + 80,self:getBg():height() / 2 - itemView:height() / 2 + 20)
					name:setPosition(itemView:x(),itemView:y() - itemView:height() / 2)
				end
			end

			local info = ActivityCenterMO.getConsumeById(self.tag)
			local propDB = json.decode(info.displaylist)
			for idx=1,#propDB do
				if (propDB[idx][1] == self.m_data[index].type) and (propDB[idx][2] == self.m_data[index].id) then
					local light = armature_create("clds_gaoji_tx", itemView:x(),itemView:y())
				    light:getAnimation():playWithIndex(0)
				    light:addTo(self.m_contentNode,-1)
				end
			end
		end
	end

	local function showHundreds()
		local view = MasterAwardTableView.new(cc.size(self.m_contentNode:getContentSize().width, self.m_contentNode:getContentSize().height - 60),self.m_data, self.tag):addTo(self.m_contentNode,-1)
		view:setPosition(0, 40)
		view:reloadData()
	end

	if self.type == 100 then
		showHundreds()
	else
		showTen()
	end
end

function RefineMasterAwardDialog:onExit()
	RefineMasterAwardDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.plist", IMAGE_ANIMATION .. "effect/cuilian_huode_guangxiao.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")
end
return RefineMasterAwardDialog