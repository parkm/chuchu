class Grid
  constructor: (hCells, vCells) ->
    @slots = []
    @hCells = hCells
    @vCells = vCells
    for y in [0..vCells-1] by 1
      for x in [0..hCells-1] by 1
        @slots.push(new GridSlot(this, x, y))

  getSlot: (x, y) ->
    return @slots[x + (y * @vCells)]

  # Adds a wall between the two slots. Slots must be neighbors to work correctly.
  addWall: (slotA, slotB) ->
    xDiff = slotB.x - slotA.x
    yDiff = slotB.y - slotA.y
    if xDiff < 0
      slotA.walls.left = true
      slotB.walls.right = true
    else if xDiff > 0
      slotA.walls.right = true
      slotB.walls.left = true

    if yDiff < 0
      slotA.walls.top = true
      slotB.walls.bottom = true
    else if yDiff > 0
      slotA.walls.bottom = true
      slotB.walls.top = true

class GridSlot
  constructor: (grid, x, y) ->
    @grid = grid
    @x = x
    @y = y
    @direction = null
    @walls = {
      left: false,
      top: false,
      right: false,
      bottom: false
    }
