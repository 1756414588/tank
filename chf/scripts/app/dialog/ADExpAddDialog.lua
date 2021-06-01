
local Dialog = require("app.dialog.Dialog")
local ADExpAddDialog = class("ADExpAddDialog", Dialog)


--adType  广告类型 1 经验 2 编制经验
function ADExpAddDialog:ctor(adType)
	ADExpAddDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})

	self.m_adType = adType
end

function ADExpAddDialog:onEnter()
	ADExpAddDialog.super.onEnter(self)
	self:setOutOfBgClose(true)

	local bgm = display.newSprite(IMAGE_COMMON.."guide/role_1.png"):addTo(self:getBg()):align(display.LEFT_BOTTOM,22,self:getBg():height() - 10)

	local titLab = ui.newTTFLabel({text = CommonText.MuzhiAD[3][1], font = G_FONT, size = 28, 
		 color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	titLab:setAnchorPoint(cc.p(0.5, 0.5))
	titLab:setPosition(self:getBg():getContentSize().width / 2,310)

	local adLab = ui.newTTFLabel({text = "", font = G_FONT, size = 24, 
		 color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	adLab:setAnchorPoint(cc.p(0, 0.5))

	if self.m_adType == 1 then
		adLab:setString(string.format(CommonText.MuzhiAD[5][1],MZAD_EXPADD_TIME * MZAD_EXPADD_FACTOR))
	else
		adLab:setString(string.format(CommonText.MuzhiAD[5][2],MZAD_STAFFADD_TIME))
	end
	adLab:setPosition(70,230)

	--提示
	local adLab1 = ui.newTTFLabel({text = CommonText.MuzhiAD[5][3], font = G_FONT, size = 24, 
		 color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	adLab1:setAnchorPoint(cc.p(0, 0.5))
	adLab1:setPosition(70,180)

	local adLab2 = ui.newTTFLabel({text = "", font = G_FONT, size = 24, 
		 color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	adLab2:setAnchorPoint(cc.p(0, 0.5))
	adLab2:setPosition(adLab1:getPositionX() + adLab1:getContentSize().width,180)
	self.m_adLab2 = adLab2
	if self.m_adType == 1 then
		adLab2:setString(MuzhiADMO.ExpAddADTime * MZAD_EXPADD_FACTOR .. "%")
	else
		adLab2:setString(MuzhiADMO.StaffingAddADTime .. "%")
	end

	-- 播放广告按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	self.m_adBtn = MenuButton.new(normal, selected, disabled, handler(self, self.playAdHandle)):addTo(self:getBg())  -- 确定
	self.m_adBtn:setLabel(CommonText.MuzhiAD[1][2])
	self.m_adBtn:setPosition(self:getBg():getContentSize().width / 2 , 80)
	self.m_adBtn.m_label:setPositionX(self.m_adBtn.m_label:getPositionX() + 20)
	display.newSprite(IMAGE_COMMON.."free.png"):addTo(self.m_adBtn):pos(45,58)
	display.newSprite(IMAGE_COMMON.."playAD.png"):addTo(self.m_adBtn):pos(75,50)

	if self.m_adType == 1 then
		self.m_adBtn:setVisible(MuzhiADMO.ExpAddADTime < 5)
	else
		self.m_adBtn:setVisible(MuzhiADMO.StaffingAddADTime < 5)
	end 
	
end

function ADExpAddDialog:playAdHandle()
	ServiceBO.playMzAD(MZAD_TYPE_VIDEO,function()
		Loading.getInstance():show()
		if self.m_adType == 1 then
			MuzhiADBO.PlayExpAddAD(function()
				Loading.getInstance():unshow()
				self.m_adLab2:setString(MuzhiADMO.ExpAddADTime * MZAD_EXPADD_FACTOR .. "%")
				self.m_adBtn:setVisible(MuzhiADMO.ExpAddADTime < 5)
			end)
		else
			MuzhiADBO.PlayStaffingAddAD(function()
				Loading.getInstance():unshow()
				self.m_adLab2:setString(MuzhiADMO.StaffingAddADTime .. "%")
				self.m_adBtn:setVisible(MuzhiADMO.StaffingAddADTime < 5)
			end)
		end
		
	end)
end



return ADExpAddDialog

