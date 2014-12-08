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
      slotA.walls.up = true
      slotB.walls.down = true
    else if yDiff > 0
      slotA.walls.down = true
      slotB.walls.up = true

class GridSlot
  constructor: (grid, x, y) ->
    @grid = grid
    @x = x
    @y = y
    @direction = null
    @walls = {
      left: false,
      up: false,
      right: false,
      down: false
    }

  # Returns neighbors in 4 directions.
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

  # Returns true if slot has a neighbor in direction.
  hasNeighbor: (dir) ->
    x = @x
    y = @y
    mag = Direction.mag(dir)
    x += mag.x
    y += mag.y
    return ((x >= 0 and y >= 0) and (x < @grid.hCells and y < @grid.vCells))


class MovingEntity
  constructor: (grid, gridX=0, gridY=0) ->
    @grid = grid
    @gridX = gridX
    @gridY = gridY

    @lastDir = null # Last direction we moved from.
    @currentDir = null
    @dirPreference = Direction.fromStringArray(['up', 'right', 'down', 'left']) # Preferred directions are first.

  getSlot: () ->
    @grid.getSlot(@gridX, @gridY)

  # Returns true if it's possible to move in a direction.
  isPossibleMove: (dir) ->
    slot = @getSlot()
    if slot.hasNeighbor(dir) # Make sure there's a neighbor to move to.
      return !slot.walls[Direction.str(dir)] # Make sure there's not a wall in the way.
    return false

  # Moves the entity to the next slot based on a movement algorithm.
  move: () ->
    slot = @getSlot()
    dir = null

    # Continue in the same direction if possible.
    if @currentDir != null
      dir = @currentDir if @isPossibleMove(@currentDir)

    # If current direction is not possible then find a new direction.
    if dir == null
      for prefDir in @dirPreference
        continue if prefDir == @lastDir or prefDir == @currentDir # Don't move to the direction we came from or current direction (since we proved it impossible above).
        if @isPossibleMove(prefDir)
            dir = prefDir
            break

    dir = @lastDir if dir == null
    @currentDir = dir
    @lastDir = Direction.opposite(dir)

    mag = Direction.mag(dir)
    @gridX += mag.x
    @gridY += mag.y
