--
-- Author: Gss
-- Date: 2018-08-20 14:25:47
--
-- 金币车界面  

local MoneyTankView = class("MoneyTankView", function()
	local node = display.newNode():size(display.width, display.height)
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function MoneyTankView:ctor()
	local left = display.newSprite("image/bg/moneytank_bg.jpg"):addTo(self):align(display.LEFT_BOTTOM,0,0)
	self:showMoneyTanks()
end

function MoneyTankView:showMoneyTanks()
	if self.m_tankButtons then
		for index = 1, #self.m_tankButtons do
			self.m_tankButtons[index]:removeSelf()
		end
	end
	self.m_tankButtons = {}

	local pos = function (tankId)
		for index = 1, #HomeBaseMoneyTankConfig do
			local config = HomeBaseMoneyTankConfig[index]
			if config.tankId == tankId then
				return aaaaa[config.pos]
			end
		end
	end

	local function putTank(tank)
		local tankConfig = HomeBO.getMoneyTankConfig(tank.tankId)
		if tankConfig then
			local touch = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId)
			touch:setScale(1.1)

			local btn = TouchButton.new(touch, handler(self, self.onTankBegan), nil, handler(self, self.onTankEnded), handler(self, self.onChosenTank)):addTo(self)
			btn.tankId = tank.tankId
			btn:setScale(0.78)
			btn:setPosition(tankConfig.x, tankConfig.y)

			-- 显示数量
			local count = UserMO.getResource(ITEM_KIND_TANK, tank.tankId)
			local label = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER})

			local numBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(btn)
			numBg:setPreferredSize(cc.size(label:getContentSize().width + 10, numBg:getContentSize().height))
			numBg:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height + 6)
			numBg:setScale(0.9)

			label:setPosition(numBg:getContentSize().width / 2 + 2, numBg:getContentSize().height / 2 + 2)
			label:addTo(numBg)

			self.m_tankButtons[#self.m_tankButtons + 1] = btn
		end
	end

	local tanks = TankMO.getAllMoneyTanks()
	-- 显示所有的坦克
	for tankIndex = 1, #tanks do
		putTank(tanks[tankIndex])
	end
end

function MoneyTankView:onTankBegan(tag, sender)
end

function MoneyTankView:onTankEnded(tag, sender)
end

function MoneyTankView:onChosenTank(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local tankId = sender.tankId
	gprint("[MoneyTankView] onChosenTank tankId:", tankId)

	require("app.dialog.DetailTankDialog").new(tankId, true):push()
end

function MoneyTankView:onExit()

end

return MoneyTankView