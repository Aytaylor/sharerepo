WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'
ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)
paddle1 = Paddle(5, 20, 5, 20)
paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

function love.load()
    --paddle1 = Paddle(5, 20, 5, 20)
    --paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('score.wav', 'static')
    }
    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end
    

    gameState = 'start'

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'play' then
        -- left goal
        if ball.x <= 0 then
            player2Score = player2Score + 1
            ball:reset()
            sounds['point_scored']:play()
            if player2Score >= 3 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
                ball.dx = 100
                servingPlayer = 1
            end
        end
        
        -- right goal
        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
            ball:reset()
            sounds['point_scored']:play()
            if player1Score >= 3 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
                ball.dx = -100
                servingPlayer = 2
            end
        end
    end
    -- collision check
    if ball:collides(paddle1) then
        -- deflect ball to the right
        ball.dx = -ball.dx * 1.03

        sounds['paddle_hit']:play()
    end
    -- deflect ball to the left
    if ball:collides(paddle2) then
        ball.dx = -ball.dx * 1.03

        sounds['paddle_hit']:play()
    end
    
    -- collide with ceiling
    if ball.y <= 0 then
        -- deflect ball down
        ball.dy = -ball.dy
        ball.y = 0
        sounds['paddle_hit']:play()
    end
    -- collide with floor
    if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4
        sounds['paddle_hit']:play()
    end

    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    if math.floor(ball.y) < math.floor(paddle2.y) then
        paddle2.dy = -PADDLE_SPEED / 3
    elseif math.floor(ball.y) > math.floor(paddle2.y) then
        paddle2.dy = PADDLE_SPEED / 3
    else
        paddle2.dy = 0
    end

    paddle1:update(dt)
    paddle2:update(dt)

end

function love.keypressed(key)
    -- exit app
    if key == 'escape' then
        love.event.quit()
    -- start or serve
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end
    

function love.draw()
    push:apply('start')

    love.graphics.clear(40 /255, 45 /255 , 52 / 255, 255 / 255)

    love.graphics.setFont(smallFont)
    love.graphics.print("Ball: " .. ball.y .. " Paddle: " .. paddle2.y)
    -- print text based on gameState
    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong! Use W and S to move the left paddle", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player  " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        -- display victory message
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player  " .. tostring(winningPlayer) .. " wins!", 0, 18, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Serve!", 0, 44, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI message
    end

    -- Print score
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- render ball (center)
    ball:render()
    -- render left paddle
    paddle1:render()
    --render right paddle
    paddle2:render()
    
    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end