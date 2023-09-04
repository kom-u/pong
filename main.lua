-- assets location
ASSET_LOC = 'assets/'
FONT_LOC = ASSET_LOC .. 'fonts/'
SOUND_LOC = ASSET_LOC .. 'sounds/'

-- Libraries
-- push https://github.com/Ulydev/push
local push = require 'push'
-- class https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- Classes
require 'Ball'
require 'Paddle'

-- Sets virtual resolution
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Sets up the game window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--  Game settings
PADDLE_SPEED = 200



-- Called when the game first starts up
function love.load()
    -- Sets love's default filter to "nearest-neighbor", which essentially means there will be no filtering of pixels (blurriness), which is important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Sets up the window title
    love.window.setTitle('Pong')

    -- Seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- Initializes fonts
     SmallFont = love.graphics.newFont(FONT_LOC .. 'font.ttf', 8)
     LargeFont = love.graphics.newFont(FONT_LOC .. 'font.ttf', 16)
     ScoreFont = love.graphics.newFont(FONT_LOC .. 'font.ttf', 32)

    -- Initializes sounds
     Sounds = {
        ['paddle_hit'] = love.audio.newSource(SOUND_LOC .. 'paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource(SOUND_LOC .. 'score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource(SOUND_LOC .. 'wall_hit.wav', 'static')
    }

    -- Sets up the window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- Initializes player
     Player1 = Paddle(10, 30, 5, 20)
     Player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- Initializes ball
     BallObject = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- Initializes score variables
     Player1Score = 0
     Player2Score = 0

    -- Initializes serving player
     ServingPlayer = 1

    -- Initializes winning player
     WinningPlayer = 0


    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
    GameState = 'start'
end



-- Called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end



-- Runs every frame, with "dt" passed in, our delta in seconds since the last frame
function love.update(dt)
    if GameState == 'serve' then
        BallObject.deltaY = math.random(-50, 50)
        if ServingPlayer == 1 then
            BallObject.deltaX = math.random(140, 200)
        else
            BallObject.deltaX = -math.random(140, 200)
        end
    elseif GameState == 'play' then
        -- Detects ball collision with paddles, reversing dx if true and slightly increasing it, then altering the dy based on the position of collision
        if BallObject:isCollide(Player1) then
            BallObject.deltaX = -BallObject.deltaX * 1.03
            BallObject.x = Player1.x + 5

            if BallObject.deltaY < 0 then
                BallObject.deltaY = -math.random(10, 150)
            else
                BallObject.deltaY = math.random(10, 150)
            end

            Sounds['paddle_hit']:play()
        end

        if BallObject:isCollide(Player2) then
            BallObject.deltaX = -BallObject.deltaX * 1.03
            BallObject.x = Player2.x - 4

            if BallObject.deltaY < 0 then
                BallObject.deltaY = -math.random(10, 150)
            else
                BallObject.deltaY = math.random(10, 150)
            end

            Sounds['paddle_hit']:play()
        end



        -- Detects upper and lower screen boundary collision and reverses if collided
        if BallObject.y <= 0 then
            BallObject.y = 0
            BallObject.deltaY = -BallObject.deltaY
            Sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if BallObject.y >= VIRTUAL_HEIGHT - 4 then
            BallObject.y = VIRTUAL_HEIGHT - 4
            BallObject.deltaY = -BallObject.deltaY
            Sounds['wall_hit']:play()
        end



        -- Score update
        if BallObject.x < 0 then
            ServingPlayer = 1
            Player2Score = Player2Score + 1
            Sounds['score']:play()

            if Player2Score == 10 then
                WinningPlayer = 2
                GameState = 'done'
            else
                GameState = 'serve'
                BallObject:reset()
            end
        end

        if BallObject.x > VIRTUAL_WIDTH then
            ServingPlayer = 2
            Player1Score = Player1Score + 1
            Sounds['score']:play()

            if Player1Score == 10 then
                WinningPlayer = 1
                GameState = 'done'
            else
                GameState = 'serve'
                BallObject:reset()
            end
        end
    end


    
    -- Player can move whanever the GameState is
    -- Player 1 movement
    if love.keyboard.isDown('w') then
        Player1.deltaY = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        Player1.deltaY = PADDLE_SPEED
    else
        Player1.deltaY = 0
    end
    
    -- Player 2 movement
    if love.keyboard.isDown('up') then
        Player2.deltaY = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        Player2.deltaY = PADDLE_SPEED
    else
        Player2.deltaY = 0
    end



    -- Updates ball
    if GameState == 'play' then
        BallObject:update(dt)
    end

    Player1:update(dt)
    Player2:update(dt)
end



function love.keypressed(key)
    -- Keys can be accessed by string name
    if key == 'escape' then
        -- function LOVE gives us to terminate application
        love.event.quit()



    -- If we press enter during the start state of the game, we'll go into play mode
    -- and if we press enter during play mode, we'll go into start mode.
    elseif key == 'enter' or key == 'return' then
        if GameState == 'start' then
            GameState = 'serve'
        elseif GameState == 'serve' then
            GameState = 'play'
        elseif GameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            GameState = 'serve'

            BallObject:reset()

            -- reset scores to 0
            Player1Score = 0
            Player2Score = 0

            -- decide serving player as the opposite of who won
            if WinningPlayer == 1 then
                ServingPlayer = 2
            else
                ServingPlayer = 1
            end
        end
    end
end



-- Called after update by LOVE2D, used to draw anything to the screen, updated or otherwise
function love.draw()
    -- begin rendering at virtual resolution
    push:start()

    -- Clears the screen with a specific color; in this case, a color similar to some versions of the original Pong
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    if GameState == 'start' then
        love.graphics.setFont(SmallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif GameState == 'server' then
        love.graphics.setFont(SmallFont)
        love.graphics.printf('Player ' .. tostring(ServingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif GameState == 'play' then
        -- No UI messages to display in play
    elseif GameState == 'done' then
        love.graphics.setFont(LargeFont)
        love.graphics.printf('Player ' .. tostring(WinningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SmallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end



    -- Draw score on the left and right center of the screen
    DisplayScore()

    -- Renders paddles
    Player1:render()
    Player2:render()

    -- Render ball
    BallObject:render()

    -- Draw FPS
    DisplayFPS()
    
    -- end rendering at virtual resolution
    push:finish()
end



-- Display score
function DisplayScore()
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end



-- Display FPS
function DisplayFPS()
    love.graphics.setFont(SmallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end