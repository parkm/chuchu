# TODO: Add tests for the Direction object.

test('grid size correct', () ->
  grid = new Grid(12, 9)
  ok(grid.slots.length == 108, '12x9 size is 108')
  grid = new Grid(4, 4)
  ok(grid.slots.length == 16, '4x4 size is 16')
)

test('Grid.getSlot', () ->
  grid = new Grid(4, 4)
  for y in [0..grid.vCells-1] by 1
    for x in [0..grid.hCells-1] by 1
      slot = grid.getSlot(x, y)
      ok(slot.x == x and slot.y == y, "getSlot(#{x}, #{y}) got slot #{slot.x}, #{slot.y}")
  ok(grid.getSlot(-1, -1) == null, 'getSlot(-1, -1) returns null')
  ok(grid.getSlot(4, 4) == null, 'getSlot(4, 4) returns null')
)

test('Grid.addWall', () ->
  grid = new Grid(3, 3)
  slotA = grid.getSlot(1, 1)
  slotB = grid.getSlot(1, 0)
  grid.addWall(slotA, slotB)
  ok(slotA.walls.up == true, 'bottom slot gets top wall')
  ok(slotB.walls.down == true, 'top slot gets bottom wall')

  slotA = grid.getSlot(1, 0)
  slotB = grid.getSlot(1, 1)
  grid.addWall(slotA, slotB)
  ok(slotA.walls.down == true, 'top slot gets bottom wall')
  ok(slotB.walls.up == true, 'bottom slot gets top wall')

  slotA = grid.getSlot(2, 1)
  slotB = grid.getSlot(1, 1)
  grid.addWall(slotA, slotB)
  ok(slotA.walls.left == true, 'furthest right gets left wall')
  ok(slotB.walls.right == true, 'furthest left gets right wall')

  slotA = grid.getSlot(1, 1)
  slotB = grid.getSlot(2, 1)
  grid.addWall(slotA, slotB)
  ok(slotA.walls.right == true, 'furthest left gets right wall')
  ok(slotB.walls.left == true, 'furthest right gets left wall')
)

test('GridSlot.getNeighbors', () ->
  grid = new Grid(3, 3)
  slotNeighbors = grid.getSlot(0, 0).getNeighbors()
  ok(slotNeighbors.length == 2, '0,0 has 2 neighbors')
  ok(slotNeighbors.indexOf(grid.getSlot(0, 1)) != -1, '0,0 has neighbor 0,1')
  ok(slotNeighbors.indexOf(grid.getSlot(1, 0)) != -1, '0,0 has neighbor 1,0')
  ok(slotNeighbors.indexOf(grid.getSlot(1, 1)) == -1, '0,0 does not have neighbor 1,1')

  slotNeighbors = grid.getSlot(1, 1).getNeighbors()
  ok(slotNeighbors.length == 4, '1,1 has 4 neighbors')
  ok(slotNeighbors.indexOf(grid.getSlot(1, 0)) != -1, '1,1 has neighbor 1,0')
  ok(slotNeighbors.indexOf(grid.getSlot(2, 1)) != -1, '1,1 has neighbor 2,1')
  ok(slotNeighbors.indexOf(grid.getSlot(1, 2)) != -1, '1,1 has neighbor 1,2')
  ok(slotNeighbors.indexOf(grid.getSlot(0, 1)) != -1, '1,1 has neighbor 0,1')
)

test('GridSlot.hasNeighbor', () ->
  grid = new Grid(3, 3)
  slot = grid.getSlot(0, 0)
  ok(slot.hasNeighbor(Direction.UP) == false, '0,0 has no up neighbor')
  ok(slot.hasNeighbor(Direction.LEFT) == false, '0,0 has no left neighbor')
  ok(slot.hasNeighbor(Direction.RIGHT) == true, '0,0 has right neighbor')
  ok(slot.hasNeighbor(Direction.DOWN) == true, '0,0 has down neighbor')

  slot = grid.getSlot(1, 1)
  ok(slot.hasNeighbor(Direction.UP) == true, '1,1 has up neighbor')
  ok(slot.hasNeighbor(Direction.LEFT) == true, '1,1 has left neighbor')
  ok(slot.hasNeighbor(Direction.RIGHT) == true, '1,1 has right neighbor')
  ok(slot.hasNeighbor(Direction.DOWN) == true, '1,1 has down neighbor')

  slot = grid.getSlot(2, 2)
  ok(slot.hasNeighbor(Direction.RIGHT) == false, '2,2 has no right neighbor')
  ok(slot.hasNeighbor(Direction.DOWN) == false, '2,2 has no down neighbor')
  ok(slot.hasNeighbor(Direction.UP) == true, '2,2 has up neighbor')
  ok(slot.hasNeighbor(Direction.LEFT) == true, '2,2 has left neighbor')
)

test('MovingEntity.move', () ->
  ### Grid
  x|x|x x
      _
  x > v x

  > ^ > x

  x x x x
  ###
  grid = new Grid(4, 4)
  level = new Level(grid)
  grid.addWall(grid.getSlot(0,0), grid.getSlot(1, 0))
  grid.addWall(grid.getSlot(1,0), grid.getSlot(2, 0))
  grid.addWall(grid.getSlot(2,0), grid.getSlot(2, 1))

  grid.getSlot(0, 2).setDirection(Direction.RIGHT)
  grid.getSlot(1, 2).setDirection(Direction.UP)
  grid.getSlot(1, 1).setDirection(Direction.RIGHT)
  grid.getSlot(2, 1).setDirection(Direction.DOWN)
  grid.getSlot(2, 2).setDirection(Direction.RIGHT)

  path = Direction.fromStringArray(['down', 'down', 'right', 'up', 'right', 'down', 'right', 'up', 'up', 'left', 'right', 'down'])

  entity = new MovingEntity(level)
  x = 0
  y = 0
  for dir in path
    entity.move() # Should move down since no top neighbor and wall to the right.
    mag = Direction.mag(dir)
    x += mag.x
    y += mag.y
    correct = (entity.gridX == x and entity.gridY == y)
    if correct
      ok(true, "moved #{Direction.str(dir)}")
    else
      ok(false, "did not move #{Direction.str(dir)}")
)

test('CoinEntity.onPlayerSlotEnter', () ->
  ### Grid
  coin player
  ###
  grid = new Grid(2, 1)
  level = new Level(grid)
  player = new Player()
  grid.getSlot(1, 0).setOwner(player)
  coin = new CoinEntity(level, 0, 0)
  ok(level.entities.length == 1, 'coin added to level')
  ok(player.score == 0, 'player score is 0')
  coin.move() # Coin moves right, enters player owned slot.
  ok(player.score == 1, 'coin moved into player owned slot; player score is 1')
  ok(level.entities.length == 0, 'coin removed from level')
)

test('BombEntity.onPlayerSlotEnter', () ->
  ### Grid
  bomb player
  ###
  grid = new Grid(2, 1)
  level = new Level(grid)
  player = new Player()
  grid.getSlot(1, 0).setOwner(player)
  bomb = new BombEntity(level, 0, 0)
  ok(level.entities.length == 1, 'bomb added to level')
  ok(player.score == 0, 'player score is 0')
  bomb.move() # Coin moves right, enters player owned slot.
  ok(player.score == -1, 'bomb moved into player owned slot; player score is -1')
  ok(level.entities.length == 0, 'bomb removed from level')
)
