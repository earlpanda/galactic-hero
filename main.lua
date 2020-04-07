--[[
    Galactic Hero
    Simple space shooting game demo
    Reference from peterhellberg - "https://gist.github.com/peterhellberg/ac9f10c9559bdcc7296a.js"
]]

WIDTH = 480
HEIGHT = 800

Class = require 'Class'
require 'Player'

PLAYER_SPEED = 150
ENEMY_SPEED = 150
BULLET_SPEED = 250

createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

isAlive = true
score = 0

-- called when game starts 
-- load images, sounds of the game here
function love.load(arg)

    gamestate = 'start'

    background = love.graphics.newImage('gfx/milkyway.png')

    -- initialize player
    player = Player(200, 710)

    -- Entity storage
    bullets = {} -- array of current bullets being drawn and updated
    bullets2 = {} -- to stores bullets of enemies' aircrafts

    enemies = {} -- array of current enemies on the screen

    -- initialize bullet and enemies
    -- render image to map
    bulletimage = love.graphics.newImage('gfx/bullet.png')
    bulletimage2 = love.graphics.newImage('gfx/bullet2.png')
    enemies_image = love.graphics.newImage('gfx/enemy.png')

    scoreFont = love.graphics.newFont('font.ttf', 32)
    smallFont = love.graphics.newFont('font.ttf', 32)
end

function love.update(dt)

    -- keypress for shooting
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
    
    -- move the player
    if love.keyboard.isDown('left', 'a') then
        if player.x > 0 then
            player.x = player.x - (PLAYER_SPEED * dt)
        end
    elseif love.keyboard.isDown('right', 'd') then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (PLAYER_SPEED * dt)
        end
    elseif love.keyboard.isDown('up', 'w') then
        if player.y > 0 then
            player.y = player.y - (PLAYER_SPEED * dt)
        end
    elseif love.keyboard.isDown('down', 's') then
        if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
            player.y = player.y + (PLAYER_SPEED * dt)
        end
    end

    -- keep updating the positions of bullets when shooting
    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (BULLET_SPEED * dt)
        -- remove bullets when they pass off the screen
        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end

    -- time out enemy creation
    if score <= 5 then
        createEnemyTimer = createEnemyTimer - (0.3 * dt)
    elseif score >= 5 then
        createEnemyTimer = createEnemyTimer - (1 * dt)
    elseif score >= 10 then
        createEnemyTimer = createEnemyTimer - (1.5 * dt)
    elseif score >= 30 then
        createEnemyTimer = createEnemyTimer - (2 * dt)
    end
    if createEnemyTimer < 0 then
        createEnemyTimer = createEnemyTimerMax
        -- create an enemy
        if score < 10 then
            randomNumber = math.random(10, WIDTH - 10)
            newEnemy = { x = randomNumber, y = -10, img = enemies_image}
            table.insert(enemies, newEnemy)
        elseif score >= 10 then
            randomNumber = math.random(10, WIDTH - 100)
            newEnemy = { x = randomNumber, y = -100, img = enemies_image}
            table.insert(enemies, newEnemy)
        elseif score >= 30 then
            randomNumber = math.random(10, WIDTH - 300)
            newEnemy = { x = randomNumber, y = -200, img = enemies_image}
            table.insert(enemies, newEnemy)
        end
    end

    -- keep updating the positions of enemies
    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (100 * dt)
        -- remove enemies when they pass off the screen
        if enemy.y > 800 then 
            table.remove(enemies, i)
        end
    end

    -- enemies' bullets
    for i, bullet2 in ipairs(bullets2) do
        bullet2.y = bullet2.y + (BULLET_SPEED * dt)
        -- remove bullets when they pass off the screen
        if bullet2.y > HEIGHT then
            table.remove(bullets2, i)
        end
    end

    -- create bullets when enemies shoot
    if gamestate == 'play' then
        for i, enemy in ipairs(enemies) do
            if math.random(1, 10) == 1 and player.x > enemy.x + enemy.img:getHeight() / 2 then
                newBullet2 = {x = enemy.x + enemy.img:getWidth() / 2, 
                             y = enemy.y + enemy.img:getHeight(), img = bulletimage2}
                table.insert(bullets2, newBullet2)
            end
        end
    end

    -- run our collision detection
    -- check if our player shoot down enemies
    if gamestate == 'play' then
        for i, enemy in ipairs(enemies) do
            for j, bullet in ipairs(bullets) do
                if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
                    bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
                    table.remove(bullets, j)
                    table.remove(enemies, i)
                    score = score + 1
                end
            end
            -- check if enemies hit our player
            if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
                        player.x, player.y, player.width, player.height)
            and isAlive == true then
                table.remove(enemies, i)
                isAlive = false
                gamestate = 'done'
            end
        end
        -- check if enemies shoot down our player
        for i, bullet2 in ipairs(bullets2) do
            if CheckCollision(player.x, player.y, player.width, player.height,
                             bullet2.x, bullet2.y, bullet2.img:getWidth(), bullet2.img:getHeight())
            and isAlive == true then
                isAlive = false
                gamestate = 'done'
            end
        end
    end
end


-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called whenever a key is pressed
function love.keypressed(key)
    dt = love.timer.getDelta()
    -- to exit the game
    if love.keyboard.isDown('escape') then
        love.event.quit()
    end

    if gamestate == 'start' and love.keyboard.isDown('return', 'kpenter') then
        gamestate = 'play'
    elseif gamestate == 'done' and love.keyboard.isDown('r') then
        resetgame()
        gamestate = 'play'
    end   
    
    -- create bullets when shooting 
    if love.keyboard.isDown('space') then
        newBullet = {x = player.x + (player.img:getWidth() / 2), 
                     y = player.y, img = bulletimage}
        table.insert(bullets, newBullet)
    end

    love.keyboard.keysPressed[key] = true
end


function love.draw(dt)

    -- set background image
    love.graphics.clear(51/255, 43/255, 68/255, 1)
    drawBackground()
    
    displayScore()

    -- draw player
    if gamestate == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to Galactic Hero!", 0, HEIGHT/2 - 50, WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!", 0, HEIGHT/2 - 10, WIDTH, 'center')
    elseif gamestate == 'play' then 
        player:render()
    elseif gamestate == 'done' then
        love.graphics.print("Press 'R' to restart", 75, HEIGHT / 2)
    end
    
    love.graphics.setDefaultFilter('nearest', 'nearest')

    if gamestate == 'play' then
        -- draw bullets
        for i, bullet in ipairs(bullets) do 
            love.graphics.draw(bulletimage, bullet.x, bullet.y, 3)
        end

        for i, bullet2 in ipairs(bullets2) do 
            love.graphics.draw(bulletimage2, bullet2.x, bullet2.y, 3)
        end
    
        -- draw enemies
        for i, enemy in ipairs(enemies) do
            love.graphics.draw(enemies_image, enemy.x, enemy.y)
        end
    end

end

-- background is distributed for free on pixelstalk.net
function drawBackground()
    for i = 0, love.graphics.getWidth() / background:getWidth() do 
        for j = 0, love.graphics.getHeight() / background:getHeight() do
            love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
        end
    end
end

-- function to check collision
-- returns true if 2 objects overlap, false if they don't
-- x1, y1 are left-top coords of the first object, while w1, h1 are its width and height
-- x2, y2, w2, h2 are the same, but for the second object
function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    if x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1 then
        return true
    else
        return false
    end
end

function displayScore()
    -- set score font
    love.graphics.setFont(scoreFont)
    love.graphics.print(score, 10, 10)
end

function resetgame()
    -- remove all the bullets and enemies from the screen
    bullets = {}
    enemies = {}
    -- reset timers
    createEnemyTimer = createEnemyTimerMax
    -- move player to default position
    player.x = 200
    player.y = 710
    -- reset gamestate
    score = 0
    isAlive = true
end