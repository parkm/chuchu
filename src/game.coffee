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

class Rect
  constructor: (x, y, w, h) ->
    @x = x
    @y = y
    @w = w
    @h = h

  # Returns if point is inside rectangle
  isPointInside: (x, y) ->
    return (y >= @y and y <= @y + @h) and (x >= @x and x <= @x + @w)

class EventHandler
  constructor: () ->
    @listeners = {}

  addListener: (eventName, callback) ->
    listener = @listeners[eventName]
    if listener
      listener.push(callback)
    else
      @listeners[eventName] = [callback]

  emitEvent: (eventName, details={}) ->
    listener = @listeners[eventName]
    if listener
      for callback in listener
        callback(details)

class Game
  constructor: () ->
    @players = []

  addPlayer: (player) ->
    @players.push(player)

class Player
  constructor: (color) ->
    @score = 0
    @color = color

class Level extends EventHandler
  constructor: (grid) ->
    super()
    @grid = grid
    @entities = []

  addEntity: (entity) -> @entities.push(entity)
  removeEntity: (entity) -> @entities.splice(@entities.indexOf(entity), 1)

class Grid
  constructor: (hCells, vCells) ->
    @slots = []
    @hCells = hCells
    @vCells = vCells
    for y in [0..vCells-1] by 1
      for x in [0..hCells-1] by 1
        @slots.push(new GridSlot(this, x, y))

  getSlot: (x, y) ->
    # If x,y does not fit within the grid then return null.
    if !(x >= 0 and x < @hCells and y >= 0 and y < @vCells)
      return null

    slot = @slots[x + (y * @hCells)]
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
    @walls = {
      left: false,
      up: false,
      right: false,
      down: false
    }
    @direction = null
    @owner = null

  # Sets the owner of this slot to a player. MovingEntity's will apply to the player if it comes into contact with this slot.
  setOwner: (player) ->
    @owner = player
    @direction = null

  setDirection: (dir) ->
    return if @owner != null
    @direction = dir

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

class MovingEntity extends EventHandler
  constructor: (level, gridX=0, gridY=0) ->
    super()
    @level = level
    @level.addEntity(@)
    @gridX = gridX
    @gridY = gridY

    @lastDir = null # Last direction we moved from.
    @currentDir = null
    @dirPreference = Direction.fromStringArray(['up', 'right', 'down', 'left']) # Preferred directions are first.

  delete: () -> # Removes self from level.
    @level.removeEntity(@)

  getSlot: () ->
    @level.grid.getSlot(@gridX, @gridY)

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

    # Go in the direction of the current slot if possible.
    if slot.direction != null
      dir = slot.direction if @isPossibleMove(slot.direction)

    # Continue in the same direction if possible.
    if dir == null and @currentDir != null
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

    slot = @getSlot()
    if slot.owner != null
      @onPlayerSlotEnter(slot.owner, slot)

    @emitEvent('onMove')

  onPlayerSlotEnter: (slot) -> # Called when this entity enters a slot owned by a player.

class CoinEntity extends MovingEntity
  worth: 1
  onPlayerSlotEnter: (player, slot) ->
    player.score += @worth
    @level.emitEvent('onPlayerCollectCoin', {
      coin: @,
      player: player
    })
    @delete()

class BombEntity extends MovingEntity
  worth: -1
  onPlayerSlotEnter: (player, slot) ->
    player.score += @worth
    @delete()
