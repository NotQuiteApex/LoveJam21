default_width = 1280
default_height = 800

function love.conf(t)
	t.identity = ".achocolypse"
	t.appendidentity = true
	t.version = "11.3"
	t.console = false
	t.accelerometerjoystick = true
	t.externalstorage = false 
	t.gammacorrect = false

	t.audio.mic = false
	t.audio.mixwithsystem = true

	t.window.title = "Werewolf: The Achocolypse"
	t.window.icon = "images/icon.png"
	t.window.width = default_width
	t.window.height = default_height
	t.window.borderless = false
	t.window.resizable = true
	t.window.minwidth = default_width/4
	t.window.minheight = default_height/4
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.vsync = 1
	t.window.msaa = 0
	t.window.depth = nil
	t.window.stencil = nil
	t.window.display = 1
	t.window.highdpi = true
	t.window.usedpiscale = true
	t.window.x = nil
	t.window.y = nil

	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = true
	t.modules.video = true
	t.modules.window = true
end