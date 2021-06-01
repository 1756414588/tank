--
-- Author: Your Name
-- Date: 2017-04-19 19:06:58
--
--材料工坊生产Dialog

MATERIAL = 1  --材料
DRAWING  = 2  --图纸

local textMap = {[2] = CommonText[1705][1], [3] = CommonText[1705][2], [4] = CommonText[1705][3], [5] = CommonText[1705][4]}
local paperTab = {[1] = CommonText[1706][1], [2] = CommonText[1706][2], [3] = CommonText[1706][3], [4] = CommonText[1706][4], [5] = CommonText[1706][5]}
local detailTab = {CommonText[1717][1],CommonText[1717][2],CommonText[1717][3],CommonText[1717][4]}
local lvTab = {1,2,3,4}

local Dialog = require("app.dialog.Dialog")
local MaterialProductDialog = class("MaterialProductDialog", Dialog)

function MaterialProductDialog:ctor(data,rhand)
	MaterialProductDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.m_data = data
	self.rhand = rhand
end

function MaterialProductDialog:onEnter()
	MaterialProductDialog.super.onEnter(self)
	self:setTitle(CommonText[1707])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(self:getBg():getContentSize().width - 30, 800))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	--选择需要生产的材料
	local choseBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(btm)
	choseBg:setCapInsets(cc.rect(80, 60, 1, 1))
	choseBg:setPreferredSize(cc.size(btm:width() - 30, 200))
	choseBg:setPosition(btm:width() / 2, btm:height() - choseBg:height() / 2 - 40)
	local chose = ui.newTTFLabel({text = CommonText[1708], font = G_FONT, size = FONT_SIZE_SMALL,
	 x = choseBg:width() / 2, y = choseBg:height() - 25, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(choseBg)

	local buildLevel = BuildMO.getBuildLevel(BUILD_ID_MATERIAL_WORKSHOP)
	for i=2,5 do
		if buildLevel < lvTab[i-1] then
			local famebg = display.newSprite(IMAGE_COMMON .. "item_bg_"..i..".png"):addTo(choseBg)
			famebg:setPosition(75 + 115*(i - 2),chose:y() - famebg:height() / 2 - 20)
			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_"..i..".png")
			local famesele = display.newSprite(IMAGE_COMMON .. "item_fame_"..i..".png")
			local lock = display.newSprite(IMAGE_COMMON.."icon_lock_1.png"):addTo(famebg):center()
			local addBtn = MenuButton.new(fame, famesele, nil,function ()
				ManagerSound.playNormalButtonSound()
				Toast.show(detailTab[i -1])
			end):addTo(famebg):center()

			local desc = ui.newTTFLabel({text = textMap[i], font = G_FONT, size = FONT_SIZE_TINY,
			 x = famebg:x() - famebg:width() / 2, y = famebg:y() - famebg:height() / 2 - 20, color = COLOR[i]}):addTo(choseBg)
		else
			local normal = display.newSprite("image/item/material_color_"..(i-1)..".jpg")
			local selected = display.newSprite("image/item/material_color_"..(i-1)..".jpg")
			local itemButton = MenuButton.new(normal, selected, nil, handler(self, self.onChoseMaterial)):addTo(choseBg)
			itemButton:setPosition(75 + 115*(i - 2),chose:y() - itemButton:height() / 2 - 20)
			itemButton.tag = i
			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_"..i..".png"):addTo(itemButton):center()
			
			local desc = ui.newTTFLabel({text = textMap[i], font = G_FONT, size = FONT_SIZE_TINY,
			 x = itemButton:x() - itemButton:width() / 2, y = itemButton:y() - itemButton:height() / 2 - 20, color = COLOR[i]}):addTo(choseBg)
		end
	end

	self.chose = display.newSprite(IMAGE_COMMON.."chose_1.png"):addTo(choseBg):pos(75,chose:y() - 70)
	self.chose:setScale(0.7)
	self.quility = 2  --初始化品质为2

	self:showUI()

	--确定生产按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local productBtn = MenuButton.new(normal, selected, nil, handler(self, self.productCallback)):addTo(btm)
	productBtn:setPosition(btm:width() / 2,productBtn:height() / 2 + 10)
	productBtn:setLabel(CommonText[1709])

end

function MaterialProductDialog:productCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	if self.paperCost == false then
		Toast.show(CommonText[1713])
		return
	elseif self.resourceCost == false then
		Toast.show(self.cost2.name..CommonText[1715])
		return
	end

	MaterialBO.productLordEquipMat(function (data)
		self.rhand(data)
		self:pop()
	end,self.quility,self.coastId)
end

function MaterialProductDialog:showUI()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end
	
	local container = display.newNode():addTo(self:getBg(),-1)
	container:setAnchorPoint(cc.p(0.5,0.5))
	container:setContentSize(cc.size(self:getBg():getContentSize().width - 30, 800))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	self.m_contentNode = container

	local paperId = MaterialMO.queryPaperByQuality(MATERIAL,self.quility)
	local query = WeaponryMO.queryUp(paperId[1].formula)
	local cost = json.decode(query.materials)
	-- local cost1 = UserMO.getResourceData(cost[1][1], cost[1][2]) --图纸
	self.cost2 = UserMO.getResourceData(cost[2][1], cost[2][2]) --资源
	local cient = json.decode(UserMO.querySystemId(38))
	local speed = UserMO.getResource(ITEM_KIND_PROSPEROUS) / cient[1] * 10000 + UserMO.maxProsperous_ / cient[2] * 10000 + 10000
	local costTime = query.period / (speed / 10000) --最低保证速度为1
	self.paperCost = false
	for index =1,#MaterialMO.getPaperByQuality(cost[1][2]) do
		if MaterialMO.getPaperByQuality(cost[1][2])[index].count >= cost[1][3] then
			self.paperCost = true
		else
			self.paperCost = false
		end
	end
	-- self.paperCost = MaterialMO.getPaperByQuality(cost[1][2]) >= cost[1][3]
	self.resourceCost = UserMO.getResource(cost[2][1],cost[2][2]) >= cost[2][3]

	--生产消耗
	local descBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(container)
	descBg:setPreferredSize(cc.size(container:width(), 140))
	descBg:setPosition(container:width() / 2, 560 - descBg:height() / 2 - 10)

	local desc = ui.newTTFLabel({text = textMap[self.quility], font = G_FONT, size = FONT_SIZE_SMALL,
		 x = 40, y = descBg:height() - 30,align = ui.TEXT_ALIGN_LEFT, color = COLOR[self.quility]}):addTo(descBg)
	local consume = ui.newTTFLabel({text = CommonText[1710]..paperTab[cost[1][2]].."*"..cost[1][3]..","..self.cost2.name.."*"..UiUtil.strNumSimplify(cost[2][3]), font = G_FONT, size = FONT_SIZE_SMALL,
		x = 40, y = desc:y() - 40,align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(descBg:width() - 60, 98), color = COLOR[1]}):addTo(descBg)
	local time = ui.newTTFLabel({text = CommonText[1701][3]..UiUtil.strBuildTime(costTime), font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 20, align = ui.TEXT_ALIGN_LEFT,
		color = COLOR[1]}):addTo(descBg)
	--选择图纸
	local drawBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	drawBg:setCapInsets(cc.rect(80, 60, 1, 1))
	drawBg:setPreferredSize(cc.size(container:width() - 30, 290))
	drawBg:setPosition(container:width() / 2, descBg:y() - descBg:height() / 2 - drawBg:height() / 2 - 10)
	local chosedraw = ui.newTTFLabel({text = CommonText[1711], font = G_FONT, size = FONT_SIZE_SMALL,
	 x = drawBg:width() / 2, y = drawBg:height() - 25, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(drawBg)
	--图纸列表
	local paperInfo = MaterialMO.getPaperByQuality(cost[1][2])
	if #paperInfo <= 0 then
		local desc = ui.newTTFLabel({text = CommonText[1712], font = G_FONT, size = FONT_SIZE_SMALL, x = drawBg:width() / 2, y = drawBg:height() / 2, align = ui.TEXT_ALIGN_CENTER,
			color = COLOR[1]}):addTo(drawBg)
		return
	end
	local function sortFun(a,b)
		return a.count > b.count
	end
	table.sort(paperInfo,sortFun) --按数量多少排序
	for index=1,#paperInfo do
		local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_PAPER, paperInfo[index].id, {count = paperInfo[index].count})
		itemView:setScale(0.8)
		itemView:addTo(drawBg)
		itemView.tag = paperInfo[index].id
		UiUtil.createItemDetailButton(itemView, nil, false, handler(self, self.onChosenCallback))
		--图纸名字
		local resData = WeaponryMO.queryPaperById(paperInfo[index].id)
		local t = UiUtil.label(resData.name,FONT_SIZE_LIMIT,COLOR[resData.quality])
			:addTo(drawBg)
		if index <= 4 then
			itemView:setPosition(75 + 115*(index - 1),chosedraw:y() - itemView:height() / 2 - 30)
			t:setPosition(75 + 115*(index - 1),itemView:y() - itemView:height() / 2)
		else
			itemView:setPosition(75 + 115*(index - 5),chosedraw:y() - itemView:height() / 2 - itemView:height() - 40)
			t:setPosition(75 + 115*(index - 5),itemView:y() - itemView:height() / 2)
		end
	end

	self.gou = display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(drawBg):pos(75,chosedraw:y() - 80)
	self.coastId = paperInfo[1].id

end

function MaterialProductDialog:onChosenCallback(sender)
	ManagerSound.playNormalButtonSound()
	self.coastId = sender.tag
	if self.gou then
		self.gou:removeSelf()
	end
	self.gou = display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(sender):center()
end

function MaterialProductDialog:onChoseMaterial(tag,sender)
	ManagerSound.playNormalButtonSound()
	self.quility = sender.tag
	if self.chose then
		self.chose:removeSelf()
	end
	self.chose = display.newSprite(IMAGE_COMMON.."chose_1.png"):addTo(sender):center()
	self.chose:setScale(0.7)
	self:showUI()
end

function MaterialProductDialog:onExit()
	MaterialProductDialog.super.onExit(self)
end

return MaterialProductDialog