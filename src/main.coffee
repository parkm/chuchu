class GridView
  constructor: (renderer, world, grid) ->
    display = new PIXI.Graphics()

    @cellWidth = 48
    @cellHeight = 48

    colorToggle = false
    for y in [0..grid.vCells-1] by 1
      for x in [0..grid.hCells-1] by 1

        if !colorToggle
          display.beginFill(0x006EB9,1)
        else
          display.beginFill(0xAFAFAF,1)
        colorToggle = !colorToggle

        display.drawRect(x * @cellWidth, y * @cellHeight , @cellWidth, @cellHeight)
        display.endFill()

      colorToggle = !colorToggle

    width = @cellWidth * grid.hCells
    height = @cellHeight * grid.vCells

    display.x = renderer.width/2 - width/2
    display.y = renderer.height/2 - height/1.6

    @display = display
    world.addChild(@display)

  updateWalls: (grid) ->
    for slot in grid.slots
      if slot.walls.right
        @display.beginFill(0,1)
        @display.drawRect(slot.x * @cellWidth + @cellWidth - 5, slot.y * @cellHeight, 10, @cellHeight)
        @display.endFill()
      else if slot.walls.down
        @display.beginFill(0,1)
        @display.drawRect(slot.x * @cellWidth, slot.y * @cellHeight + @cellHeight - 5, @cellWidth, 10)
        @display.endFill()

class LevelView
  constructor: (renderer, world, level) ->
    @renderer = renderer
    @world = world

class LevelController
  constructor: (level, view) ->
    grid = new Grid(12, 9)
    @view = view
    @gridView = new GridView(view.renderer, view.world, grid)

  onCoinAdd: (coin) ->
    coinView = new CoinView(@view.renderer, @gridView, coin)
    coinControl = new CoinController(@, coin, coinView)

class CoinView
  constructor: (renderer, gridView, coin) ->
    display = new PIXI.Graphics()
    display.beginFill(0xCFCF00, 1)
    display.drawRect(8, 8, 32, 32)
    display.endFill()
    @display = display
    gridView.display.addChild(@display)

class CoinController
  constructor: (levelControl, coin, view) ->
    @gridView = levelControl.gridView
    coin.addListener('onMove', () =>
      view.display.x = coin.gridX * @gridView.cellWidth
      view.display.y = coin.gridY * @gridView.cellHeight
    )

onBodyLoad = () ->
  grid = new Grid(12, 9)
  level = new Level(grid)
  coin = new CoinEntity(level, 0, 0)
  coin2 = new CoinEntity(level, 1, 4)
  coin3 = new CoinEntity(level, 3, 8)
  grid.addWall(grid.getSlot(2,0), grid.getSlot(3, 0))
  grid.addWall(grid.getSlot(11,4), grid.getSlot(11, 5))

  stage = new PIXI.Stage(0x10109F)
  renderer = new PIXI.autoDetectRenderer(800, 600)
  world = new PIXI.DisplayObjectContainer()
  stage.addChild(world)
  document.body.appendChild(renderer.view)

  #gridView = new GridView(renderer, world, grid)
  levelView = new LevelView(renderer, world, level)
  levelControl = new LevelController(level, levelView)
  levelControl.gridView.updateWalls(grid)

  levelControl.onCoinAdd(coin)
  levelControl.onCoinAdd(coin2)
  levelControl.onCoinAdd(coin3)

  update = () ->
    #requestAnimFrame(update)
    coin.move()
    coin2.move()
    coin3.move()
    renderer.render(stage)
    setTimeout(update, 250)
  update()
