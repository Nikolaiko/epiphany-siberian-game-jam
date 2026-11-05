local root = assert(app.params.root, 'Pass --script-param root=<project directory>')
local directory = root .. '/assets/art/style-test/'
local source = directory .. 'Full-body_pixel_art_char-Idle (1)/Idle/'
local colors = Palette { fromFile=root .. '/assets/palette/resurrect-64.gpl' }
local palette = Palette(#colors + 1)
palette:setColor(0, Color { r=0, g=0, b=0, a=0 })
for i=0,#colors-1 do palette:setColor(i+1, colors:getColor(i)) end

-- Remove the walking export's extra transparent padding without resampling pixels.
-- Rows: eight idle directions, six south walking frames, six north walking frames.
local atlas = Sprite(256, 96, ColorMode.INDEXED)
atlas:setPalette(palette)
atlas.transparentColor = 0
local sheet = Image(256, 96, ColorMode.INDEXED)
local cache = {}
local function addFrame(path, column, row)
  local sprite = app.open(source .. path)
  assert((sprite.width == 32 or sprite.width == 48) and sprite.height == sprite.width,
    'Unexpected source dimensions: ' .. path)
  local padding = (sprite.width - 32) / 2
  local original = Image(sprite.width, sprite.height, ColorMode.RGB)
  original:drawSprite(sprite, 1)
  for pixel in original:pixels() do
    if app.pixelColor.rgbaA(pixel()) >= 128 then
      assert(pixel.x >= padding and pixel.x < padding+32 and pixel.y >= padding and pixel.y < padding+32,
        'Cropping would clip visible pixels: ' .. path)
    end
  end
  local frame = Image(32, 32, ColorMode.RGB)
  frame:drawImage(original, Point(-padding, -padding))
  for pixel in frame:pixels() do
    local value = pixel()
    local index = 0
    if app.pixelColor.rgbaA(value) >= 128 then
      index = cache[value]
      if not index then
        local r, g, b = app.pixelColor.rgbaR(value), app.pixelColor.rgbaG(value), app.pixelColor.rgbaB(value)
        local distance = math.huge
        for i=0,#colors-1 do
          local color = colors:getColor(i)
          local candidate = (r-color.red)^2 + (g-color.green)^2 + (b-color.blue)^2
          if candidate < distance then distance, index = candidate, i+1 end
        end
        cache[value] = index
      end
    end
    sheet:drawPixel(column*32 + pixel.x, row*32 + pixel.y, index)
  end
  sprite:close()
end

for i, direction in ipairs({'south', 'south-east', 'east', 'north-east', 'north', 'north-west', 'west', 'south-west'}) do
  addFrame('rotations/' .. direction .. '.png', i-1, 0)
end
for row, direction in ipairs({'south', 'north'}) do
  for frame=0,5 do
    addFrame(string.format('animations/Walking/%s/frame_%03d.png', direction, frame), frame, row)
  end
end
atlas.cels[1].image = sheet
assert(atlas.width == 256 and atlas.height == 96)
atlas:saveAs(directory .. 'char_student_atlas.aseprite')
atlas:saveAs(directory .. 'char_student_atlas.png')
app.sprite = atlas
app.command.SpriteSize { ui=false, width=1024, height=384, method='nearest-neighbor' }
atlas:saveAs(directory .. 'char_student_atlas_preview_4x.png')
atlas:close()
print('Student atlas: 256x96, 32x32 frames, Resurrect 64, binary transparency')
