--
-- Author: Gss
-- Date: 2018-12-19 10:50:06
--
-- 战术突破消耗界面  TacticBreakDialog

local Dialog = require("app.dialog.Dialog")
local TacticBreakDialog = class("TacticBreakDialog", Dialog)
	
function TacticBreakDialog:ctor(keyId)
	TacticBreakDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 540)})
	self.m_keyId = keyId
	self.m_tactic = TacticsMO.getTacticByKeyId(keyId)
end

function TacticBreakDialog:onEnter()
	TacticBreakDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)
	self:setTitle(CommonText[4010]) -- 战术突破

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(506, 150))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)

	local item = UiUtil.createItemView(ITEM_KIND_TACTIC, self.m_tactic.tacticsId,{tacticLv = self.m_tactic.lv}):addTo(infoBg)
	item:setPosition(item:width() / 2 + 20, infoBg:height() / 2 + 10)
	local resData = UserMO.getResourceData(ITEM_KIND_TACTIC, self.m_tactic.tacticsId)
	local name = UiUtil.label(resData.name):alignTo(item, -70, 1)

	local tacticInfo = TacticsMO.queryTacticById(self.m_tactic.tacticsId)
	local nowLv = UiUtil.label("Lv."..self.m_tactic.lv):addTo(infoBg)
	nowLv:setPosition(item:x() + item:width() / 2 + 60, item:y() + 20)
	local arrow = display.newSprite("image/tactics/break_arrow.png"):rightTo(nowLv, 30)
	local nextNum = TacticsMO.getNextBreakByLv(tacticInfo.quality, self.m_tactic.lv)
	local nextLv = UiUtil.label("Lv."..nextNum,nil,COLOR[5]):rightTo(arrow,30)

	local desc = UiUtil.label(CommonText[4028],nil,COLOR[2]):addTo(infoBg)
	desc:setPosition(infoBg:width() / 2 + 20, 48)
	--消耗
	local costLab = UiUtil.label(CommonText[4011]):addTo(self:getBg())
	costLab:setAnchorPoint(cc.p(0, 0.5))
	costLab:setPosition(50,infoBg:y() - infoBg:height() / 2 - 30)

	local costBg = display.newSprite("image/tactics/break_costbg.png"):addTo(self:getBg())
	costBg:setPosition(self:getBg():width() / 2, costLab:y() - 90)
	local costDB = TacticsMO.getLvInfoByLv(tacticInfo.quality, self.m_tactic.lv)
	local cost = TacticsMO.getBreakCostByLv(tacticInfo.quality,tacticInfo.tacticstype,self.m_tactic.lv)
	self.m_pieceNeed = cost.breakChips
	local costInfo = json.decode(cost.breakNeed)
	self.m_cost = costInfo

	local posX = 220
	local costPiece = UiUtil.createItemView(ITEM_KIND_TACTIC_PIECE, self.m_tactic.tacticsId):addTo(costBg)
	costPiece:setPosition(70,costBg:height() / 2 + 10)
	costPiece:setScale(0.83)
	UiUtil.createItemDetailButton(costPiece)
	local pieceName = UiUtil.label(resData.name.."*",nil,COLOR[tacticInfo.quality + 1]):addTo(costBg)
	pieceName:setPosition(costPiece:x() - 20, costPiece:y() - costPiece:height() / 2 - 18)
	local ownChips = UiUtil.label(UserMO.getResource(ITEM_KIND_TACTIC_PIECE, self.m_tactic.tacticsId),nil,COLOR[2]):rightTo(pieceName)
	local needChips = UiUtil.label("/"..cost.breakChips):rightTo(ownChips)

	if UserMO.getResource(ITEM_KIND_TACTIC_PIECE, self.m_tactic.tacticsId) < cost.breakChips then
		ownChips:setColor(COLOR[6])
	end
	if cost.breakChips == 0 then
		costPiece:setVisible(false)
		pieceName:setVisible(false)
		ownChips:setVisible(false)
		needChips:setVisible(false)
		posX = 70
	end

	for index=1, #costInfo do
		local itemView = UiUtil.createItemView(costInfo[index][1], costInfo[index][2]):addTo(costBg)
		itemView:setPosition(posX + (index - 1) * 160, costBg:height() / 2 + 10)
		itemView:setScale(0.8)
		UiUtil.createItemDetailButton(itemView)
		local resData = UserMO.getResourceData(costInfo[index][1], costInfo[index][2])
		-- local name = UiUtil.label(resData.name.. "*"..costInfo[index][3],18):alignTo(itemView, -60, 1)
		local name = UiUtil.label(resData.name.."*",18):addTo(costBg)
		name:setPosition(itemView:x() - 20,itemView:y() - itemView:height() / 2 - 10)

		local own = UserMO.getResource(costInfo[index][1], costInfo[index][2])
		local ownLab = UiUtil.label(own,nil,COLOR[2]):rightTo(name)
		local need = UiUtil.label("/"..costInfo[index][3]):rightTo(ownLab)
		if own < costInfo[index][3] then
			ownLab:setColor(COLOR[6])
		end
	end

	-- 突破
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local breakBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onBreakCallback)):addTo(self:getBg())
	breakBtn:setPosition(self:getBg():getContentSize().width / 2, breakBtn:height())
	breakBtn:setLabel(CommonText[4009][2])

end

function TacticBreakDialog:onBreakCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local canBreak = true
	for index =1, #self.m_cost do
		local own = UserMO.getResource(self.m_cost[index][1], self.m_cost[index][2])
		local need = self.m_cost[index][3]
		if own < need then
			canBreak = false
			break
		end
	end

	local ownPiece = UserMO.getResource(ITEM_KIND_TACTIC_PIECE, self.m_tactic.tacticsId)
	if ownPiece < self.m_pieceNeed then Toast.show(CommonText[4013]) return end

	if canBreak then
		TacticsBO.onTacticTp(function (data)
			Toast.show(CommonText[4012])
			self:pop()
		end, self.m_keyId)
	else
		Toast.show(CommonText[4013])
	end
end

return TacticBreakDialog