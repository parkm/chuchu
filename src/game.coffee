Direction = {}
Direction.RIGHT = 0
Direction.DOWN = 1
Direction.LEFT = 2
Direction.UP = 3
Direction.opposite = (dir) -> # Returns the opposite direction.
  return null if dir == null
  if dir == Direction.RIGHT
    return Direction.LEFT
  else if dir == Direction.DOWN
    return Direction.UP
  else if dir == Direction.LEFT
    return Direction.RIGHT
  else if dir == Direction.UP
    return Direction.DOWN
Direction.fromStringArray = (array) -> # Converts a string array of direction names into direction constants.
  out = []
  for str in array
    if str == 'right'
      out.push(Direction.RIGHT)
    else if str == 'down'
      out.push(Direction.DOWN)
    else if str == 'left'
      out.push(Direction.LEFT)
    else if str == 'up'
      out.push(Direction.UP)
  return out
Direction.str = (dir) -> # Converts a direction to a string.
  if dir == Direction.RIGHT
    return 'right'
  else if dir == Direction.DOWN
    return 'down'
  else if dir == Direction.LEFT
    return 'left'
  else if dir == Direction.UP
    return 'up'
Direction.mag = (dir) -> # Gets the magnitude of a direction.
  x = y = 0
  if dir == Direction.RIGHT
    x++
  else if dir == Direction.DOWN
    y++
  else if dir == Direction.LEFT
    x--
  else if dir == Direction.UP
    y--
  return {x:x, y:y}

class Grid
  constructor: (hCells, vCells) ->
    @slots = []
    @hCells = hCells
    @vCells = vCells
    for y in [0..vCells-1] by 1
      for x in [0..hCells-1] by 1
        @slots.push(new GridSlot(this, x, y))

  getSlot: (x, y) ->
    slot = @slots[x + (y * @vCells)]
    if slot == undefined
      return null
    else
      return slot

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

  # Returns neighbors in 4 direction.
  getNeighbors: () ->
    slots = [
      @grid.getSlot(@x,   @y-1),
      @grid.getSlot(@x+1, @y),
      @grid.getSlot(@x,   @y+1),
      @grid.getSlot(@x-1, @y)
    ]
    out = []
    for slot in slots
      if slot != null
        out.push(slot)
    return out
