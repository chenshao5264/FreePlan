--
-- Author: Your Name
-- Date: 2017-06-14 09:42:08
--
local DrawNode = cc.DrawNode or {}

local atan = math.atan
local M_PI = math.pi
local cos  = math.cos
local sin  = math.sin

-- /**
--  * brief 				画圆弧
--  * @param  {[vec2]}		圆心坐标
--  * @param  {[vec2]}		圆弧位置
--  * @param  {[number]}	内圆半径
--  * @param  {[number]}	外圆半径
--  * @param  {[number]}	弧度
--  * @param  {[number]}	线段数量，越大弧越平滑
--  * @param  {[cc.c4f]}	颜色
--  * @return {[nil]}
--  */
function DrawNode:drawSolidSector(orign, beginVec, radius1, radius2, radian, segments, color)
	local angle = atan(beginVec.x / beginVec.y)
	if beginVec.y < 0 then
		angle = angle + M_PI
	end
	local coef = radian / segments

	local vertices1 = {}
	local vertices2 = {}

	for i = 0, segments do
		local rads = i * coef

		vertices1[i] = {}
		vertices1[i].x = radius1 * sin(rads + angle) + orign.x
		vertices1[i].y = radius1 * cos(rads + angle) + orign.y

		vertices2[i] = {}
		vertices2[i].x = radius2 * sin(rads + angle) + orign.x
		vertices2[i].y = radius2 * cos(rads + angle) + orign.y
	end

	local triangles = {}
	local triCount = 0
	for i = 0, segments - 1 do
		triangles[triCount] = {}
		triangles[triCount].a = vertices1[i]
		triangles[triCount].b = vertices2[i]
		triangles[triCount].c = vertices2[i + 1]
		triCount = triCount + 1

		triangles[triCount] = {}
		triangles[triCount].a = vertices1[i]
		triangles[triCount].b = vertices1[i + 1]
		triangles[triCount].c = vertices2[i + 1]
		triCount = triCount + 1
	end

	for i = 0, segments * 2 - 1 do
		self:drawTriangle(triangles[i].a, triangles[i].b, triangles[i].c, color)
	end
end

-- /**
--  * @param  {[vec2]}
--  * @param  {[table]}
--  * @param  {[table]}
--  * @param  {[number]}
--  * @param  {[number]}
--  * @return {[nil]}
--  */

-- local a = {60, 30, 150, 120}
-- local b = {cc.c4f(1, 0, 0, 1), cc.c4f(0, 1, 0, 1), cc.c4f(0, 0, 1, 1), cc.c4f(1, 0, 1, 1)}
-- draw:drawPie(cc.p(display.cx, display.cy), a, b, 100, 100)
function DrawNode:drawPie(orign, radians, colors, radius, segments)
	radians = checktable(radians)
	colors  = checktable(colors)
	
	if #radians ~= #colors then
		print("<==== 颜色数量和份数数量不对等")
		return
	end

	local beginVec = 0
	local middleVec = 0

	for i = 1, #radians  do
		local x = sin(beginVec)
		local y = cos(beginVec)

		self:drawSolidSector(orign, cc.p(x, y), radius, 0, radians[i] * M_PI / 180, segments, colors[i])
		beginVec = beginVec + radians[i] * M_PI / 180

		-- if radians[i] > 0 then
		-- 	local txt = string.format("%.1f%%", radians[i] / 360 * 100)
		-- 	local textPercent = ccui.Text:create(txt, "", 20)
		-- 	middleVec = radians[i] / 2 * M_PI / 180
		-- 	textPercent:setPosition(cc.p(orign.x + radius / 2 * sin(beginVec - middleVec), orign.y + radius / 2 * cos(beginVec - middleVec)))
		-- 	self:addChild(textPercent, 1)
		-- end
	end
end