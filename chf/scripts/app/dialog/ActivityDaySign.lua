--
-- Author: xiaoxing
-- Date: 2017-04-17 19:35:31
--
local ItemTableView = class("ItemTableView", TableView)

function ItemTableView:ctor(size,rhand)
	ItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(self:getViewSize().width, 128)
end

function ItemTableView:onEnter()
	ItemTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_PARTY_BATTLE_JOIN_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function ItemTableView:numberOfCells()
	return #self.m_list
end

function ItemTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ItemTableView:createCellAtIndex(cell, index)
	ItemTableView.super.createCellAtIndex(self, cell, index)
	local data = self.m_list[index]
	local x,y,ex = 69,self.m_cellSize.height/2,122
	for k,v in ipairs(data) do
		local tx = x + (k-1)*ex
		local day = (index - 1)*4 + k
		display.newSprite(IMAGE_COMMON .."btn_position_normal.png"):addTo(cell):pos(tx,y):scale(0.72)
		local award = json.decode(v.reward)
		local view = UiUtil.createItemView(award[1], award[2], {count = award[3]}):addTo(cell):pos(tx,y+3):scale(0.88)
		if v.multiple > 1 then
			display.newSprite(IMAGE_COMMON.."vip_more.png"):addTo(cell):pos(tx - 25,y + 25)
			UiUtil.label(string.format(CommonText[992][1], v.vip,v.multiple), 16, cc.c3b(255,187,57))
				:addTo(cell):pos(tx-30,y+30):rotation(-45)
		end
		local state =0
		if ActivityBO.sign_.days == day then
			if v.multiple > 1 and ActivityBO.sign_.today_sign == 1 then
				state = 2
				display.newSprite(IMAGE_COMMON.."bg_2.png"):addTo(cell):pos(tx,y+4)
			else
				display.newSprite(IMAGE_COMMON.."bg_0.png"):addTo(cell):pos(tx,y+4):scale(1.22)
				display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(cell):pos(tx,y+3)
			end
		elseif day == ActivityBO.sign_.days + 1 and ActivityBO.sign_.today_sign == 0 then
			state = 1
			display.newSprite(IMAGE_COMMON.."bg_1.png"):addTo(cell):pos(tx,y+4)
		elseif day < ActivityBO.sign_.days then
			display.newSprite(IMAGE_COMMON.."bg_0.png"):addTo(cell):pos(tx,y+4):scale(1.22)
			display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(cell):pos(tx,y+3)
		end
		UiUtil.createItemDetailButton(view, cell, true, function()
				if state == 0 then
					if award[1] == ITEM_KIND_TANK then
						require("app.dialog.DetailTankDialog").new(award[2]):push()
					else
						require("app.dialog.DetailItemDialog").new(award[1], award[2], {count = award[3]}):push()
					end
				elseif state == 1 then
					ActivityBO.monthSign(function()
							local offset = self:getContentOffset()
							self:reloadData()
							self:setContentOffset(offset)
							self.rhand()
						end)
				elseif state == 2 then
					if UserMO.vip_ < v.vip then
						local ConfirmDialog = require("app.dialog.ConfirmDialog")
						ConfirmDialog.new(CommonText[992][2], function()
							-- require("app.view.RechargeView").new():push()
							RechargeBO.openRechargeView()
						end):push()
						return
					end
					ActivityBO.monthSign(function()
							local offset = self:getContentOffset()
							self:reloadData()
							self:setContentOffset(offset)
						end)
				end
			end)
	end
	return cell
end

function ItemTableView:getNextHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarParties(function()
		Loading.getInstance():unshow()
		end, sender.page)
end

function ItemTableView:onExit()
	ItemTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end

function ItemTableView:updateUI(data)
	local list = {}
	for k,v in ipairs(data) do
		local index = math.floor((k-1)/4)
		if not list[index+1] then
			list[index+1] = {}
		end
		table.insert(list[index+1], v)
	end
	self.m_list = list
	self:reloadData()
end

--------------------------------------------------------------------
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local ActivityDaySign = class("ActivityDaySign", Dialog)

function ActivityDaySign:ctor()
	ActivityDaySign.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
end

function ActivityDaySign:onEnter()
	ActivityDaySign.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "effect/mrdl_baoxiang_guang.pvr.ccz", IMAGE_ANIMATION .. "effect/mrdl_baoxiang_guang.plist", IMAGE_ANIMATION .. "effect/mrdl_baoxiang_guang.xml")
	self:setTitle(CommonText[991][1])
	local bg = self:getBg()
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 810))
	
	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(bg)
	tableBg:setPreferredSize(cc.size(504, 526))
	tableBg:setPosition(bg:width()/2, bg:height() - tableBg:height()/2 - 70)

	local view = ItemTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 4),handler(self, self.updatePro)):addTo(tableBg)
	view:setPosition(0, 2)
	self.view = view

	local month = tonumber(os.date("%m", ManagerTimer.getTime()))
	local data = ActivityMO.getMonthSign(month)
	self.view:updateUI(data)
	if ActivityBO.sign_.days >= 17 or 
		(ActivityBO.sign_.days == 16 and ActivityBO.sign_.today_sign == 0) then
		self.view:setContentOffset(cc.p(0, 0))
	end

	local t = UiUtil.sprite9("info_bg_11.png",130,40,1,1,504,190)
		:addTo(bg):pos(bg:width()/2, 140)
	t = display.newNode():size(t:width(),t:height()):addTo(t)
	self.bottom = t
	self:updatePro()
end

function ActivityDaySign:updatePro()
	local t = self.bottom
	t:removeAllChildren()
	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.signInfo):push()
		end):addTo(t):scale(0.8)
	detailBtn:setPosition(462, t:height() - 35)

	local title = display.newSprite(IMAGE_COMMON.."title_red.png")
		:addTo(t):pos(t:width()/2, t:height() - 35):scaleTX(420)
	UiUtil.label(CommonText[991][2],24):alignTo(title, 0)
	--总进度
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_5.png", BAR_DIRECTION_HORIZONTAL, cc.size(412, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(412 + 4, 26)}):addTo(t)
	bar:setPosition(t:width() / 2 - 20, 55)
	local month = tonumber(os.date("%m", ManagerTimer.getTime()))
	local data = ActivityMO.getMonthSign(month)
	local list = {}
	for k,v in ipairs(data) do
		if v.extreward and v.extreward ~= "" then
			table.insert(list, v)
		end
	end
	local total = list[#list].day
	local sign = ActivityBO.sign_.days
	bar:setPercent(sign / total)
	local has = {}
	if table.isexist(ActivityBO.sign_, "day_ext") then
		for k,v in ipairs(ActivityBO.sign_.day_ext) do
			has[v] = true
		end
	end
	for k,v in ipairs(list) do
		UiUtil.showTip(bar, v.day, v.day/total*bar:width(), bar:height()/2 , 5, k)
		local img = "box"..k.."_0.png"
		if has[v.day] then
			img = "box"..k.."_1.png"
		end
		local data = {}
		for k,v in ipairs(json.decode(v.extreward)) do
			table.insert(data, {kind=v[1],type=v[1],id=v[2],count=v[3]})
		end
		local t = UiUtil.button(img, img, nil, function()
				local func = nil
				if sign >= v.day and not has[v.day] then
					func = function()
						ActivityBO.drawMonthSignExt(v.day,function()
								UiDirector.pop()
								self:updatePro()
							end)
					end
				end
				require("app.dialog.RewardDialog").new(data,func,has[v.day]):push()
			end):addTo(bar,2):pos(v.day/total*bar:width(),60)
		if sign >= v.day and not has[v.day] then
			local effect = armature_create("mrdl_baoxiang_guang_mc", t:x(),t:y()):addTo(bar)
		    effect:getAnimation():playWithIndex(0)
			t:run{
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
	end
end

function ActivityDaySign:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/mrdl_baoxiang_guang.pvr.ccz", IMAGE_ANIMATION .. "effect/mrdl_baoxiang_guang.plist", IMAGE_ANIMATION .. "effect/mrdl_baoxiang_guang.xml")
end

return ActivityDaySign