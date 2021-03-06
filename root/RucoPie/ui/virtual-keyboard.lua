local constants = require 'constants'
local utils = require 'utils'
local colors = require 'colors'

local virtualKeyboard = {
  active = false,
  grid = {},
  cellWidth = 5 + _G.font:getWidth('A'),
  cellHeight = 5 + _G.font:getHeight(),
  padding = 4,
  typedText = {},
  getCaption = function()
    return utils.getCaption({
      {'A', 'Add'},
      {'B', 'Remove'},
      {'Start', 'Confirm'},
      {'Select', 'Cancel'}
    })
  end,
  index = { 1, 1 } -- row and column
}

function virtualKeyboard:indexAt(x, y)
  return self.index[1] == y and self.index[2] == x
end

function virtualKeyboard:openFor(textField)
  self.active = true
  self.textField = textField
end

function virtualKeyboard:hide()
  self.active = false
end

function virtualKeyboard:confirm()
  if self.textField then
    self.textField.value = table.concat(self.typedText)
    self.textField = nil
    self.active = false
    self.typedText = {}
  end
end


function virtualKeyboard:cancel()
  if self.textField then
    self.textField = nil
    self.active = false
    self.typedText = {}
  end
end

function virtualKeyboard:remove()
  if #self.typedText >= 1 then
    table.remove(self.typedText)
  end
end

function virtualKeyboard:getSelectedItem()
  local y = self.index[1]
  local x = self.index[2]

  if self.grid[y] then
    if self.grid[y][x] then
      return self.grid[y][x]
    end
  end
end

function virtualKeyboard:add(element) -- adds selected grid element
  table.insert(self.typedText, element)
end

function virtualKeyboard:setGrid(grid) -- two-dimensional flat table
  self.grid = grid
  self.w, self.h, self.hItems, self.vItems = (function ()
    local w, h, hItems, vItems = 0, 0, 0, 0
    for y = 1, #self.grid do
      local currentRowWidth = 0
      local currentHorizontalItems = 0
      for x = 1, #self.grid[y] do
        currentRowWidth = currentRowWidth + self.cellWidth
        currentHorizontalItems = currentHorizontalItems + 1
      end

      if currentRowWidth > w then
        w = currentRowWidth
      end
      if currentHorizontalItems > hItems then
        hItems = currentHorizontalItems
      end
      h = h + self.cellHeight
      vItems = vItems + 1
    end

    return w, h, hItems, vItems
  end)()
end

function virtualKeyboard:left()
  self.index[2] = self.index[2] - 1
  if self.index[2] < 1 then
    self.index[2] = self.hItems
  end
  if not self:getSelectedItem() then -- skip empty cells, same for the next 3
    self:left()
  end
end

function virtualKeyboard:right()
  self.index[2] = self.index[2] + 1
  if self.index[2] > self.hItems then
    self.index[2] = 1
  end
  if not self:getSelectedItem() then
    self:right()
  end
end

function virtualKeyboard:up()
  self.index[1] = self.index[1] - 1
  if self.index[1] < 1 then
    self.index[1] = self.vItems
  end
  if not self:getSelectedItem() then
    self:up()
  end
end

function virtualKeyboard:down()
  self.index[1] = self.index[1] + 1
  if self.index[1] > self.vItems then
    self.index[1] = 1
  end
  if not self:getSelectedItem() then
    self:down()
  end
end

function virtualKeyboard:drawBackground(gridX, gridY)
  -- love.graphics.setColor(colors:withOpacity('black', 0.5))
  -- love.graphics.rectangle('line',
  --   gridX - self.padding,
  --   gridY - self.padding - self.cellHeight,
  --   self.w + self.padding * 2,
  --   self.h + self.padding * 2 + self.cellHeight
  -- )
end

function virtualKeyboard:drawCursor(x, y, gridX, gridY)
  if self:indexAt(x, y) then
    love.graphics.setColor(colors.green)
    love.graphics.rectangle('fill',
      gridX + (x - 1) * self.cellWidth - 1,
      gridY + (y - 1) * self.cellHeight,
      self.cellWidth,
      self.cellHeight
    )
  end
end

function virtualKeyboard:drawElement(element, x, y, gridX, gridY)
  love.graphics.setColor(colors.white)
  utils.pp(element,
    (gridX + (x - 1) * self.cellWidth) + self.cellWidth / 2 - _G.font:getWidth(element) / 2,
    (gridY + (y - 1) * self.cellHeight) + self.cellHeight / 2 - _G.font:getHeight() / 2,
    _G.getPrintingParameters({ shadow = self:getSelectedItem() ~= element })
  )
end

function virtualKeyboard:drawTypedText(gridX, gridY)
  local text = table.concat(self.typedText)
  local xText = constants.CANVAS_WIDTH / 2 - _G.font:getWidth(text) / 2
  love.graphics.line(gridX, gridY - self.padding, gridX + self.w - 1, gridY - self.padding)
  utils.pp(text, xText, gridY - self.cellHeight, _G.getPrintingParameters())
end

function virtualKeyboard:draw()
  if not self.active then return end

  local gridX = constants.CANVAS_WIDTH / 2 - self.w / 2
  local gridY = constants.CANVAS_HEIGHT / 2 - self.h / 2

  self:drawBackground(gridX, gridY)

  for y = 1, #self.grid do
    local row = self.grid[y]

    for x = 1, #row do
      local element = row[x]
      self:drawCursor(x, y, gridX, gridY)
      self:drawElement(element, x, y, gridX, gridY)
    end
  end

  self:drawTypedText(gridX, gridY)
end

return virtualKeyboard
