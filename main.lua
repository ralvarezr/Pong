-- Window.
VIRTUAL_WIDTH = 432 -- Fixed Game Resolution.
VIRTUAL_HEIGHT = 243 -- Fixed Game Resolution. 
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

-- Paddle.
PADDLE_WIDTH = 8
PADDLE_HEIGHT = 32
PADDLE_SPEED = 140

-- Ball
BALL_SIZE = 4

-- Include the Push Library
push = require 'lib/push'

-- Font Sizes.
SMALL_FONT = love.graphics.newFont('fonts/font.ttf', 16)
LARGE_FONT = love.graphics.newFont('fonts/font.ttf', 32)
MEDIUM_FONT = love.graphics.newFont('fonts/font.ttf', 20)
SCORE_FONT = love.graphics.newFont('fonts/font.ttf', 32)


-- Game State.
gameState = 'title'

-- Score
SCORE_TO_WIN = 3

-- Entities.
player1 = {
    x = 10, 
    y = 10,
    score = 0
}

player2 = {
    x = VIRTUAL_WIDTH - PADDLE_WIDTH - 10, 
    y = VIRTUAL_HEIGHT - PADDLE_HEIGHT - 10,
    score = 0
}

ball = {
    x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2,
    y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2,
    dx = 0, -- x speed
    dy = 0 -- y speed
}

-- Load Function.
function love.load()

    
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest') --Setting the OpenGL filter.
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {resizable = true, vsync = true})
    love.window.setTitle('Pong')

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    ballReset()

end

-- function to resize the window. Used by Push.
function love.resize(w, h)
    push:resize(w, h)
  end

-- update loop.
function love.update(dt)

    if love.keyboard.isDown('w') then
        player1.y = player1.y - dt * PADDLE_SPEED
        if player1.y <= 0 then
            player1.y = 0
        end
    end

    if love.keyboard.isDown('s') then
        player1.y = player1.y + dt * PADDLE_SPEED
        if player1.y >= VIRTUAL_HEIGHT - PADDLE_HEIGHT then
            player1.y = VIRTUAL_HEIGHT - PADDLE_HEIGHT
        end
    end

    if love.keyboard.isDown('up') then
        player2.y = player2.y - dt * PADDLE_SPEED
        if player2.y <= 0 then
            player2.y = 0
        end
    end

    if love.keyboard.isDown('down') then
        player2.y = player2.y + dt * PADDLE_SPEED
        if player2.y >= VIRTUAL_HEIGHT - PADDLE_HEIGHT then
            player2.y = VIRTUAL_HEIGHT - PADDLE_HEIGHT
        end
    end

    if gameState == 'play' then
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        if ball.x <= 0 then
            ballReset()
            gameState = 'serve'
            player2.score = player2.score + 1
            sounds['score']:play()
            if player2.score >= SCORE_TO_WIN then gameState = 'win' end
        end

        if ball.x >= VIRTUAL_WIDTH - BALL_SIZE then
            ballReset()
            gameState = 'serve'
            player1.score = player1.score + 1
            sounds['score']:play()
            if player1.score >= SCORE_TO_WIN then gameState = 'win' end
        end

        if ball.y >= (VIRTUAL_HEIGHT - BALL_SIZE) or ball.y <= 0 then
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if collides(ball, player1) then
            ball.x = player1.x + PADDLE_WIDTH
            ball.dx = -ball.dx * 1.1

            if ball.y < 0 then
                ball.dy = -math.random(10, 100)
            else
                ball.dy = math.random(10, 100)
            end 
            sounds['paddle_hit']:play()    
        end

        if collides(ball, player2) then
            ball.x = player2.x - BALL_SIZE
            ball.dx = -ball.dx * 1.1

            if ball.y < 0 then
                ball.dy = -math.random(10, 100)
            else
                ball.dy = math.random(10, 100)
            end
            sounds['paddle_hit']:play()
        end

    end

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'title' or gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'win' then
            player1.score = 0
            player2.score = 0
            gameState = 'title'
        end
    end

    if key == 'tab' then
        if gameState == 'title' then
            gameState = 'controls'
        elseif gameState == 'controls' then
            gameState = 'title'
        end
    end

end


-- Render Loop.
function love.draw()

    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    if gameState == 'title' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('PONG', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press ENTER to Play', 0, VIRTUAL_HEIGHT - 64, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press TAB Controls', 0, VIRTUAL_HEIGHT - 48, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press ESC to Exit', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')

    end

    if gameState == 'controls' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('Player 1:', 0, 10, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(MEDIUM_FONT)
        love.graphics.printf('Up: W', 0, 50, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Down: S', 0, 70, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('Player 2:', 0, 100, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(MEDIUM_FONT)
        love.graphics.printf('Up: Up Arrow Key', 0, 140, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Down: Down Arrow Key', 0, 160, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press TAB to Continue', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')

    end

    if gameState == 'serve' then
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter to Serve', 0, 10, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'win' then
        love.graphics.setFont(LARGE_FONT)
        local winner = player1.score >= SCORE_TO_WIN and '1' or '2'
        love.graphics.printf('Player ' .. winner .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter to Restart', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.rectangle('fill', player1.x, player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)

    if gameState ~= 'controls' then
        love.graphics.setFont(SCORE_FONT)
        love.graphics.print(player1.score, VIRTUAL_WIDTH / 2 - 36, VIRTUAL_HEIGHT/ 2 - 16)
        love.graphics.print(player2.score, VIRTUAL_WIDTH / 2 + 16, VIRTUAL_HEIGHT / 2 - 16)
        love.graphics.rectangle('fill', ball.x, ball.y, BALL_SIZE, BALL_SIZE)
    end

    push:finish()

end

-- AABB Collision.
function collides(ball, paddle) 
    return not (ball.x > paddle.x + PADDLE_WIDTH or ball.y > paddle.y + PADDLE_HEIGHT or  paddle.x > ball.x + BALL_SIZE or paddle.y > ball.y + BALL_SIZE)
end

-- Restarts the position and speed of the ball.
function ballReset()    

    ball.x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2
    ball.y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2

    ball.dx = 60 + math.random(60)
    if math.random(2) == 1 then -- half chance of beign negative.
        ball.dx = -ball.dx
    end
    ball.dy = 60 + math.random(60)
    if math.random(2) == 1 then -- half chance of beign negative.
        ball.dy = -ball.dy
    end
end