apple = {}
apple.total = 1

apple.create = function ()
    apple.total = 1

    apple[1] = {}
    apple[1].x = math.random(map.width)
    apple[1].y = math.random(map.height)
end

apple.createMultiple = function ()
    apple.total = 10

    for i = 1, apple.total do
        apple[i] = {}
        apple[i].x = math.random(map.width)
        apple[i].y = math.random(map.height)
    end
end

apple.resetIndex = function (index)
    apple[index].x = math.random(map.width)
    apple[index].y = math.random(map.height)
end

apple.update = function (player, audioOn)
    for i = 1, apple.total do
        if player[player.size].x == apple[i].x and player[player.size].y == apple[i].y then
            if audioOn then
                sounds.eatApple:play()
            end
            player.grow = true
            updateDelay = updateDelay - 1/2400
            apple.resetIndex(i)

            score = score + 100 * scoreMult
            break
        end
    end
end

specialApple = {}

specialApple.time = {}
specialApple.time.create = function ()
    specialApple.time.x = math.random(map.width)
    specialApple.time.y = math.random(map.height)
    specialApple.time.visible = false
end

specialApple.time.maxPeriod = 15
specialApple.time.active = false

specialApple.time.update = function (player, audioOn)
    if specialApple.time.visible then
        if player[player.size].x == specialApple.time.x and player[player.size].y == specialApple.time.y then
            if audioOn then
                sounds.powerUp:play()
            end
            sounds.soundtrack:setPitch(2)

            specialApple.time.active = true
            specialApple.time.create()

            updateDelay = updateDelay / 2
            scoreMult = 4
        end
    elseif not specialApple.time.visible and not specialApple.time.active then
        local randomNumber = math.random(1, 100)

        if randomNumber == 1 then -- 1%
            specialApple.time.visible = true
        end
    end
end

specialApple.time.timer = function(dt)
    specialApple.time.maxPeriod = specialApple.time.maxPeriod - dt
    if specialApple.time.maxPeriod < 0 then
        sounds.soundtrack:setPitch(1)

        specialApple.time.maxPeriod = 15
        scoreMult = 1
        updateDelay = updateDelay * 2

        specialApple.time.active = false
    end
end

specialApple.mult = {}
specialApple.mult.create = function ()
    specialApple.mult.x = math.random(map.width)
    specialApple.mult.y = math.random(map.height)
    specialApple.mult.visible = false
end

specialApple.mult.maxPeriod = 15
specialApple.mult.active = false

specialApple.mult.update = function (player, audioOn)
    if specialApple.mult.visible then
        if player[player.size].x == specialApple.mult.x and player[player.size].y == specialApple.mult.y then
            if audioOn then
                sounds.powerUp:play()
            end

            specialApple.mult.active = true
            specialApple.mult.create()

            apple.createMultiple()
        end
    elseif not specialApple.mult.visible and not specialApple.mult.active then
        local randomNumber = math.random(1, 100)

        if randomNumber == 1 then -- 1%
            specialApple.mult.visible = true
        end
    end
end

specialApple.mult.timer = function(dt)
    specialApple.mult.maxPeriod = specialApple.mult.maxPeriod - dt
    if specialApple.mult.maxPeriod < 0 then
        specialApple.mult.maxPeriod = 15
        apple.create()

        specialApple.mult.active = false
    end
end