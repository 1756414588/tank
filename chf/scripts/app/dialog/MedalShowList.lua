--
-- Author: xiaoxing
-- Date: 2017-01-04 17:26:34
--
local ContentTableView = class("ContentTableView", TableView)
local rhand = rhand
function ContentTableView:ctor(size,parent)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.parent = parent
	self.m_cellSize = cc.size(size.width, 150)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_activityList[index]
	local md = MedalMO.queryById(data.medalId)
	local img = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON,data.medalId,{data = data})
		:addTo(cell):pos(103, 73)
	UiUtil.createItemDetailButton(img,cell,true)
	-- 名称
	local name = UiUtil.label(md.medalName,nil,COLOR[md.quality]):addTo(cell):align(display.LEFT_CENTER, 166, 120)
	
	local attrs = MedalBO.getPartAttrData(nil,nil,data)
	-- 强度
	local t = display.newSprite(IMAGE_COMMON .. "label_medal_strength.png"):addTo(cell)
	t:setAnchorPoint(cc.p(0, 0.5))
	t:setPosition(166, 80)
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(attrs.strengthValue), font = "fnt/num_2.fnt"}):rightTo(t, 10)
	
	local att = attrs[md.attr1]
	t = UiUtil.label(att.name .."："):alignTo(t, -25, 1)
	UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
	if md.attr2 > 0 then
		att = attrs[md.attr2]
		t = UiUtil.label(att.name.."："):alignTo(t, -25, 1)
		UiUtil.label(att.strValue,nil,COLOR[2]):rightTo(t)
	end
	
	UiUtil.sprite9("info_bg_26.png", 220, 80, 1, 1, 500, 138)
		:addTo(cell, -1):pos(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local btn = UiUtil.button("btn_9_normal.png", "btn_9_selected.png", nil, handler(self, self.show), CommonText[20181][3], 1)
	btn.data = data
	cell:addButton(btn, self.m_cellSize.width - 92, self.m_cellSize.height / 2)
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:show(tag,sender)
	local data = sender.data
	local md = MedalMO.queryById(data.medalId)

	local showStr = {
		{content = "展示需要消耗", }, 
		{content = string.format("%s", md.medalName), color = COLOR[md.quality]}, 
		{content = "，确定继续展示？", }, 
	}
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(showStr, function()
		MedalBO.showMedal(data.medalId,data.keyId,function()
				Toast.show(CommonText[20184])
				self.parent:pop()
			end)
	end):push()
end

function ContentTableView:updateUI(data)
	table.sort(data,function(a,b)
			local total1,total2 = MedalBO.getPartAttrData(nil, nil, a),MedalBO.getPartAttrData(nil, nil, b)
			return total1.strengthValue < total2.strengthValue
		end)
	self.m_activityList = data
	self:reloadData()
end

------------------------------------------------------------------------------
-- 坦克改装view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local MedalShowList = class("MedalShowList", Dialog)

-- tankId: 需要改装的tank
function MedalShowList:ctor(data)
	MedalShowList.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self.tankId = tankId
	self.data = data
	self:size(582,834)
end

function MedalShowList:onEnter()
	MedalShowList.super.onEnter(self)
	self:setTitle(CommonText[20181][3])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local view = ContentTableView.new(cc.size(500, self:getBg():height()-102),self)
		:addTo(self:getBg()):pos(42,34)
	--找出所有符合条件的科技类型 
	view:updateUI(self.data)
end

function MedalShowList:onExit()
	MedalShowList.super.onExit(self)
end

return MedalShowList
