-- 只能用于ScrollView中的cell内部的菜单按钮

local CellMenuButton = class("CellMenuButton", MenuButton)

function CellMenuButton:ctor(normalSprite, selectedSprite, disabledSprite, tagCallback)
	CellMenuButton.super.ctor(self, normalSprite, selectedSprite, disabledSprite, tagCallback)
    self:setTouchEnabled(false)
end

function CellMenuButton:onCellTouch(event)
	if not self:isVisible() or not self:isEnabled() then return false end

    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
        self:onTouchMoved(event)
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    else -- cancelled
        self:onTouchCancelled(event)
    end
end

-- 此事件不可使用
function CellMenuButton:onTouch(event, x, y)
	-- 此事件不可使用
	return false
end

function CellMenuButton:onExit()
    -- dump(self:getParent(), "???")
    if self._SCROLL_VIEW_ then
        self._SCROLL_VIEW_:_removeCellButton(self)
    end
end

return CellMenuButton
