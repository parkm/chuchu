class GridController
  constructor: (gameControl, grid) ->
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

    display.x = gameControl.renderer.width/2 - width/2
    display.y = gameControl.renderer.height/2 - height/1.6

    @slotHoverDisplay =  new PIXI.Graphics()
    @slotHoverDisplay.beginFill(0xFFFFFF,1)
    @slotHoverDisplay.drawRect(-5, -5, @cellWidth+10, @cellHeight+10)
    @slotHoverDisplay.endFill()
    @slotHoverDisplay.visible = false
    @slotHoverDisplay.alpha = 0.5

    @width = width
    @height = height
    @grid = grid

    @display = display
    @display.addChild(@slotHoverDisplay)
    gameControl.worldDisplay.addChild(@display)

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

  onMouseMove: (event) ->
    bounds = new Rect(@display.x, @display.y, @width, @height)
    mX = event.layerX
    mY = event.layerY
    if bounds.isPointInside(mX, mY)
      x = (mX - @display.x) / @cellWidth
      y = (mY - @display.y) / @cellHeight
      slot = @grid.getSlot(Math.floor(x), Math.floor(y))
      @hoveringSlot = slot
      if @hoveringSlot != null
        @slotHoverDisplay.visible = true
        @slotHoverDisplay.x = slot.x * @cellWidth
        @slotHoverDisplay.y = slot.y * @cellHeight

  onKeyDown: (event) ->
    if event.keyCode == Inputs.KEY_UP
      @hoveringSlot.setDirection(Direction.UP)
      console.log('set to up')
    if event.keyCode == Inputs.KEY_DOWN
      @hoveringSlot.setDirection(Direction.DOWN)
      console.log('set to down')
    if event.keyCode == Inputs.KEY_LEFT
      @hoveringSlot.setDirection(Direction.LEFT)
      console.log('set to left')
    if event.keyCode == Inputs.KEY_RIGHT
      @hoveringSlot.setDirection(Direction.RIGHT)
      console.log('set to right')

class LevelController
  constructor: (gameControl, grid, level) ->
    @gameControl = gameControl
    @gridControl = new GridController(gameControl, grid)

  onCoinAdd: (coin) ->
    coinControl = new CoinController(@gameControl, @, coin)

class CoinController
  constructor: (gameControl, levelControl, coin) ->
    display = new PIXI.Graphics()
    display.beginFill(0xCFCF00, 1)
    display.drawRect(8, 8, 32, 32)
    display.endFill()
    @display = display

    @gridControl = levelControl.gridControl
    @gridControl.display.addChild(@display)
    coin.addListener('onMove', () =>
      @display.x = coin.gridX * @gridControl.cellWidth
      @display.y = coin.gridY * @gridControl.cellHeight
    )

class GameController
  constructor: () ->
    @stage = new PIXI.Stage(0x10109F)
    @renderer = new PIXI.autoDetectRenderer(800, 600)
    @worldDisplay = new PIXI.DisplayObjectContainer()
    @stage.addChild(@worldDisplay)
    document.body.appendChild(@renderer.view)

onBodyLoad = () ->
  grid = new Grid(12, 9)
  level = new Level(grid)
  coin = new CoinEntity(level, 0, 0)
  coin2 = new CoinEntity(level, 1, 4)
  coin3 = new CoinEntity(level, 3, 8)
  grid.addWall(grid.getSlot(2,0), grid.getSlot(3, 0))
  grid.addWall(grid.getSlot(11,4), grid.getSlot(11, 5))

  gameControl = new GameController()

  levelControl = new LevelController(gameControl, grid, level)
  levelControl.gridControl.updateWalls(grid)

  levelControl.onCoinAdd(coin)
  levelControl.onCoinAdd(coin2)
  levelControl.onCoinAdd(coin3)

  gameControl.renderer.view.addEventListener('mousemove', (e) ->
    levelControl.gridControl.onMouseMove(e)
  )

  document.body.addEventListener('keydown', (e) ->
    levelControl.gridControl.onKeyDown(e)
  )

  updateCoins = () ->
    coin.move()
    coin2.move()
    coin3.move()
    setTimeout(updateCoins, 250)
  render = () ->
    gameControl.renderer.render(gameControl.stage)
    setTimeout(render, 1000/33)
  updateCoins()
  render()
