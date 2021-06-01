--
-- Author: Xiaohang
-- Date: 2016-08-10 14:47:27
--
--------------------------------------------------------------------
-- 增益tableview
--------------------------------------------------------------------
local EffectTableView = class("EffectTableView", TableView)

function EffectTableView:ctor(size)
	EffectTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_effects = ExerciseMO.getBuffs()
end

function EffectTableView:numberOfCells()
	return #self.m_effects
end

function EffectTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EffectTableView:createCellAtIndex(cell, index)
	EffectTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = ExerciseMO.getImage(index):addTo(cell)
		:pos(100, self.m_cellSize.height / 2)

	local level = ExerciseBO.buffData[index] and ExerciseBO.buffData[index].buffLv or 0
	local effectDB = ExerciseMO.queryBuffById(index,level)
	local title = ui.newTTFLabel({text = effectDB.buffName .." Lv."..level, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[12]}):addTo(cell)
	local exp = ExerciseBO.buffData[index] and ExerciseBO.buffData[index].exper or 0
	local str = CommonText[20088]..exp .."/"..effectDB.exp
	if effectDB.exp == -1 then
		str = CommonText[20088].."MAX"
	end
	local t = UiUtil.label(str):addTo(cell):align(display.LEFT_CENTER,170,72)
	UiUtil.label(effectDB.desc):addTo(cell):alignTo(t, -26, 1)
	self:showRate(ExerciseBO.buffData[index].ratio):addTo(cell):pos(370, 65)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
	local useBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onUp))
	cell:addButton(useBtn, self.m_cellSize.width - 80, self.m_cellSize.height / 2 - 22)
	useBtn.id = effectDB.buffId
	if effectDB.exp ~= -1 then
		local prop = json.decode(effectDB.cost)
		useBtn.prop = prop
		local t = nil
		if prop[1] == ITEM_KIND_COIN then
			t = display.newSprite(IMAGE_COMMON.."icon_coin.png")
				:addTo(cell):pos(self.m_cellSize.width - 100,114)
			UiUtil.label(UiUtil.strNumSimplify(prop[3])):addTo(cell):rightTo(t, 20)
		else
			t = UiUtil.createItemSprite(prop[1], prop[2]):scale(0.5)
				:addTo(cell):pos(self.m_cellSize.width - 100,114)
			UiUtil.label(UiUtil.strNumSimplify(prop[3])):addTo(cell):rightTo(t, -20)
		end
	else
		useBtn:hide()
	end
	return cell
end

--显示比率
function EffectTableView:showRate(value)
	local node = display.newNode():size(124,22)
	local value = node:width()*value/100
	display.newSprite(IMAGE_COMMON.."red.png")
		:addTo(node):align(display.LEFT_CENTER,0,node:height()/2):scaleTX(value)
	display.newSprite(IMAGE_COMMON.."blue.png")
		:addTo(node):align(display.LEFT_CENTER,value,node:height()/2):scaleTX(node:width() - value)
	return node
end

function EffectTableView:onUp(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not ExerciseMO.inPrepareTime() then
		Toast.show(CommonText[20106])
		return
	end
	ExerciseBO.improveBuff(sender.id,function()
			UserMO.reduceResource(sender.prop[1],sender.prop[3],sender.prop[2])
			self:reloadData()
		end)
end

--------------------------------------------------------------------
-- 增益view
--------------------------------------------------------------------

local ExerciseBuff = class("ExerciseBuff", UiNode)

function ExerciseBuff:ctor()
	ExerciseBuff.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function ExerciseBuff:onEnter()
	ExerciseBuff.super.onEnter(self)
	-- 增益信息
	self:setTitle(CommonText[20086])
	self:showUI()
end

function ExerciseBuff:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_container = container
	end

	local container = self.m_container

	container:removeAllChildren()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 40)

	local view = EffectTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 40)):addTo(container)
	self.view = view
	view:setPosition(0, 40)

	UiUtil.label(CommonText[20087]):addTo(self):align(display.LEFT_CENTER,50,46)
	ExerciseBO.getBuff(function()
			view:reloadData()
		end)
end

return ExerciseBuff