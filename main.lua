push = require 'push'
Class = require 'class'

require "Bird"
require "Pipe"
require "PipePair"

require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'
require 'states/CountdownState'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('images/background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('images/ground.png')
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()

local pipePairs = {}

local spawnTimer = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true

function love.load ()

  math.randomseed(os.time())

  love.graphics.setDefaultFilter('nearest','nearest')

  love.window.setTitle('Flufy bird')

  smallFont = love.graphics.newFont('fonts/font.ttf', 8)
  mediumFont = love.graphics.newFont('fonts/flappy.ttf', 14)
  flappyFont = love.graphics.newFont('fonts/flappy.ttf', 28)
  hugeFont = love.graphics.newFont('fonts/flappy.ttf', 56)
  love.graphics.setFont(flappyFont)


  sounds = {
       ['jump'] = love.audio.newSource('soundtracks/jump.wav', 'static'),
       ['explosion'] = love.audio.newSource('soundtracks/explosion.wav', 'static'),
       ['hurt'] = love.audio.newSource('soundtracks/hurt.wav', 'static'),
       ['score'] = love.audio.newSource('soundtracks/score.wav', 'static'),

       -- https://freesound.org/people/xsgianni/sounds/388079/
       ['music'] = love.audio.newSource('soundtracks/marios_way.mp3', 'static')
   }

   sounds['music']:setLooping(true)
   sounds['music']:play()

  push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
    vsync = true,
    fullscreen = false,
    resizable = true
  })


  gStateMachine = StateMachine {
         ['title'] = function() return TitleScreenState() end,
         ['countdown'] = function() return CountdownState() end,
         ['play'] = function() return PlayState() end,
         ['score'] = function() return ScoreState() end
     }
  gStateMachine:change('title')

  love.keyboard.keysPressed = {}

end

function love.resize (w,h)
  push:resize(w,h)
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true

  if key == 'escape' then
    love.event.quit()
  end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)

  backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
  groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

  gStateMachine:update(dt)

  love.keyboard.keysPressed = {}
end

function love.draw()
  push:start()

  love.graphics.draw(background,-backgroundScroll,0)

  gStateMachine:render()

  love.graphics.draw(ground,-groundScroll,VIRTUAL_HEIGHT-16)

  push:finish()


end
