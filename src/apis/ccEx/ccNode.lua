--
-- Author: Your Name
-- Date: 2017-06-27 18:28:22
--
local Node = cc.Node or {}

function Node:performWithDelay(callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return self
end

function Node:addTo(parent, zorder, tag)
    if tag then
        parent:addChild(self, zorder, tag)
    elseif zorder then
        parent:addChild(self, zorder)
    else
        parent:addChild(self)
    end
    return self
end

function Node:posY(y)
    self:setPositionY(y)
    return self
end

function Node:posX(x)
    self:setPositionX(x)
    return self
end

function Node:name(name)
    self:setName(name)
    return self
end

function Node:changeParent(newParent, zorder, tag)
    self:removeFromParent(false)
    self:addTo(newParent, zorder, tag)
end