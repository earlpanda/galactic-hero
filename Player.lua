Player = Class{}

function Player:init(x, y)
    self.x = x
    self.y = y
    -- render image to map
    self.img = love.graphics.newImage('gfx/aircraft.png')

    self.width = self.img:getWidth()
    self.height = self.img:getHeight()
    
end

function Player:update()
    
end

function Player:render()
    -- pixel aircrafts created by chabull and 
    -- distributed for free on OpenGameArt.org
    love.graphics.draw(self.img, self.x, self.y)
end