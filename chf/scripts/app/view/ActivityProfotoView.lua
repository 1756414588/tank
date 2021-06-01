--
-- Author: gf
-- Date: 2015-12-11 12:22:08
-- 哈洛克宝藏


local ConfirmDialog = require("app.dialog.ConfirmDialog")
local ActivityProfotoView = class("ActivityProfotoView", UiNode)

function ActivityProfotoView:ctor(activity)
	ActivityProfotoView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_activity = activity
	-- gdump(self.m_mail, "ActivityProfotoView:ctor")
end

function ActivityProfotoView:onEnter()
	ActivityProfotoView.super.onEnter(self)
	self:hasCoinButton(true)
	
	self:setTitle(self.m_activity.name)

	Loading.getInstance():show()
	ActivityCenterBO.asynGetActivityContent(function()
		Loading.getInstance():unshow()
		self:setUI()
		end, self.m_activity.activityId)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function ActivityProfotoView:setUI()

	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self:getBg():getContentSize().height - 130)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(self:getBg())
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 20)
	self.m_timeLab = timeLab

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityProfoto):push()
		end):addTo(self:getBg())
	detailBtn:setPosition(self:getBg():getContentSize().width - 70, self:getBg():getContentSize().height - 150)


	--背景图
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_Fortune.jpg'):addTo(self:getBg())
	bg:setPosition(self:getBg():getContentSize().width / 2, timeLab:getPositionY() - bg:getContentSize().height / 2 - 20)

	self.m_bg = bg

	local desc1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(530, 60)}):addTo(bg)
	desc1:setPosition(40, bg:getContentSize().height - 20)
	desc1:setAnchorPoint(cc.p(0, 1))
	desc1:setString(CommonText[783])


	self:updatePartUI()
	
	--小贴士
	local lab = ui.newTTFLabel({text = CommonText[785], font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[2], align = ui.TEXT_ALIGN_CENTER,
		x = bg:getContentSize().width / 2, y = 110}):addTo(bg)
	lab:setAnchorPoint(cc.p(0.5, 0.5))


	--宝藏
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, PROFOTO_PROP_PROFOTO_ID):addTo(bg)
	itemView:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView)

	-- armature_add("animation/effect/ui_item_light_orange.pvr.ccz", "animation/effect/ui_item_light_orange.plist", "animation/effect/ui_item_light_orange.xml")
	-- local armature = armature_create("ui_item_light_orange", itemView:getContentSize().width / 2 + 6, itemView:getContentSize().height / 2):addTo(itemView, 10)
	-- armature:getAnimation():playWithIndex(0)
	-- armature:setScale(0.76)

	--采集按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local gatherBtn = MenuButton.new(normal, selected, nil, handler(self,self.gatherHandler)):addTo(bg)
	gatherBtn:setPosition(bg:getContentSize().width / 2 - 150, 40)
	gatherBtn:setLabel(CommonText[784][1])

	--合成按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local composeBtn = MenuButton.new(normal, selected, nil, handler(self,self.composeHandler)):addTo(self:getBg())
	composeBtn:setPosition(bg:getContentSize().width / 2 + 150, 40)
	composeBtn:setLabel(CommonText[784][2])
	
	

	--信物
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, PROFOTO_PROP_TRUST_ID, {count = activityContent.trust.count}):addTo(self:getBg())
	itemView:setPosition(110,self:getBg():getContentSize().height - 680)
	UiUtil.createItemDetailButton(itemView)

	local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROFOTO_PROP_TRUST_ID)
	local propDB = PropMO.queryPropById(PROFOTO_PROP_TRUST_ID)

	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = itemView:getPositionX() + itemView:getContentSize().width / 2 + 10, y = itemView:getPositionY() + 25, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	if propDB.desc then
		local desc = ui.newTTFLabel({text = propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, 
			 color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP, dimensions = cc.size(430, 70)}):addTo(self:getBg())
		desc:setAnchorPoint(cc.p(0, 1))
		desc:setPosition(itemView:getPositionX() + itemView:getContentSize().width / 2 + 10, itemView:getPositionY() + 5)
	end
end

function ActivityProfotoView:updatePartUI()
	if self.chipNode then self.m_bg:removeChild(self.chipNode, true) end

	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
	--碎片
	local posList = {
		{x = self.m_bg:getContentSize().width / 2 - 185, y = self.m_bg:getContentSize().height / 2 + 110},
		{x = self.m_bg:getContentSize().width / 2 + 185, y = self.m_bg:getContentSize().height / 2 + 110},
		{x = self.m_bg:getContentSize().width / 2 - 185, y = self.m_bg:getContentSize().height / 2 - 110},
		{x = self.m_bg:getContentSize().width / 2 + 185, y = self.m_bg:getContentSize().height / 2 - 110}
	}
	local lineList = {
		{x = 237, y = 398},
		{x = 375, y = 398},
		{x = 237, y = 213},
		{x = 375, y = 213}
	}

	local chipNode = display.newNode():addTo(self.m_bg)
	self.chipNode = chipNode
	for index=1,#activityContent.parts do
		local part = activityContent.parts[index]
		local itemBg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png"):addTo(chipNode)
		itemBg:setScale(0.65)
		itemBg:setPosition(posList[index].x, posList[index].y - 2)

		local itemView = UiUtil.createItemView(ITEM_KIND_PROP, part.propId,{count = part.count,need = 1,noSuffix = true}):addTo(chipNode)
		itemView:setPosition(posList[index].x, posList[index].y)
		UiUtil.createItemDetailButton(itemView)
		local pic = display.newSprite(IMAGE_COMMON .. "profoto.png"):addTo(chipNode)
		if index == 2 then
			pic:setScaleX(-1)
		elseif index == 3 then
			pic:setScaleY(-1)
		elseif index == 4 then
			pic:setScale(-1)
		end
		pic:setPosition(lineList[index].x,lineList[index].y)
	end
end

function ActivityProfotoView:composeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	--判断碎片数量
	if not ActivityCenterBO.profotoCanCompose(self.m_activity.activityId) then
		Toast.show(CommonText[786])
		return
	end
	
	Loading.getInstance():show()
		ActivityCenterBO.asynDoActProfoto(function()
			Loading.getInstance():unshow()
			self:updatePartUI()
			end,self.m_activity.activityId)
end

function ActivityProfotoView:gatherHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	UiDirector.popMakeUiTop("HomeView")
	UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
end

function ActivityProfotoView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end


function ActivityProfotoView:onExit()
	ActivityProfotoView.super.onExit(self)
end




return ActivityProfotoView

