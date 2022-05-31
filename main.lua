require "player"
require "food"

local push = require "libraries/push"
local serialize = require "libraries/ser"
local utf8 = require "utf8"

local saveFolder = "%homepath%/AppData/LocalLow/Snake/"
local saveName = "snake.sav"

local gameWidth, gameHeight = 1080, 720 -- fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth*.5, windowHeight*.5 --make the window a bit smaller than the screen itself

push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Snake")

    fontSmall = love.graphics.newFont("assets/fonts/upheavtt.ttf", 32)
    fontBig = love.graphics.newFont("assets/fonts/upheavtt.ttf", 128)

    sounds = {}
    sounds.on = true

    sounds.eatApple = love.audio.newSource("assets/audio/eatApple.wav", "static")
    sounds.powerUp = love.audio.newSource("assets/audio/powerUp.wav", "static")
    
    sounds.soundtrack = love.audio.newSource("assets/audio/soundtrack.wav", "stream")
    sounds.soundtrack:setLooping(true)

    sounds.soundtrack:play()

    count = 0
    updateDelay = 1/15

    gameState = "menu"
    score = 0
    scoreMult = 1

    love.graphics.setBackgroundColor(255, 255, 255)

    menu = {}
    menu.buttons = {}
    menu.buttons.count = 4

    menu.buttons[1] = {}
    menu.buttons[1].name = "Start"
    menu.buttons[1].onPress = function ()
        gameState = "play"
        score = 0
        snake.create()
    end
    menu.buttons[1].selected = true

    menu.buttons[2] = {}
    menu.buttons[2].name = "Ranking"
    menu.buttons[2].onPress = function ()
        gameState = "ranking"
        ranking.sort()
    end
    menu.buttons[2].selected = false

    menu.buttons[3] = {}
    menu.buttons[3].name = "Audio: On"
    menu.buttons[3].onPress = function ()
        sounds.on = not sounds.on

        if sounds.on then
            menu.buttons[3].name = "Audio: On"
            sounds.soundtrack:play()
        else
            menu.buttons[3].name = "Audio: Off"
            sounds.soundtrack:pause()
        end
    end
    menu.buttons[3].selected = false

    menu.buttons[4] = {}
    menu.buttons[4].name = "Quit"
    menu.buttons[4].onPress = function ()
        love.event.quit()
    end
    menu.buttons[4].selected = false

    menu.input = function (key)
        if key == "w" or key == "up" then
            for i = 1, menu.buttons.count do
                if menu.buttons[i].selected == true then
                    menu.buttons[i].selected = false
                    if i == 1 then
                        menu.buttons[menu.buttons.count].selected = true
                    else
                        menu.buttons[i - 1].selected = true
                    end

                    break
                end
            end
        end

        if key == "s" or key == "down" then
            for i = 1, menu.buttons.count do
                if menu.buttons[i].selected == true then
                    menu.buttons[i].selected = false
                    if i == menu.buttons.count then
                        menu.buttons[1].selected = true
                    else
                        menu.buttons[i + 1].selected = true
                    end

                    break
                end
            end
        end

        if key == "space" or key == "return" then
            for i = 1, menu.buttons.count do
                if menu.buttons[i].selected then
                    menu.buttons[i].onPress()
                end
            end
        end
    end

    menu.draw = function ()
        love.graphics.setColor(190/255, 195/255, 187/255)
        love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)

        love.graphics.setColor(89/255, 152/255, 47/255)
        love.graphics.setFont(fontBig)
        love.graphics.printf("Snake", windowWidth / 2 - 145, windowHeight / 2 - 100, 400, "center")
        love.graphics.setColor(0, 0, 0)

        love.graphics.setFont(fontSmall)
        for i = 1, menu.buttons.count do
            if menu.buttons[i].selected then
                love.graphics.setColor(100/255, 100/255, 100/255)
                love.graphics.printf(menu.buttons[i].name, windowWidth / 2 - 50, windowHeight / 2 + 50 + i * 50, 200, "center")
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.printf(menu.buttons[i].name, windowWidth / 2 - 50, windowHeight / 2 + 50 + i * 50, 200, "center")
            end
        end
    end

    pause = {}
    pause.buttons = {}
    pause.buttons.count = 2

    pause.buttons[1] = {}
    pause.buttons[1].name = "Continue"
    pause.buttons[1].onPress = function ()
        gameState = "play"
    end
    pause.buttons[1].selected = true

    pause.buttons[2] = {}
    pause.buttons[2].name = "Exit"
    pause.buttons[2].onPress = function ()
        gameState = "menu"
    end
    pause.buttons[2].selected = false

    pause.input = function (key)
        if key == "w" or key == "up" then
            for i = 1, pause.buttons.count do
                if pause.buttons[i].selected == true then
                    pause.buttons[i].selected = false
                    if i == 1 then
                        pause.buttons[pause.buttons.count].selected = true
                    else
                        pause.buttons[i - 1].selected = true
                    end

                    break
                end
            end
        end

        if key == "s" or key == "down" then
            for i = 1, pause.buttons.count do
                if pause.buttons[i].selected == true then
                    pause.buttons[i].selected = false
                    if i == pause.buttons.count then
                        pause.buttons[1].selected = true
                    else
                        pause.buttons[i + 1].selected = true
                    end

                    break
                end
            end
        end

        if key == "space" or key == "return" then
            for i = 1, pause.buttons.count do
                if pause.buttons[i].selected then
                    pause.buttons[i].onPress()
                end
            end
        end
    end

    pause.draw = function ()
        love.graphics.setColor(190/255, 195/255, 187/255)
        love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)

        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fontBig)
        love.graphics.printf("Pause", windowWidth / 2 - 145, windowHeight / 2 - 100, 400, "center")

        love.graphics.setFont(fontSmall)
        for i = 1, pause.buttons.count do
            if pause.buttons[i].selected then
                love.graphics.setColor(100/255, 100/255, 100/255)
                love.graphics.printf(pause.buttons[i].name, windowWidth / 2 - 50, windowHeight / 2 + 50 + i * 50, 200, "center")
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.printf(pause.buttons[i].name, windowWidth / 2 - 50, windowHeight / 2 + 50 + i * 50, 200, "center")
            end
        end
    end

    ranking = {}
    ranking.size = 0
    ranking.maxPrintSize = 5

    ranking.addScore = function(name, score)
        ranking.size = ranking.size + 1
        ranking[ranking.size] = {}
        ranking[ranking.size].name = name
        ranking[ranking.size].score = score
    end

    ranking.sort = function ()
        for i = 1, ranking.size do
            for j = 1, ranking.size - i do
                if ranking[j].score < ranking[j + 1].score then
                    local aux = ranking[j]
                    ranking[j] = ranking[j + 1]
                    ranking[j + 1] = aux
                end
            end
        end
    end

    ranking.draw = function()
        love.graphics.setColor(190/255, 195/255, 187/255)
        love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)

        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fontBig)
        love.graphics.printf("Ranking", windowWidth / 2 - 235, windowHeight / 2 - 100, 600, "center")

        love.graphics.setFont(fontSmall)
        for i = 1, ranking.size do
            love.graphics.printf(ranking[i].name .. " - " .. ranking[i].score, windowWidth / 2 - 145, windowHeight / 2 + i * 50, 400, "center")
            if i == ranking.maxPrintSize then
                break
            end
        end

        love.graphics.setColor(100/255, 100/255, 100/255)
        love.graphics.printf("Go back", windowWidth / 2 - 145, gameHeight - 100, 400, "center")
    end

    ranking.input = function (key)
        if key == "return" or key == "space" then
            gameState = "menu"
        end
    end

    ranking.save = function ()
        if love.filesystem.getInfo(saveFolder) == nil then
            love.filesystem.createDirectory(saveFolder)
        end
        love.filesystem.write(saveFolder .. saveName, serialize(ranking))
    end

    ranking.load = function ()
        if love.filesystem.getInfo(saveFolder .. saveName) ~= nil then
            local data = love.filesystem.load(saveFolder .. saveName)()
            for i = 1, data.size do
               ranking.addScore(data[i].name, data[i].score) 
            end
        end
    end

    gameOver = {}
    gameOver.scoreName = ""
    gameOver.nameWritten = true

    gameOver.buttons = {}
    gameOver.buttons.count = 2

    gameOver.buttons[1] = {}
    gameOver.buttons[1].name = "Try Again"
    gameOver.buttons[1].onPress = function ()
        gameState = "play"
        score = 0
        snake.create()
    end
    gameOver.buttons[1].selected = true

    gameOver.buttons[2] = {}
    gameOver.buttons[2].name = "Main Menu"
    gameOver.buttons[2].onPress = function ()
        gameState = "menu"
    end
    gameOver.buttons[2].selected = false

    gameOver.input = function (key)
        if gameOver.nameWritten then
            if key == "w" or key == "up" then
                for i = 1, gameOver.buttons.count do
                    if gameOver.buttons[i].selected == true then
                        gameOver.buttons[i].selected = false
                        if i == 1 then
                            gameOver.buttons[gameOver.buttons.count].selected = true
                        else
                            gameOver.buttons[i - 1].selected = true
                        end

                        break
                    end
                end
            end

            if key == "s" or key == "down" then
                for i = 1, gameOver.buttons.count do
                    if gameOver.buttons[i].selected == true then
                        gameOver.buttons[i].selected = false
                        if i == gameOver.buttons.count then
                            gameOver.buttons[1].selected = true
                        else
                            gameOver.buttons[i + 1].selected = true
                        end

                        break
                    end
                end
            end

            if key == "space" or key == "return" then
                for i = 1, gameOver.buttons.count do
                    if gameOver.buttons[i].selected then
                        gameOver.buttons[i].onPress()
                    end
                end
            end
        else
            if key == "backspace" then
                -- get the byte offset to the last UTF-8 character in the string.
                local byteoffset = utf8.offset(gameOver.scoreName, -1)

                if byteoffset then
                    -- remove the last UTF-8 character.
                    -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                    gameOver.scoreName = string.sub(gameOver.scoreName, 1, byteoffset - 1)
                end
            end

            if key == "return" then
                gameOver.nameWritten = true
                ranking.addScore(gameOver.scoreName, score)
                ranking.save()
            end
        end
    end

    gameOver.draw = function ()
        love.graphics.setColor(190/255, 195/255, 187/255)
        love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)

        love.graphics.setColor(255, 0, 0)
        love.graphics.setFont(fontBig)
        love.graphics.printf("You Died!", windowWidth / 2 - 145, windowHeight / 2 - 150, 400, "center")
        love.graphics.setColor(0, 0, 0)

        love.graphics.setFont(fontSmall)
        love.graphics.printf("Your Score: " .. score, windowWidth / 2 - 235, windowHeight / 2 + 100, 600, "center")

        love.graphics.printf("Name: " .. gameOver.scoreName .. "_", windowWidth / 2 - 145, windowHeight / 2 + 150, 400, "center")

        for i = 1, gameOver.buttons.count do
            if gameOver.buttons[i].selected then
                love.graphics.setColor(100/255, 100/255, 100/255)
                love.graphics.printf(gameOver.buttons[i].name, windowWidth / 2 - 50, windowHeight / 2 + 200 + i * 50, 200, "center")
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.printf(gameOver.buttons[i].name, windowWidth / 2 - 50, windowHeight / 2 + 200 + i * 50, 200, "center")
            end
        end
    end

    map = {}
    map.width = gameWidth / 20
    map.height = gameHeight / 20

    map.tile = {}
    map.tile.width = 20
    map.tile.height = 20

    map.create = function ()
        for i = 1, map.height do
            map[i] = {}
            for j = 1, map.width do
                map[i][j] = 0
            end
        end
    end

    map.create()

    map.update = function (player, food, specialFood)
        for i = 1, map.height do
            for j = 1, map.width do
                map[i][j] = 0
            end
        end

        for i = 1, player.size do
            map[player[i].y][player[i].x] = 1
        end

        for i = 1, food.total do
            map[food[i].y][food[i].x] = 2
        end

        if specialFood.time.visible then
            map[specialFood.time.y][specialFood.time.x] = 3
        end
        
        if specialFood.mult.visible then
            map[specialFood.mult.y][specialFood.mult.x] = 4
        end

    end

    map.draw = function ()
        love.graphics.setColor(190/255, 195/255, 187/255)
        for i = 0, map.height - 1 do
            for j = 0, map.width - 1 do
                if map[i + 1][j + 1] == 0 then -- map
                    love.graphics.rectangle("fill", j * 20, i * 20, map.tile.width, map.tile.height)
                elseif map[i + 1][j + 1] == 1 then -- player
                    love.graphics.rectangle("line", j * 20, i * 20, map.tile.width, map.tile.height)
                elseif map[i + 1][j + 1] == 2 then -- food
                    love.graphics.setColor(255, 0, 0)
                    love.graphics.rectangle("fill", j * 20, i * 20, map.tile.width, map.tile.height)
                    love.graphics.setColor(190/255, 195/255, 187/255)
                elseif map[i + 1][j + 1] == 3 then -- time special
                    love.graphics.setColor(0, 0, 255)
                    love.graphics.rectangle("fill", j * 20, i * 20, map.tile.width, map.tile.height)
                    love.graphics.setColor(190/255, 195/255, 187/255)
                elseif map[i + 1][j + 1] == 4 then -- mult special
                    love.graphics.setColor(240/255, 240/255, 0)
                    love.graphics.rectangle("fill", j * 20, i * 20, map.tile.width, map.tile.height)
                    love.graphics.setColor(190/255, 195/255, 187/255)
                end
            end
        end

        love.graphics.setFont(fontSmall)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Score: " .. score, windowWidth / 16, windowHeight / 16, 400, "left")
    end

    apple.create()

    specialApple.time.create()
    specialApple.mult.create()

    ranking.load()
end

function love.update(dt)
    if specialApple.time.active then
        specialApple.time.timer(dt)
    end

    if specialApple.mult.active then
        specialApple.mult.timer(dt)
    end

    if gameState == 'play' then
        count = count + dt -- dt is in seconds
        while count > updateDelay do
            snake.update()
            apple.update(snake, sounds.on)
            specialApple.time.update(snake, sounds.on)
            specialApple.mult.update(snake, sounds.on)
            map.update(snake, apple, specialApple)

            count = count - updateDelay
        end
    end
end

function love.textinput(t)
    if gameState == "gameOver" then
        if not gameOver.nameWritten and string.len(gameOver.scoreName) < 5 then
            gameOver.scoreName = gameOver.scoreName .. t
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
       if gameState == "play" then
           gameState = "pause"
       elseif gameState == "pause" then
           gameState = "play"
       end
    end

    if gameState == "play" then snake.input(key)
    elseif gameState == "menu" then menu.input(key)
    elseif gameState == "pause" then pause.input(key)
    elseif gameState == "gameOver" then gameOver.input(key)
    elseif gameState == "ranking" then ranking.input(key) end
end

function love.draw()
    push:start()

    if gameState == "play" then map.draw()
    elseif gameState == "menu" then menu.draw()
    elseif gameState == "pause" then pause.draw()
    elseif gameState == "gameOver" then gameOver.draw()
    elseif gameState == "ranking" then ranking.draw() end

    push:finish()
end