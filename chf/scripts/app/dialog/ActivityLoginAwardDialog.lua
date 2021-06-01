--
-- Author: Gss
-- Date: 2018-08-13 17:47:32
-- 登录奖励


local Dialog = require("app.dialog.Dialog")
local ActivityLoginAwardDialog = class("ActivityLoginAwardDialog", Dialog)

function ActivityLoginAwardDialog:ctor(data)
	ActivityLoginAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 700)})
	self.m_data = data
	self.m_activity = ActivityMO.getActivityById(ACTIVITY_ID_LOGIN_AWARDS)
	local awardId = self.m_activity.awardId
	local ultiAward, awards = ActivityMO.queryActivityAwardsByAwardId(awardId)
	self.m_awards = awards
end

function ActivityLoginAwardDialog:onEnter()
	ActivityLoginAwardDialog.super.onEnter(self)
	self:setTitle(self.m_activity.name)

	armature_add(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")

	local awards = self.m_awards
	local bg = self:getBg()
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 660))

	local root = "activity_71_bg.jpg"
	if self.m_activity.awardId == 7499 then --特殊写死。奖励ID为99时，为节日活动
		root = "activity_71_festival_bg.jpg"
	end
	local topBg = display.newSprite(IMAGE_COMMON .. root):addTo(bg)
	topBg:setPosition(bg:width() / 2, bg:height() - topBg:height() / 2 - 70)

	--登录满6天奖励
	local box = display.newSprite(IMAGE_COMMON .. "activity_71_box.png")
	local awardBtn = ScaleButton.new(box, handler(self, self.awardHandler)):addTo(topBg)
	awardBtn:setPosition(topBg:width() - awardBtn:width() / 2 - 30, awardBtn:height() / 2 + 60)
	local status = self.m_data.status[#self.m_data.status]
	awardBtn.status = status
	awardBtn.keyId = awards[#awards].keyId
	self.m_awardBtn = awardBtn

	if status == 1 then --可领
		local light = armature_create("clds_gaoji_tx")
	    light:getAnimation():playWithIndex(0)
	    light:addTo(awardBtn,-1,99)
	    light:setPosition(awardBtn:width() / 2, awardBtn:height() / 2 + 8)
	    light:setScale(0.85)
		awardBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.8, 1), cc.ScaleTo:create(0.8, 0.9)})))
		awardBtn:run{
			"rep",
			{
				"seq",
				{"delay",math.random(1,3)},
				{"rotateTo",0,-10},
				{"rotateTo",0.1,10},
				{"rotateTo",0.1,-10},
				{"rotateTo",0.5,0,"ElasticOut"}
			}
		}
	end

	--tips
	local tips = UiUtil.label(CommonText[1147]):addTo(topBg)
	tips:setAnchorPoint(cc.p(0, 0.5))
	tips:setPosition(topBg:width() - tips:width() - 50, 38)

	--登录天数
	local days = UiUtil.label(self.m_data.days, nil ,COLOR[2]):rightTo(tips)

	--总天数
	local total = UiUtil.label("/" .. (#self.m_data.status - 1) .. ")"):rightTo(days)

	local newAwards = clone(awards)
	table.remove(newAwards, #newAwards)
	self:showDayAwards(newAwards)
end

function ActivityLoginAwardDialog:showDayAwards(newAwards)
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local col = math.max(math.ceil(#newAwards / 2), 2)
	for k,v in ipairs(newAwards) do
		local award = json.decode(v.awardList)[1]

		local itemView = UiUtil.createItemView(award[1], award[2], {count = award[3]}):addTo(self:getBg())
		local x, y
		itemView:setScale(0.88)

		if k <= col then
			x = (self:getBg():width() / col) * ((k-1)%col) + 95
		    y = self:getBg():getContentSize().height - 430
		 else
		 	x = (self:getBg():width() / col) * ((k-1)%col) + 95
		    y = self:getBg():getContentSize().height - 570
		 end
		itemView:setPosition(x, y)

		local days = UiUtil.label(CommonText[1146][k]):alignTo(itemView, -60, 1)

		local status = self.m_data.status[k]
		local keyId = v.keyId

		if status == 2 then
			display.newSprite(IMAGE_COMMON.."bg_0.png"):addTo(itemView):center()
			display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(itemView):center()
		elseif status == 0 then
			display.newSprite(IMAGE_COMMON.."bg_0.png"):addTo(itemView):center()
		end

		if self.m_data.index > k and status == 0 then
			local mask = display.newSprite(IMAGE_COMMON.."bg_0.png"):addTo(itemView):center()
			local overdue = UiUtil.label("已过期"):addTo(mask):center()
		end

		UiUtil.createItemDetailButton(itemView, nil, nil, function()
			if status == 0 and self.m_data.index <= k then
				if award[1] == ITEM_KIND_TANK then
					require("app.dialog.DetailTankDialog").new(award[2]):push()
				else
					require("app.dialog.DetailItemDialog").new(award[1], award[2], {count = award[3]}):push()
				end
			elseif status == 1 then
				ActivityBO.getLoginAwards(function ()
					self.m_data.status[k] = 2
					local awards = self.m_awards
					local newAwards = clone(awards)
					table.remove(newAwards, #newAwards)
					self:showDayAwards(newAwards)
				end ,keyId)
			else
				--todo
			end
		end)
	end
end

function ActivityLoginAwardDialog:awardHandler(tag, sender)
	local awards = self.m_awards
	local newAwards = clone(awards)

	local status = sender.status
	local keyId = sender.keyId
	if status == 0 then --不可领
		if self.m_data.index == (#self.m_data.status - 1) then
			Toast.show(CommonText[1148])
			return
		end

		local data = {}
		local award = json.decode(newAwards[#newAwards].awardList)

		for k,v in ipairs(award) do
			table.insert(data, {kind=v[1],type=v[1],id=v[2],count=v[3]})
		end

		require("app.dialog.RewardDialog").new(data):push()
	elseif status == 1 then --可领，未领取
		ActivityBO.getLoginAwards(function ()
			self.m_awardBtn:stopAllActions()
			self.m_awardBtn:removeChildByTag(99, true)
			self.m_awardBtn.status = 2
		end ,keyId)
	else --已领取
		Toast.show("奖励已领取")
	end
end

function ActivityLoginAwardDialog:onExit()
	ActivityLoginAwardDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/clds_gaoji_tx.pvr.ccz", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.plist", IMAGE_ANIMATION .. "effect/clds_gaoji_tx.xml")
end

return ActivityLoginAwardDialog