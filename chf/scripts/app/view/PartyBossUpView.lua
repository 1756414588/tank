--
-- Author: Gss
-- Date: 2018-11-22 14:05:22
--
--军团BOSS升级捐献  PartyBossUpView

local PartyBossUpView = class("PartyBossUpView", UiNode)

function PartyBossUpView:ctor()
	PartyBossUpView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function PartyBossUpView:onEnter()
	PartyBossUpView.super.onEnter(self)
	self:setTitle(CommonText[2603])
	self:showUI()
end

function PartyBossUpView:showUI()
	local topBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	topBg:setPreferredSize(cc.size(self:getBg():width() - 40, 120))
	topBg:setPosition(self:getBg():width() / 2, self:getBg():height() - topBg:height() / 2 - 110)
	local item = display.newSprite("image/item/boss_star.jpg"):addTo(topBg)
	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(item):center()
	item:setPosition(item:width() / 2 + 20, topBg:height() / 2)

	--星级
	local starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
	local nexlv = starLv + 1
	local maxStar = PartyMO.getPartyBossMaxStarInfo().star
	if nexlv >= maxStar then
		nexlv = maxStar
	end
	local nexStar = PartyMO.getStarInfoByStar(nexlv)
	local star = UiUtil.label(CommonText[2601][2]):addTo(topBg)
	star:setAnchorPoint(cc.p(0,0.5))
	star:setPosition(item:x() + item:width() / 2 + 20, topBg:height() - 30)
	local value = UiUtil.label(starLv):rightTo(star)
	self.m_value = value

	--经验
	local exp = UiUtil.label(CommonText[2601][3]):alignTo(star, -50, 1)
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(topBg:width() - 280, 35), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(topBg:width() - 280 + 4, 20)}):rightTo(exp)
	bar:setPercent(PartyMO.partyData_.altarexp / nexStar.exp)
	bar:setLabel(PartyMO.partyData_.altarexp.."/"..nexStar.exp)
	if PartyMO.partyData_.altarexp >= nexStar.exp then
		bar:setLabel("Max")
	end
	self.m_bar = bar

	--捐献
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(self:getBg())
	titleBg:setAnchorPoint(cc.p(0,0.5))
	titleBg:setPosition(35,topBg:y() - topBg:height() / 2 - 30)
	local donate = UiUtil.label(CommonText[583]):addTo(titleBg)
	donate:setPosition(70,titleBg:height() / 2)
	local contributBg = UiUtil.sprite9("info_bg_9.png", 80,60,1,1,self:getBg():width() - 40,500):addTo(self:getBg())
	contributBg:setPosition(self:getBg():width() / 2,titleBg:y() - titleBg:height() / 2 - contributBg:height() / 2)
	self.m_contributBg = contributBg
	self:showDonateUI()

	--一键捐献
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local payBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onDonateAlldHandler)):addTo(self:getBg())
	payBtn:setLabel(CommonText[1152])
	payBtn:setPosition(self:getBg():getContentSize().width / 2 , 70)
	payBtn:setEnabled(PartyMO.partyData_.altarexp < nexStar.exp)
	self.m_payBtn = payBtn
end

function PartyBossUpView:showDonateUI()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self.m_contributBg)
	container:setContentSize(self.m_contributBg:getContentSize())
	self.m_contentNode = container

	local posX = {45, 130, 230, 350, 430, 520}
	for index=1,#CommonText[2600] do
		local labTit = ui.newTTFLabel({text = CommonText[2600][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = self.m_contributBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		labTit:setAnchorPoint(cc.p(0, 0.5))
	end

	for num=1,RESOURCE_ID_STONE do
		local partyContribute = PartyMO.queryPartyBossContribute(num,PartyMO.partyBossData_[num])

		local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(container)
		line:setPreferredSize(cc.size(container:width() - 40, line:getContentSize().height))
		line:setPosition(container:width() / 2, container:height() - (num - 1) - num * 90 - 30)

		local itemView = UiUtil.createItemView(ITEM_KIND_RESOURCE,num):addTo(container)
		itemView:setScale(0.6)
		itemView:setPosition(posX[1] + 20, line:y() + 37)

		local need = partyContribute.price
		-- if ActivityBO.isValid(ACTIVITY_ID_PARTY_DONATE) then
		-- 	need = need * ACTIVITY_PARTY_DONATE_COIN_RATE
		-- end
		local needLab = UiUtil.label(UiUtil.strNumSimplify(need)):addTo(container)
		needLab:setPosition(posX[2] + 20,itemView:y())
		local count = UserMO.getResource(ITEM_KIND_RESOURCE,num)
		local own = UiUtil.label(UiUtil.strNumSimplify(count)):addTo(container)
		own:setPosition(posX[3] + 40,itemView:y())
		local addExp = UiUtil.label("+"..partyContribute.exp):addTo(container)
		addExp:setPosition(posX[4] + 20,itemView:y())

		local ctt = partyContribute.contribute
		if ActivityBO.isValid(ACTIVITY_ID_PARTY_DONATE) then
			ctt = math.ceil(ctt * ACTIVITY_ID_PARTY_DONATE_RATE)
		end
		local contribute = UiUtil.label("+"..ctt):addTo(container)
		contribute:setPosition(posX[5] + 20,itemView:y())

		local maxExp = PartyMO.getPartyBossMaxStarInfo().exp
		local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
		local donateBtn = MenuButton.new(normal, selected, disabled, handler(self,self.donateHandler)):addTo(container)
		donateBtn:setPosition(posX[6] + 20,itemView:y())
		donateBtn:setScale(0.8)
		donateBtn.resourcesId = num
		donateBtn:setEnabled(PartyMO.partyBossData_[num] < PartyMO.queryPartyBossContributeMaxCount(num)
			and partyContribute and need <= count)

		if PartyMO.partyBossData_[num] == PartyMO.queryPartyBossContributeMaxCount(num) then
			needLab:setString("-")
			contribute:setString("-")
		else
			if partyContribute.price <= count then -- 足够
				local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png"):rightTo(needLab)
				tag:setScale(0.5)
				needLab:setColor(COLOR[11])
			else -- 不足够
				local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png"):rightTo(needLab)
				tag:setScale(0.5)
				needLab:setColor(COLOR[6])
			end

			if PartyMO.partyData_.altarexp >= maxExp then
				donateBtn:setEnabled(false)
			end
		end
	end
end

function PartyBossUpView:donateHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	if self.donateStatus == true then return end
	self.donateStatus = true

	local list = {sender.resourcesId}
	PartyBO.asynDonatePartyBoss(function (data)
		self.donateStatus = false
		Toast.show(string.format(CommonText[584][2],data.contribute))
		self:showDonateUI()
		local starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
		local nexlv = starLv + 1
		local maxStar = PartyMO.getPartyBossMaxStarInfo().star
		if nexlv >= maxStar then
			nexlv = maxStar
		end
		local nexStar = PartyMO.getStarInfoByStar(nexlv)

		self.m_value:setString(starLv)
		self.m_bar:setLabel(PartyMO.partyData_.altarexp.."/"..nexStar.exp)
		if PartyMO.partyData_.altarexp >= nexStar.exp then
			self.m_bar:setLabel("Max")
			self.m_payBtn:setEnabled(false)
		end
		self.m_bar:setPercent(PartyMO.partyData_.altarexp / nexStar.exp)
	end,list)
end

function PartyBossUpView:onDonateAlldHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local maxExp = PartyMO.getPartyBossMaxStarInfo().exp
	local resTab = CommonText[1153]
	local text = ""
	local canDonate = 0
	local costList = {}
	local totalExp = 0
	for index=1,PARTY_CONTRIBUTE_TYPE_STONE do
		local partyContribute = PartyMO.queryPartyBossContribute(index,PartyMO.partyBossData_[index])

		local own = UserMO.getResource(ITEM_KIND_RESOURCE,index)
		if PartyMO.partyBossData_[index] == PartyMO.queryPartyBossContributeMaxCount(index) or own < partyContribute.price or partyContribute == nil then
			canDonate = canDonate + 1
		else
			costList[#costList + 1] = index
			totalExp = totalExp + partyContribute.exp
			local cost = (UiUtil.strNumSimplify(partyContribute.price))
			text = text .. resTab[index]..cost .. "、"
		end
	end
	local desc = CommonText[1155][1] .. text .. CommonText[1155][2]


	local function donate()
		PartyBO.asynDonatePartyBoss(function (data)
			Toast.show(string.format(CommonText[584][2],data.contribute))
			self:showDonateUI()

			local starLv = PartyMO.getBossStarByExp(PartyMO.partyData_.altarexp)
			local nexlv = starLv + 1
			local maxStar = PartyMO.getPartyBossMaxStarInfo().star
			if nexlv >= maxStar then
				nexlv = maxStar
			end
			local nexStar = PartyMO.getStarInfoByStar(nexlv)

			self.m_value:setString(starLv)
			self.m_bar:setLabel(PartyMO.partyData_.altarexp.."/"..nexStar.exp)
			if PartyMO.partyData_.altarexp >= nexStar.exp then
				self.m_bar:setLabel("Max")
				self.m_payBtn:setEnabled(false)
			end
			self.m_bar:setPercent(PartyMO.partyData_.altarexp / nexStar.exp)
		end,costList)
	end

	local now = PartyMO.partyData_.altarexp + totalExp
	if canDonate < 5 then
		require("app.dialog.TipsAnyThingDialog").new(desc,function ()
			if now > maxExp then
				require("app.dialog.TipsAnyThingDialog").new(CommonText[2604],function ()
					donate()
				end):push()
			else
				donate()
			end
		end):push()
	else
		Toast.show(CommonText[1154])
	end
end

return PartyBossUpView