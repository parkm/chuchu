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
  ok(slotA.walls.top == true, 'bottom slot gets top wall')
  ok(slotB.walls.bottom == true, 'top slot gets bottom wall')

  slotA = grid.getSlot(1, 0)
  slotB = grid.getSlot(1, 1)
  grid.addWall(slotA, slotB)
  ok(slotA.walls.bottom == true, 'top slot gets bottom wall')
  ok(slotB.walls.top == true, 'bottom slot gets top wall')

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
