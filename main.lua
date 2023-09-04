-- push https://github.com/Ulydev/push
local push = require 'push'
-- Sets virtual resolution
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Sets up the game window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720



-- Called when the game first starts up
function love.load()
    -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text and graphics
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end



function love.keypressed(key)
    -- Keys can be accessed by string name
    if key == 'escape' then
        -- function LOVE gives us to terminate application
        love.event.quit()
    end
end



-- Called after update by LOVE2D, used to draw anything to the screen, updated or otherwise
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- note we are now using virtual width and height now for text placement
    love.graphics.printf('Hello Pong!', 0, VIRTUAL_HEIGHT / 2 - 6, VIRTUAL_WIDTH, 'center')

    -- end rendering at virtual resolution
    push:apply('end')
end



