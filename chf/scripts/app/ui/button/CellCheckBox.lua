-- 只能用于ScrollView中的cell内部的CheckBox

local CellCheckBox = class("CellCheckBox", CheckBox)

function CellCheckBox:ctor(uncheckedSprite, checkedSprite, onCheckedChanged)
	CellCheckBox.super.ctor(self, uncheckedSprite, checkedSprite, onCheckedChanged)
    self:setTouchEnabled(false)
end

function CellCheckBox:onCellTouch(event)
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
function CellCheckBox:onTouch(event, x, y)
	-- 此事件不可使用
	return false
end

function CellCheckBox:onExit()
    -- dump(self:getParent(), "???")
    if self._SCROLL_VIEW_ then
        self._SCROLL_VIEW_:_removeCellButton(self)
    end
end

return CellCheckBox
