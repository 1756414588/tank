--
-- Author: Your Name
-- Date: 2017-09-26 17:28:54
--

local Dialog = require("app.dialog.Dialog")
local HyperspaceAwardDialog = class("HyperspaceAwardDialog", Dialog)

function HyperspaceAwardDialog:ctor(data)
	HyperspaceAwardDialog.super.ctor(self,nil,nil)
	self.m_data = data
	self:setOutOfBgClose(false)
	self:setInOfBgClose(false)
end

function HyperspaceAwardDialog:onEnter()
	HyperspaceAwardDialog.super.onEnter(self)
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_99.png"):addTo(self:getBg()):center()
	local hyperMan = display.newSprite(IMAGE_COMMON .. "hyperspace_man.png"):addTo(bg)
	hyperMan:setPosition(hyperMan:width() / 2 - 10,15)
	hyperMan:setAnchorPoint(cc.p(0.5,0))
	
	local desc = UiUtil.label(CommonText[1751],nil,nil,cc.size(320,0),ui.TEXT_ALIGN_LEFT):addTo(bg)
	desc:setAnchorPoint(cc.p(0,1))
	desc:setPosition(hyperMan:x() + hyperMan:width() / 2 + 10,bg:height() - 30)


	local function mergeUiAwards(awards)
		local ret = {}

		local function add(award)
			if award.id and award.id == 0 then award.id = nil end

			for index = 1, #ret do
				local r = ret[index]
				if r.kind == award.kind then
					if r.id and award.id then
						if r.id == award.id then  -- 找到了
							r.count = r.count + award.count
							return
						end
					elseif not r.id and not award.id then  -- 找到了
						r.count = award.count
						return
					end
				end
			end
			ret[#ret + 1] = award
		end
		
		for index = 1, #awards do
			local award = awards[index]
			if not table.isexist(award, "kind") then award.kind = award.type end

			add(award)
		end
		return ret
	end
	local as = mergeUiAwards(self.m_data)
	for index= 1,#as do
		local awards = as[index]
		local itemView = UiUtil.createItemView(awards.type, awards.id,{count = awards.count}):addTo(bg)
		itemView:setAnchorPoint(cc.p(0,1))
		itemView:setScale(0.6)
		local x,y
		if index <= 2 then
			x = hyperMan:x() + index * (itemView:width() / 2 + 30) + 50
			y = 100
		else
			x = hyperMan:x() + (index - 2) * (itemView:width() / 2 + 10) + 50
			y = 60
		end
		itemView:setPosition(x,y)
		UiUtil.createItemDetailButton(itemView)
	end

	--领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.rewardCallBack)):addTo(bg)
	btn:setPosition(bg:width() - btn:width() / 2 - 40,btn:height() / 2 + 30)
	btn:setLabel(CommonText[538][2])

end

function HyperspaceAwardDialog:rewardCallBack(tag,sender)
	ManagerSound.playNormalButtonSound()
	ActivityCenterBO.HyperSpaceGetAward(function (data)
		self:pop()
	end)
end

function HyperspaceAwardDialog:onExit()
	HyperspaceAwardDialog.super.onExit(self)
end

return HyperspaceAwardDialog