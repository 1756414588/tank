--
-- Author: Your Name
-- Date: 2017-05-26 11:04:26
--
--淬炼大师活动
--------------------------------奖励列表tableview--------------------------------------

local RefineAwardTableview = class("RefineAwardTableview", TableView)

function RefineAwardTableview:ctor(size)
	RefineAwardTableview.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 70)
	self:showSlider(true,nil,{bar = "image/common/scroll_head_4.png", bg = "image/common/scroll_bg_4.png"})
	self:showShade(false)
	local info = ActivityCenterMO.getConsumeById(1)
	self.propDB = json.decode(info.displaylist)
end

function RefineAwardTableview:onEnter()
	RefineAwardTableview.super.onEnter(self)
end

function RefineAwardTableview:numberOfCells()
	return #self.propDB
end

function RefineAwardTableview:cellSizeForIndex(index)
	return self.m_cellSize
end

function RefineAwardTableview:createCellAtIndex(cell, index)
	local awards = self.propDB
	local award = UiUtil.createItemView(awards[index][1],awards[index][2],{count = awards[index][3]}):addTo(cell)
	award:setPosition(award:width() / 2, self.m_cellSize.height / 2)
	award:setScale(0.6)
	UiUtil.createItemDetailButton(award)		
	local resData = UserMO.getResourceData(awards[index][1],awards[index][2])
	local desc = UiUtil.label(resData.name.."*"..awards[index][3],16,COLOR[resData.quality]):rightTo(award)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width - 20, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2,0)
	return cell
end

function RefineAwardTableview:onExit()
	RefineAwardTableview.super.onExit(self)
end

--------------------------------界面展示----------------------------------------------------
local ActivityRefineMasterView = class("ActivityRefineMasterView", UiNode)

function ActivityRefineMasterView:ctor(activity)
	ActivityRefineMasterView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity

end

function ActivityRefineMasterView:onEnter()
	ActivityRefineMasterView.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	self.m_activityHandler = Notify.register("ACTIVITY_NOTIFY_ACTIVITY_REFINEMASTER", handler(self, self.onUpdatePage))

	local function createDelegate(container, index)
		self.m_timeLab = nil
		self.index = index
		if index == 1 then  
			self:showTreasure(container)
		elseif index == 2 then 
			self:showRanking(container)
		end
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[1028][1],CommonText[1028][2]}

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	ActivityCenterBO.GetRefineMasterInfo(function()
		pageView:setPageIndex(1)
	end)
	self.m_pageView = pageView
end

--UI
function ActivityRefineMasterView:showTreasure(container)

	local list = PropMO.queryActProp(self.m_activity.activityId)
	self.list = list
	local count = ActivityCenterBO.prop_[list[1].id] and ActivityCenterBO.prop_[list[1].id].count or 0
	--当前拥有
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_new_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, container:getContentSize().height - 30)
	local kejin = display.newSprite(IMAGE_COMMON .. "prop_kejin.png"):addTo(bg):align(display.LEFT_CENTER,10,bg:height() / 2)
	kejin:setScale(0.6)
	local title = UiUtil.label(CommonText[507][1],nil,COLOR[1]):addTo(bg):align(display.LEFT_CENTER,40,bg:height() / 2)
	local own = UiUtil.label(count,nil,COLOR[3]):rightTo(title)

	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(container)
		chanceBtn:setPosition(container:width() / 2 + 50, container:height() - 30)
		chanceBtn:setVisible(chance.open == 1)
	end

	--去获取
	local normal = display.newSprite(IMAGE_COMMON .. "btn_go.png")
	normal:scaleX(-1)
	local btn = ScaleButton.new(normal,function ()
		ManagerSound.playNormalButtonSound()
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_COMPONENT) then
			Toast.show(CommonText[1029])
		elseif self.m_activity.open == true then
			Toast.show(CommonText[1033])
		else
			self:pop()
			require("app.view.ComponentView").new(nil, UI_ENTER_FADE_IN_GATE):push()
		end
	end):addTo(container):rightTo(bg,220)
	local kejin = display.newSprite(IMAGE_COMMON .. "prop_kejin.png"):addTo(btn):align(display.LEFT_CENTER,10,btn:height() / 2)
	kejin:setScale(0.6)
	UiUtil.label(CommonText[1027]):addTo(btn):align(display.LEFT_CENTER,40,btn:height() / 2)

	--活动描述
	local desc = ui.newTTFLabel({text = CommonText[1020],font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(560, 70)}):addTo(container):alignTo(bg,-66,1)
	--背景图
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_89.jpg"):addTo(container)
	infoBg:setPosition(container:width()/2,desc:y() - 50 - infoBg:height() / 2)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(infoBg)
	titleBg:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 8)
	local canget = ui.newTTFLabel({text = CommonText[278], font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y =titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_39_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_39_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.RefineMaster):push()
		end):addTo(infoBg)
	detailBtn:setPosition(detailBtn:width() / 2 + 10,infoBg:height() - detailBtn:height() / 2 - 10)
	local viewBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_88.png"):addTo(infoBg)
	viewBg:setPreferredSize(cc.size(270, infoBg:height() - 40))
	viewBg:setPosition(infoBg:width() - 290,10)
	viewBg:setAnchorPoint(cc.p(0,0))

	--奖励列表
	local view = RefineAwardTableview.new(cc.size(viewBg:width(), viewBg:height())):addTo(infoBg,0)
	view:setPosition(viewBg:getPosition())
	view:reloadData()
	--中奖信息
	local winBg = UiUtil.sprite9("info_bg_90.png", 80, 60, 1, 1, container:width()-40, 100)
	winBg:addTo(container):pos(container:width()/2,container:height()- 480 - winBg:height() / 2)
	local arrow = display.newSprite(IMAGE_COMMON.."icon_arrow_3.png"):addTo(winBg):pos(winBg:width() - 40,winBg:height() - 35)
	local arrow2 = display.newSprite(IMAGE_COMMON.."icon_arrow_3.png"):addTo(winBg):pos(winBg:width() - 40,35)
	arrow2:setScaleY(-1)
	local WinRefineAwardTableview = require("app.scroll.WinRefineAwardTableview")
	local view = WinRefineAwardTableview.new(cc.size(winBg:width() - 50,winBg:height() - 40)):addTo(container,0)
	view:setPosition(40,winBg:y() - winBg:height() / 2 + 20)
	view:reloadData()
	self:onViewOffset(view)
	self.winTablleview = view
	winBg:setTouchEnabled(true)
	winBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			self:showAnimation(cc.size(container:width(),container:height()), winBg:height())
			return true
		end
	end)
	--奖励箱子
	local award1 = display.newSprite(IMAGE_COMMON.."refine_master_1.png"):addTo(container):pos(container:width() / 6 + 10,155)
	self:showTips(CommonText[1031][1],award1)
	local award2 = display.newSprite(IMAGE_COMMON.."refine_master_10.png"):addTo(container):pos(container:width() / 6 * 2.9,award1:y())
	self:showTips(CommonText[1031][2],award2)
	local award3 = display.newSprite(IMAGE_COMMON.."refine_master_10.png"):addTo(container):pos(container:width() / 6 * 4.9,award1:y())
	self:showTips(CommonText[1031][3],award3)
	--消耗
	local consume1 = ActivityCenterMO.getConsumeById(1)
	local consume2 = ActivityCenterMO.getConsumeById(2)
	local consume3 = ActivityCenterMO.getConsumeById(3)
	local materiel1 = display.newSprite(IMAGE_COMMON .. "prop_kejin.png"):addTo(container)
	materiel1:setPosition(container:width() / 6,85)
	local consume = UiUtil.label(CommonText[1026],nil,COLOR[3]):rightTo(materiel1)
	local consumeNum = UiUtil.label(consume1.price,nil,COLOR[3]):rightTo(consume)
	local materiel2 = display.newSprite(IMAGE_COMMON .. "prop_kejin.png"):addTo(container)
	materiel2:setPosition(container:width() / 6 * 2.8,85)
	local consume = UiUtil.label(CommonText[1026],nil,COLOR[3]):rightTo(materiel2)
	local consumeNum = UiUtil.label(consume2.price,nil,COLOR[3]):rightTo(consume)
	local materiel3 = display.newSprite(IMAGE_COMMON .. "prop_kejin.png"):addTo(container)
	materiel3:setPosition(container:width() / 6 * 4.8,85)
	local consume = UiUtil.label(CommonText[1026],nil,COLOR[3]):rightTo(materiel3)
	local consumeNum = UiUtil.label(consume3.price,nil,COLOR[3]):rightTo(consume)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local lottery1Btn = MenuButton.new(normal, selected, disabled, handler(self,self.lotteryHandler)):addTo(container,0,1):pos(container:width() / 5,30)
	lottery1Btn:setLabel(CommonText[1024][1])
	lottery1Btn.type = 1
	lottery1Btn:setEnabled(not self.m_activity.open)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local lottery10Btn = MenuButton.new(normal, selected, disabled, handler(self,self.lotteryHandler)):addTo(container,0,2):pos(container:width() / 5 * 2.5,30)
	lottery10Btn:setLabel(CommonText[1024][2])
	lottery10Btn.type = 10
	lottery10Btn:setEnabled(not self.m_activity.open)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local lottery100Btn = MenuButton.new(normal, selected, disabled, handler(self,self.lotteryHandler)):addTo(container,0,2):pos(container:width() / 5 * 4,30)
	lottery100Btn:setLabel(CommonText[1024][3])
	lottery100Btn.type = 100
	lottery100Btn:setEnabled(not self.m_activity.open)
end

--消耗氪金开启宝箱
function ActivityRefineMasterView:lotteryHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	self.type = sender.type
	local cost = ActivityCenterMO.getConsumeById(tag)
	function doLottery()
		if cost.price > UserMO.getResource(ITEM_KIND_CHAR,17) then
			Toast.show(CommonText[1025])
			return
		end
		ActivityCenterBO.RefineMasterLottery(function(data)
				Loading.getInstance():unshow()
				self.m_pageView:setPageIndex(1)
				require("app.dialog.RefineMasterAwardDialog").new(data,self.type,function ()
				end):push()
			end, sender.type)
	end
	doLottery()
end

function ActivityRefineMasterView:refreshUI(name)
	if name == "ComponentView" then
		self.m_pageView:setPageIndex(1)
	end
end

function ActivityRefineMasterView:onUpdatePage()
	self.m_pageView:setPageIndex(1)
end

--播放获奖框变大动画
function ActivityRefineMasterView:showAnimation(size,height)
	require("app.dialog.RefineWinDialog").new(size,height):push()
end

--排行
function ActivityRefineMasterView:showRanking(container)
	container:removeAllChildren()
	ActivityCenterBO.GetActSmeltPartMasterRank(function (data)
		local RefineMasterRank = require("app.view.RefineMasterRank")
		self.view = RefineMasterRank.new(self.m_activity,data,container:width(), container:height()):addTo(container)
		self.view:setPosition(0, 0)
	end)
end

function ActivityRefineMasterView:onViewOffset(tableView, offset)
	local maxOffset = tableView:maxContainerOffset()
	local minOffset = tableView:minContainerOffset()
	if minOffset.y > maxOffset.y or not offset then
	    local y = math.max(maxOffset.y, minOffset.y)
	    tableView:setContentOffset(cc.p(0, y))
    elseif offset then
	    tableView:setContentOffset(offset)
    end
end

function ActivityRefineMasterView:showTips(str,node)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			local des = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_6.png")
			local label = UiUtil.label(str,nil,nil,cc.size(200,0),ui.TEXT_ALIGN_LEFT)
			des:setPreferredSize(cc.size(220,label:height() + 10))
			label:addTo(des):align(display.LEFT_TOP, 10, des:height() - 5)
			des:alignTo(node, node:height()*node:getScaleY() + 25, 1)
			if des:x() + des:width()/2 > des:getParent():width() then
				des:x(des:getParent():width() - des:width()/2 - 5)
			elseif des:x() - des:width()/2 < 0 then
				des:x(des:width()/2)
			end
			node.tipNode_ = des
			return true
		elseif event.name == "ended" then
			node.tipNode_:removeSelf()
		end
	end)
end

function ActivityRefineMasterView:onExit()
	ActivityRefineMasterView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

return ActivityRefineMasterView