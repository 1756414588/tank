
-- 能晶 镶嵌 Dialog

local Dialog = require("app.dialog.Dialog")
local EnergyInsetDialog = class("EnergyInsetDialog", Dialog)

function EnergyInsetDialog:ctor(pos, index, holeType, subType)
	EnergyInsetDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, GAME_SIZE_HEIGHT - 200)})
	self.m_holePos = pos ---孔位置
	self.m_holeIndex = index ---孔索引
	self.m_holeType = holeType ---孔类型
	self.subType = subType --同类已镶嵌
end

function EnergyInsetDialog:onEnter()
	EnergyInsetDialog.super.onEnter(self)

	self:setTitle(CommonText[942]) -- 碎片查看


	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	local energspars = EnergySparMO.getAllEnergySpars(self.m_holeType,self.subType)

	local EnergyInsetTableView = require("app.scroll.EnergyInsetTableView")

	local size = cc.size(self:getBg():getContentSize().width - 60, self:getBg():getContentSize().height - 120)
	local view = EnergyInsetTableView.new(size, energspars):addTo(self:getBg())
	view:setPosition(30, 50)

	view:addEventListener("INSET_ENERGYSPAR", handler(self, self.onInsetEnergySpar))

	view:reloadData()

	if #energspars <= 0 then
		local label = ui.newTTFLabel({text = "获取能晶", font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = self:getBg():getContentSize().width/2, y = self:getBg():getContentSize().height/2 + 50, 
			color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local combineBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onDepartureTo)):addTo(self:getBg())
		combineBtn:setPosition(label:getPositionX(), label:getPositionY() - label:getContentSize().height / 2 - combineBtn:getContentSize().height / 2)
		-- combineBtn:center()
		combineBtn:setLabel(CommonText[676][2] .. CommonText[4])
	end
end

function EnergyInsetDialog:onDepartureTo( event )
	self:pop()
	-- require("app.view.CombatSectionView").new(SECTION_VIEW_FOR_EXPLORE):push()
	local CombatLevelView = require("app.view.CombatLevelView")
	CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_ENERGYSPAR)):push()
end

function EnergyInsetDialog:onInsetEnergySpar( event )
	local stoneId = event.stoneId
	local function doneCallback( ... )
		Loading.getInstance():unshow()
		self:pop()
		Toast.show(CommonText[950][1])
	end

	Loading.getInstance():show()
	EnergySparBO.doEnergyStoneInlay(doneCallback, self.m_holePos, self.m_holeIndex, stoneId)
end

return EnergyInsetDialog