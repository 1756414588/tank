
-- 选择关卡大类型章节
SECTION_VIEW_FOR_COMBAT  = 1 -- 征战
SECTION_VIEW_FOR_EXPLORE = 2 -- 探险
SECTION_VIEW_FOR_LIMIT   = 3 -- 限时
SECTION_VIEW_FOR_CHALLENGE = 4 --挑战

local SweepSectionView = class("SweepSectionView", UiNode)

function SweepSectionView:ctor()
	SweepSectionView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_viewFor = viewFor
	self.totalCoin = 0
end

function SweepSectionView:onEnter()
	SweepSectionView.super.onEnter(self)
	-- 探险扫荡
	self:setTitle(CommonText[1167][1])
	-- self:showSweep()
	local coinStr1 = string.format(CommonText[1168][7],"0")
	self.labelCoin = ui.newTTFLabel({text = coinStr1, font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 100, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	self.labelCoin:setAnchorPoint(cc.p(0, 0.5))
	

	local SweepSectionTableView = require("app.scroll.SweepSectionTableView")
	local view = SweepSectionTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height -262),self):addTo(self:getBg())
	view:setPosition(0, 160)
	view:reloadData()
	self:showSweep()

end

function SweepSectionView:showSweep()
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width-20, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2,162)

	--花费金币
	--local coinStr1 = string.format(CommonText[1168][7],"0")
	--self.labelCoin = ui.newTTFLabel({text = coinStr1, font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 100, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	--self.labelCoin:setAnchorPoint(cc.p(0, 0.5))

	--拥有金币
	local coinStr2 = string.format(CommonText[1168][8],UserMO.getResource(ITEM_KIND_COIN))
	local label2 = ui.newTTFLabel({text = coinStr2 , font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = 60, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label2:setAnchorPoint(cc.p(0, 0.5))

	--保存方案
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self,self.onSetCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width- 100, 80)
	btn:setLabel(CommonText[1168][9])
end

function SweepSectionView:setCallBack(callBack)
	self.combatCallback=callBack
end

function SweepSectionView:onCloseView()
	self.combatCallback(CombatMO.getUseCoin())
end

--设置扫荡信息
function SweepSectionView:onSetCallback(tag,sender)
	-- if table.nums(CombatMO.wipeSetInfo) == 0 and table.nums(CombatMO.myWipeInfo_)> 0 then
	-- 	CombatMO.wipeSetInfo = CombatMO.myWipeInfo_
	-- else
	-- 	local tempwipeSetInfo = {}
	-- 	for k,v in pairs(CombatMO.wipeSetInfo) do
	-- 		table.insert(tempwipeSetInfo,v)
	-- 	end
	-- 	local tempMywipe = {}
	-- 	for k,v in pairs(CombatMO.myWipeInfo_) do
	-- 		for m,n in pairs(tempwipeSetInfo) do
	-- 			if v.exploreType == n.exploreType then
	-- 				table.insert(tempMywipe,m)
	-- 			end
	-- 		end
	-- 	end

	-- 	for k,v in pairs(tempMywipe) do
	-- 		table.remove(tempwipeSetInfo,v)
	-- 	end

	-- 	for k,v in pairs(CombatMO.myWipeInfo_) do
	-- 		table.insert(tempwipeSetInfo,v)
	-- 	end
	
	-- 	CombatMO.wipeSetInfo = {}
	-- 	CombatMO.wipeSetInfo = tempwipeSetInfo
	-- end

	-- local tempInfo ={}
	-- for k,v in pairs(CombatMO.wipeSetInfo) do
	-- 	if CombatMO.getNeedNum(v.exploreType)<=0 then
	-- 		v = nil
	-- 		break
	-- 	else
	-- 		tempInfo[#tempInfo + 1] = v
	-- 	end
	-- end

	-- CombatMO.wipeSetInfo = tempInfo
	if table.nums(CombatMO.wipeSetInfo) == 0 then
		Toast.show(CommonText[1169])
		self:pop()
		return
	end

	CombatBO.asynSetWipeInfo(function ()
		Toast.show(CommonText[1169])
		self:pop()
	end,CombatMO.wipeSetInfo)
end

function SweepSectionView:upCoinNum(coinNum)
	self.totalCoin = coinNum
	local coinStr1 = string.format(CommonText[1168][7],coinNum)
	if self.labelCoin~= nil then
		self.labelCoin:setString(coinStr1)
	end
end

function SweepSectionView:onEnterEnd()
	SweepSectionView.super.onEnterEnd(self)

	--local function doneCallback()
		--Loading.getInstance():unshow()
		local SweepSectionTableView = require("app.scroll.SweepSectionTableView")
		local view = SweepSectionTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height -262),self):addTo(self:getBg())
		view:setPosition(0, 160)
		view:reloadData()
		self:showSweep()
	--end
	--Loading.getInstance():show()
	--CombatBO.asynGetWipeInfo(doneCallback)
end

function SweepSectionView:onExit()
	SweepSectionView.super.onExit(self)
	self:onCloseView()
end

return SweepSectionView