class GridView
  constructor: (renderer, world, grid) ->
    display = new PIXI.Graphics()

    cellWidth = 48
    cellHeight = 48

    colorToggle = false
    for y in [0..grid.vCells-1] by 1
      for x in [0..grid.hCells-1] by 1

        if !colorToggle
          display.beginFill(0x006EB9,1)
        else
          display.beginFill(0xFFFFFF,1)
        colorToggle = !colorToggle

        display.drawRect(x * cellWidth, y * cellHeight ,cellWidth, cellHeight)
        display.endFill()

      colorToggle = !colorToggle

    width = cellWidth * grid.hCells
    height = cellHeight * grid.vCells

    display.x = renderer.width/2 - width/2
    display.y = renderer.height/2 - height/1.6

    world.addChild(display)

class LevelView
  constructor: (level) ->

class LevelController
  constructor: (level, view) ->

onBodyLoad = () ->
  grid = new Grid(12, 9)
  level = new Level(grid)

  stage = new PIXI.Stage(0x10109F)
  renderer = new PIXI.autoDetectRenderer(800, 600)
  world = new PIXI.DisplayObjectContainer()
  stage.addChild(world)
  document.body.appendChild(renderer.view)

  gridView = new GridView(renderer, world, grid)
  levelView = new LevelView(renderer, world, level)
  levelControl = new LevelController(level)

  console.log(grid)

  update = () ->
    #requestAnimFrame(update)
    renderer.render(stage)
  update()
