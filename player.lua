snake = {}
snake.size = 5
snake.direction = 'right'
snake.lastDir = 'right'

snake.create = function ()
    updateDelay = 1/15
    snake.size = 5
    for i = 1, snake.size do
        snake[i] = {}
        snake[i].x = i
        snake[i].y = 1
    end
end

snake.create()

snake.grow = false

snake.input = function (key)
    snake.lastDir = snake.direction
    if (key == "d" or key == "right") and snake.lastDir ~= 'left' then
        snake.direction = "right"
    elseif (key == "a" or key == "left") and snake.lastDir ~= 'right' then
        snake.direction = "left"
    elseif (key == "w" or key == "up") and snake.lastDir ~= 'down' then
        snake.direction = "up"
    elseif (key == "s" or key == "down") and snake.lastDir ~= 'up' then
        snake.direction = "down"
    end
end

snake.update = function ()
    local nextPoint = {}
    nextPoint.x = snake[snake.size].x
    nextPoint.y = snake[snake.size].y

    if snake.direction == 'right' then
        nextPoint.x = nextPoint.x + 1
    elseif snake.direction == 'left' then
        nextPoint.x = nextPoint.x - 1
    elseif snake.direction == 'up' then
        nextPoint.y = nextPoint.y - 1
    elseif snake.direction == 'down' then
        nextPoint.y = nextPoint.y + 1
    end

    if nextPoint.x > map.width then
        nextPoint.x = 1
    elseif nextPoint.x < 1 then
        nextPoint.x = map.width
    elseif nextPoint.y > map.height then
        nextPoint.y = 1
    elseif nextPoint.y < 1 then
        nextPoint.y = map.height
    end

    if snake.size > 1 then
        if nextPoint.x == snake[snake.size - 1].x and nextPoint.y == snake[snake.size - 1].y then
            nextPoint.x = snake[snake.size].x
            nextPoint.y = snake[snake.size].y

            if snake.direction == 'right' then
                snake.direction = 'left'
            elseif snake.direction == 'left' then
                snake.direction = 'right'
            elseif snake.direction == 'up' then
                snake.direction = 'down'
            elseif snake.direction == 'down' then
                snake.direction = 'up'
            end

            return
        end
    end

    if map[nextPoint.y][nextPoint.x] == 1 then
        gameState = "gameOver"
        gameOver.nameWritten = false
        gameOver.scoreName = ""
    end

    for i = 1, snake.size - 1 do
        snake[i] = snake[i + 1]
    end

    if snake.grow then
        snake.size = snake.size + 1
        snake.grow = false
    end

    snake[snake.size] = nextPoint
end