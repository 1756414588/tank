--
-- Author: gf
-- Date: 2015-09-17 19:08:49
-- 军团申请列表

--------------------------------------------------------------------
-- 军团申请列表tableview
--------------------------------------------------------------------

local PartyApplyTableView = class("PartyApplyTableView", TableView)

function PartyApplyTableView:ctor(size)
	PartyApplyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 180)
end

function PartyApplyTableView:onEnter()
	PartyApplyTableView.super.onEnter(self)
	self.m_UpgradeHandler = Notify.register(LOCAL_PARTY_APPLY_UPDATE_EVENT, handler(self, self.onUpgradeUpdate))
end

function PartyApplyTableView:numberOfCells()
	return #PartyMO.partyApplyList
end

function PartyApplyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PartyApplyTableView:createCellAtIndex(cell, index)
	PartyApplyTableView.super.createCellAtIndex(self, cell, index)

	local partyApply = PartyMO.partyApplyList[index]

	-- 背景框
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	infoBg:setPreferredSize(cc.size(self.m_cellSize.width - 30, 170))
	infoBg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	-- 头像
	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, partyApply.icon):addTo(infoBg)
	itemView:setScale(0.45)
	itemView:setPosition(70, infoBg:getContentSize().height - 55)

	-- 名称
	local name = ui.newTTFLabel({text = partyApply.nick, font = G_FONT, size = FONT_SIZE_SMALL,  x = 130, y = infoBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	name:setAnchorPoint(cc.p(0, 0.5))


	-- 等级
	local levelLab = ui.newTTFLabel({text = CommonText[544][1], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	levelLab:setAnchorPoint(cc.p(0, 0.5))
	local levelValue = ui.newTTFLabel({text = partyApply.level, font = G_FONT, size = FONT_SIZE_SMALL, x = levelLab:getPositionX() + levelLab:getContentSize().width, y = levelLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
	levelValue:setAnchorPoint(cc.p(0, 0.5))

	-- 战力
	local powerLab = ui.newTTFLabel({text = CommonText[544][2], font = G_FONT, size = FONT_SIZE_SMALL, x = levelLab:getPositionX(), y = levelLab:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	powerLab:setAnchorPoint(cc.p(0, 0.5))
	local powerValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(partyApply.fight), font = G_FONT, size = FONT_SIZE_SMALL, x = powerLab:getPositionX() + powerLab:getContentSize().width, y = powerLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
	powerValue:setAnchorPoint(cc.p(0, 0.5))


	-- 忽略按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local noBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.judgeHandler))
	noBtn:setLabel(CommonText[637][1])
	noBtn.partyApply = partyApply
	noBtn.judge = 2
	cell:addButton(noBtn, self.m_cellSize.width / 2 - 100, self.m_cellSize.height / 2 - 45)

	-- 同意按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local yesBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.judgeHandler))
	yesBtn:setLabel(CommonText[637][2])
	yesBtn.partyApply = partyApply
	yesBtn.judge = 1
	cell:addButton(yesBtn, self.m_cellSize.width / 2 + 100, self.m_cellSize.height / 2 - 45)

	return cell
end

function PartyApplyTableView:judgeHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynPartyApplyJudge(function()
		Loading.getInstance():unshow()
		end,sender.partyApply.lordId,sender.judge)
end



function PartyApplyTableView:onUpgradeUpdate()
	self:reloadData()
end

function PartyApplyTableView:onExit()
	PartyApplyTableView.super.onExit(self)
	
	if self.m_UpgradeHandler then
		Notify.unregister(self.m_UpgradeHandler)
		self.m_UpgradeHandler = nil
	end
end

--------------------------------------------------------------------
-- 军团科技view
--------------------------------------------------------------------

local ConfirmDialog = require("app.dialog.ConfirmDialog")
local Dialog = require("app.dialog.Dialog")
local PartyApplyJudgeDialog = class("PartyApplyJudgeDialog", Dialog)

function PartyApplyJudgeDialog:ctor()
	PartyApplyJudgeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function PartyApplyJudgeDialog:onEnter()
	PartyApplyJudgeDialog.super.onEnter(self)

	self.m_updateApplyCountHandler = Notify.register(LOCAL_PARTY_APPLY_UPDATE_EVENT, handler(self, self.updateApplyCountHandler))

	self:setTitle(CommonText[622][8])

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	
	local titLab = ui.newTTFLabel({text = CommonText[635], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = btm:getContentSize().height - 50, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	titLab:setAnchorPoint(cc.p(0, 0.5))

	local titValue = ui.newTTFLabel({text = #PartyMO.partyApplyList .. "/" .. PARTY_MEMBER_MAX_COUNT, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titLab:getPositionX() + titLab:getContentSize().width, y = titLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	titValue:setAnchorPoint(cc.p(0, 0.5))
	self.titValue = titValue
	

	--列表
	local view = PartyApplyTableView.new(cc.size(btm:getContentSize().width, btm:getContentSize().height - 125)):addTo(btm)
	view:setPosition(0, 50)
	view:reloadData()

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local clearBtn = MenuButton.new(normal, selected, disabled, handler(self,self.clearHandler)):addTo(self:getBg())
	clearBtn:setPosition(self:getBg():getContentSize().width / 2,20)
	clearBtn:setLabel(CommonText[636])
	clearBtn:setEnabled(#PartyMO.partyApplyList > 0)
	self.clearBtn = clearBtn
end

function PartyApplyJudgeDialog:clearHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	ConfirmDialog.new(CommonText[641], function()
			Loading.getInstance():show()
			PartyBO.asynPartyApplyJudge(function()
				Loading.getInstance():unshow()
				end,nil,3)

		end):push()
end

function PartyApplyJudgeDialog:updateApplyCountHandler()
	self.clearBtn:setEnabled(#PartyMO.partyApplyList > 0)
	self.titValue:setString(#PartyMO.partyApplyList .. "/" .. PARTY_MEMBER_MAX_COUNT)
end

function PartyApplyJudgeDialog:onExit()
	PartyApplyJudgeDialog.super.onExit(self)
	if self.m_updateApplyCountHandler then
		Notify.unregister(self.m_updateApplyCountHandler)
		self.m_updateApplyCountHandler = nil
	end
end


return PartyApplyJudgeDialog