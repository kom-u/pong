Ball = Class {}



function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.deltaX = 0
    self.deltaY = 0
end



-- Expects a paddle as an argument and returns true or false, depending on whether their rectangles overlap.
function Ball:isCollide(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    return true
end


--  Resets the ball to the middle of the screen with no movement.
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.deltaX = 0
    self.deltaY = 0
end



function Ball:update(dt)
    self.x = self.x + self.deltaX * dt
    self.y = self.y + self.deltaY * dt
end



function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

