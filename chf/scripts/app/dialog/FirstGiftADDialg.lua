--
-- Author: 龚帆
-- Date: 2017-05-26 15:37:15
--
local Dialog = require("app.dialog.Dialog")
local FirstGiftADDialg = class("FirstGiftADDialg", Dialog)

function FirstGiftADDialg:ctor()
	FirstGiftADDialg.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(632, 450)})
end

function FirstGiftADDialg:onEnter()
	FirstGiftADDialg.super.onEnter(self)
	self:setTitle(CommonText.MuzhiAD[3][2])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(602, 420))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	self:setOutOfBgClose(true)
	self:showUI()
end

function FirstGiftADDialg:showUI()
	self:getBg():setPositionY(display.cy + 50)
	

	local node = display.newNode():addTo(self:getBg())
	node:setContentSize(self:getBg():getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)
	self.m_container = node


	--奖励内容
	local awardDB = json.decode(ActivityMO.queryActivityAwardsById(FIRST_RECHARGE_ACTIVITY_ID).awardList)

	local posParam = {
		{x = 100, y = 290, offsetY = 75, offsetY1 = 60},
		{x = 250, y = 290, offsetY = 75, offsetY1 = 60},
		{x = 400, y = 290, offsetY = 75, offsetY1 = 60},
		{x = 550, y = 290, offsetY = 75, offsetY1 = 60}
	}
	for index=1,#awardDB do
		local itemView = UiUtil.createItemView(awardDB[index][1], awardDB[index][2], {count = awardDB[index][3]})
		itemView:setPosition(posParam[index].x,posParam[index].y)
		itemView:setScale(0.9)
		self.m_container:addChild(itemView)

		UiUtil.createItemDetailButton(itemView)

		local propDB = UserMO.getResourceData(awardDB[index][1], awardDB[index][2])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 4, 
			x = itemView:getPositionX(), y = itemView:getPositionY() + posParam[index].offsetY, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_container)
		
		local info = ui.newTTFLabel({text = CommonText[895][index], font = G_FONT, size = FONT_SIZE_SMALL - 4, 
			x = itemView:getPositionX(), y = itemView:getPositionY() - posParam[index].offsetY1, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_container)
	end


	local adLab = ui.newTTFLabel({text = string.format(CommonText.MuzhiAD[3][3],MZAD_FIRSTGIFT_TIME,MZAD_FIRSTGIFT_DAY), font = G_FONT, size = 20, 
		x = self.m_container:getContentSize().width / 2, y = 180, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_container)
	adLab:setAnchorPoint(cc.p(0.5, 0.5))

	local adLab1 = ui.newTTFLabel({text = "", font = G_FONT, size = 20, 
		x = self.m_container:getContentSize().width / 2, y = 150, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_container)
	adLab:setAnchorPoint(cc.p(0.5, 0.5))
	adLab1:setString(string.format(CommonText.MuzhiAD[3][4],MuzhiADMO.FirstGiftADTime,MZAD_FIRSTGIFT_DAY - MuzhiADMO.FirstGiftADDay))
	self.adLab1 = adLab1

	-- 去观看
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local adbtn = MenuButton.new(normal, selected, nil, handler(self, self.playAD)):addTo(self.m_container)
	adbtn:setPosition(self.m_container:getContentSize().width / 2 , 30)
	adbtn:setLabel(CommonText.MuzhiAD[1][2])
	adbtn.m_label:setPositionX(adbtn.m_label:getPositionX() + 20)
	self.adbtn = adbtn
	display.newSprite(IMAGE_COMMON.."free.png"):addTo(adbtn):pos(45,58)
	display.newSprite(IMAGE_COMMON.."playAD.png"):addTo(adbtn):pos(75,50)

	-- 领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local awardBtn = MenuButton.new(normal, selected, nil, handler(self, self.awardFirstGift)):addTo(self.m_container)
	awardBtn:setPosition(self.m_container:getContentSize().width / 2 , 30)
	awardBtn:setLabel(CommonText.MuzhiAD[3][2])
	self.awardBtn = awardBtn


	--进度条
	--总进度
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_5.png", BAR_DIRECTION_HORIZONTAL, cc.size(545, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", 
		bgScale9Size = cc.size(545 + 4, 26)}):addTo(self.m_container)
	bar:setPosition(self.m_container:getContentSize().width / 2, 100)
	self.bar = bar

	for index=1, MZAD_FIRSTGIFT_DAY do
		local dayIcon = display.newSprite(IMAGE_COMMON .. "icon_red_point.png"):addTo(self.m_container)
		dayIcon:setPosition(45 + 545 * (index / MZAD_FIRSTGIFT_DAY),100)

		local dayText = ui.newTTFLabel({text = index * MZAD_FIRSTGIFT_TIME, font = G_FONT, size = 16, 
		x = dayIcon:getContentSize().width / 2, y = dayIcon:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(dayIcon)
	end

	self:updateUI()

end

function FirstGiftADDialg:updateUI()
	self.adLab1:setString(string.format(CommonText.MuzhiAD[3][4],MuzhiADMO.FirstGiftADTime,MZAD_FIRSTGIFT_DAY - MuzhiADMO.FirstGiftADDay))
	self.adbtn:setVisible(MuzhiADMO.FirstGiftADTime < MZAD_FIRSTGIFT_TIME)


	self.awardBtn:setVisible(MuzhiADMO.FirstGiftADDay == MZAD_FIRSTGIFT_DAY and MuzhiADMO.FirstGiftADTime == MZAD_FIRSTGIFT_TIME)

	-- print((MuzhiADMO.FirstGiftADDay * MZAD_FIRSTGIFT_DAY + MuzhiADMO.FirstGiftADTime),(MZAD_FIRSTGIFT_DAY * MZAD_FIRSTGIFT_TIME))
	local currentDay
	if MuzhiADMO.FirstGiftADTime == MZAD_FIRSTGIFT_TIME then
		currentDay = MuzhiADMO.FirstGiftADDay - 1
	else
		currentDay = MuzhiADMO.FirstGiftADDay
	end
	self.bar:setPercent((currentDay * MZAD_FIRSTGIFT_TIME + MuzhiADMO.FirstGiftADTime) / (MZAD_FIRSTGIFT_DAY * MZAD_FIRSTGIFT_TIME))
end


function FirstGiftADDialg:playAD()

	ServiceBO.playMzAD(MZAD_TYPE_VIDEO,function()
		Loading.getInstance():show()
		MuzhiADBO.PlayFirstGiftAD(function()
			Loading.getInstance():unshow()
			self:updateUI()
			end)
		end)
end

function FirstGiftADDialg:awardFirstGift()
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MuzhiADBO.AwardFirstGiftAD(function()
		Loading.getInstance():unshow()
		UiDirector.clear()
		
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[759], function()
			require("app.view.MailView").new(4):push()
		end):push()
		end)
end



return FirstGiftADDialg