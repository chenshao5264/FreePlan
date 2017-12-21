--
-- Author: Chen
-- Date: 2017-11-07 14:31:55
-- Brief: 对象池,适用的对象是继承cocos2d::Ref的对象
--

local ccPool = class("ccPool")

local table_remove = table.remove

function ccPool:ctor()

    self._onceCountOfAllocObjects = 10 --// 每次重新创建的对象个数
    self._funcObjFactory = function() end --// 创建对象的工厂函数

    self._allObjs  = {}
    self._freeObjs = {}
end

local function push_back_all(self, obj)
    self._allObjs[#self._allObjs + 1] = obj
end

local function push_back_free(self, obj)
    self._freeObjs[#self._freeObjs + 1] = obj
end

local function pop_front_free(self)
    table_remove(self._freeObjs, 1)
end

-- /**
--  * 创建对象的工厂函数
--  * @param fc 函数指针
--  */
function ccPool:setFactory(fc)
    self._funcObjFactory = fc
end

-- /**
--  * 获取一个obj
--  * @param  
--  * @return
--  */
function ccPool:acquire()
    local freeObject = self._freeObjs[1]
    if not freeObject then
        self:allocObjects()
        freeObject = self._freeObjs[1]
    end

    pop_front_free(self)

    return freeObject
end

-- /**
--  * obj重新加入freed队列
--  * 调用时机，obj从父节点移除之后
--  */
function ccPool:recycle(obj)
    push_back_free(self, obj)
end

-- /**
--  * 清空pool
--  */
function ccPool:clearPool()
    for k, v in ipairs(self._allObjs) do
        v:release()
    end

    self._freeObjs = {}
    self._allObjs  = {}
end

function ccPool:allocObjects()
    for i = 1, self._onceCountOfAllocObjects do
        local obj = self._funcObjFactory()
        obj:retain()
        push_back_free(self, obj)
        push_back_all(self, obj)
    end
end

return ccPool