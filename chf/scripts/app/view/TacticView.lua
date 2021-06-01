--
-- Author: Gss
-- Date: 2018-12-19 16:50:03
--
-- 点击建筑进入战术中心界面  TacticView

local TacticView = class("TacticView", UiNode)

function TacticView:ctor(buildingId, viewFor)
	TacticView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_buildingId = buildingId
end

function TacticView:onEnter()
	TacticView.super.onEnter(self)
	self:setTitle("战术中心")
	self:showUI()
end

function TacticView:showUI()
	local topBg = display.newSprite("image/tactics/tactic_base_top.png"):addTo(self:getBg())
	topBg:setPosition(self:getBg():width() / 2, self:getBg():height() - topBg:height() / 2 - 100)
	local title = display.newSprite("image/tactics/tactic_title.png"):addTo(topBg)
	title:setPosition(topBg:width() / 2, topBg:height() - 50)

	--克制展示
	local restraint = display.newSprite("image/tactics/restraint.png")
	local restraintBtn = ScaleButton.new(restraint, function ()
		require("app.dialog.TacticsRestraintDialog").new():push()
	end):addTo(topBg)
	restraintBtn:setPosition(topBg:width() - 100, 100)
	restraintBtn:setScale(0.8)

	--描述
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
	local helpBtn = ScaleButton.new(normal, function ()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.tactic):push()
	end):addTo(topBg)
	helpBtn:setPosition(topBg:width() - 90, topBg:height() - 150)


	local y1 = topBg:height() - 110
	--克制关系
	local posList = {
		{x = topBg:width() / 2, y = y1 - 50},
		{x = topBg:width() / 4, y = y1 - 150},
		{x = topBg:width() / 2, y = y1 - 250},
		{x = topBg:width() / 4 * 3, y = y1 - 150},
	}


	local arrowPosList = {
		{x = topBg:width() / 2 - 70, y = y1 - 100, rotation = -10},
		{x = topBg:width() / 3 + 20, y = y1 - 200, rotation = 250},
		{x = topBg:width() / 2 + 80, y = y1 - 210, rotation = 170},
		{x = topBg:width() / 3 * 2 - 10, y = y1 - 110, rotation = 60},
	}

	for index=1,#posList do
		local attr = display.newSprite("image/tactics/tactics_"..index..".png"):addTo(topBg)
		attr:setPosition(posList[index].x,posList[index].y)

		local arrow = display.newSprite("image/tactics/tactics_arrow.png"):addTo(topBg)
		arrow:setPosition(arrowPosList[index].x, arrowPosList[index].y)
		arrow:setRotation(arrowPosList[index].rotation)

		local name = UiUtil.label(CommonText[4001][index]):alignTo(attr, -50, 1)
	end

	--进入按钮
	local bottom = display.newSprite("image/tactics/tactic_base_bottom.png"):addTo(self:getBg())
	bottom:setPosition(self:getBg():width() / 2, topBg:y() - topBg:height() / 2)
	bottom:setAnchorPoint(cc.p(0.5,1))

	--仓库
	local warehouse = display.newSprite("image/tactics/warehouse.png")
	local warehouseBtn = ScaleButton.new(warehouse, function ()
		UiDirector.push(require("app.view.TacticsWareHouseView").new(VIEW_FOR_SEE))
	end):addTo(bottom)
	warehouseBtn:setPosition(bottom:width() / 2 + 5, bottom:height() - 222)

end

function TacticView:onExit()
	TacticView.super.onExit(self)
	
end


return TacticView