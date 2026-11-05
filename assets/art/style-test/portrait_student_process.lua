local root = app.params.root
local directory = root .. '/assets/art/style-test/'
local sourcePalette = Palette { fromFile=root .. '/assets/palette/resurrect-64.gpl' }
local palette = Palette(#sourcePalette + 1)
palette:setColor(0, Color { r=0, g=0, b=0, a=0 })
for i=0,#sourcePalette-1 do
  palette:setColor(i+1, sourcePalette:getColor(i))
end

for _, expression in ipairs({'calm', 'surprised'}) do
  local name = 'portrait_student_' .. expression
  local sprite = app.open(directory .. name .. '_source.png')
  assert(sprite and sprite.colorMode == ColorMode.RGB, 'Expected an RGBA source')
  app.command.SpriteSize { ui=false, width=64, height=64, method='nearest-neighbor' }
  -- Map directly to exact palette entries, without approximate lookup tables or dithering.
  local transparentCount, opaqueCount = 0, 0
  local converted = {}
  for _, cel in ipairs(sprite.cels) do
    local indexed = Image(cel.image.width, cel.image.height, ColorMode.INDEXED)
    for pixel in cel.image:pixels() do
      local value = pixel()
      if app.pixelColor.rgbaA(value) < 128 then
        indexed:drawPixel(pixel.x, pixel.y, 0)
        transparentCount = transparentCount + 1
      else
        local r, g, b = app.pixelColor.rgbaR(value), app.pixelColor.rgbaG(value), app.pixelColor.rgbaB(value)
        local bestIndex, bestDistance = 1, math.huge
        for i=0,#sourcePalette-1 do
          local color = sourcePalette:getColor(i)
          local distance = (r-color.red)^2 + (g-color.green)^2 + (b-color.blue)^2
          if distance < bestDistance then
            bestDistance, bestIndex = distance, i+1
          end
        end
        indexed:drawPixel(pixel.x, pixel.y, bestIndex)
        opaqueCount = opaqueCount + 1
      end
    end
    table.insert(converted, { cel=cel, image=indexed })
  end
  assert(transparentCount > 0 and opaqueCount > 0, 'Missing transparency or portrait')
  sprite:setPalette(palette)
  sprite.transparentColor = 0
  app.command.ChangePixelFormat { format='indexed', dithering='none' }
  for _, entry in ipairs(converted) do
    entry.cel.image = entry.image
  end
  assert(sprite.width == 64 and sprite.height == 64 and sprite.colorMode == ColorMode.INDEXED)
  sprite:saveAs(directory .. name .. '.aseprite')
  sprite:saveAs(directory .. name .. '.png')
  print(name .. ': 64x64, indexed, transparent background')
  app.command.SpriteSize { ui=false, width=256, height=256, method='nearest-neighbor' }
  sprite:saveAs(directory .. name .. '_preview_4x.png')
  sprite:close()
end
