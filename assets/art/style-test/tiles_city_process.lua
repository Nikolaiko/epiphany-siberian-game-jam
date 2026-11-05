local root = app.params.root
local directory = root .. '/assets/art/style-test/'
local originalPalette = Palette { fromFile=root .. '/assets/palette/resurrect-64.gpl' }
local palette = Palette(#originalPalette + 1)
palette:setColor(0, Color { r=0, g=0, b=0, a=0 })
for i=0,#originalPalette-1 do palette:setColor(i+1, originalPalette:getColor(i)) end
local colorCache = {}
local activeColors = {}
local subsets = {
  terrain = '2e222f 3e3546 625565 966c6c ab947a 9babb2 4c3e24 676633 313638 374e4a 547e64 92a984 b2ba90 9e4539 cd683d e6904e',
  buildings = '2e222f 3e3546 625565 966c6c ab947a 694f62 7f708a 9babb2 4c3e24 313638 323353 484a77 9e4539 cd683d e6904e fbb954 fdcbb0',
  props = '2e222f 3e3546 625565 966c6c ab947a 9babb2 c7dcd0 4c3e24 676633 313638 374e4a 547e64 92a984 b2ba90 9e4539 cd683d e6904e fbb954 fdcbb0',
}

local function paletteIndex(value)
  if app.pixelColor.rgbaA(value) < 128 then return 0 end
  if colorCache[value] then return colorCache[value] end
  local r, g, b = app.pixelColor.rgbaR(value), app.pixelColor.rgbaG(value), app.pixelColor.rgbaB(value)
  local best, distance = 1, math.huge
  for _, i in ipairs(activeColors) do
    local c = originalPalette:getColor(i)
    local d = (r-c.red)^2 + (g-c.green)^2 + (b-c.blue)^2
    if d < distance then best, distance = i+1, d end
  end
  colorCache[value] = best
  return best
end

-- Nearest-neighbor sampling into exact tile allocations. No generated artwork is redrawn.
local function sample(destination, source, sx, sy, sw, sh, dx, dy, dw, dh)
  for y=0,dh-1 do
    for x=0,dw-1 do
      local px = math.min(source.width-1, math.floor(sx + (x+0.5)*sw/dw))
      local py = math.min(source.height-1, math.floor(sy + (y+0.5)*sh/dh))
      destination:drawPixel(dx+x, dy+y, paletteIndex(source:getPixel(px, py)))
    end
  end
end

local function save(image, name, previewScale)
  local sprite = Sprite(image.width, image.height, ColorMode.INDEXED)
  sprite:setPalette(palette)
  sprite.transparentColor = 0
  sprite.cels[1].image = image
  sprite:saveAs(directory .. name .. '.aseprite')
  sprite:saveAs(directory .. name .. '.png')
  if previewScale then
    app.command.SpriteSize { ui=false, width=image.width*previewScale, height=image.height*previewScale, method='nearest-neighbor' }
    sprite:saveAs(directory .. name .. '_preview_' .. previewScale .. 'x.png')
  end
  sprite:close()
end

local sheets = {}
for _, name in ipairs({'terrain', 'buildings', 'props'}) do
  activeColors, colorCache = {}, {}
  for i=0,#originalPalette-1 do
    local c = originalPalette:getColor(i)
    local hex = string.format('%02x%02x%02x',c.red,c.green,c.blue)
    if subsets[name]:find(hex,1,true) then table.insert(activeColors,i) end
  end
  local sourceSprite = app.open(directory .. 'tiles_city_' .. name .. '_source.png')
  local source = sourceSprite.cels[1].image
  assert(sourceSprite.colorMode == ColorMode.RGB)
  local sheet = Image(64, 64, ColorMode.INDEXED)
  if name == 'terrain' then
    -- Remove the thin separators introduced by generation before sampling each cell.
    local step = source.width / 4
    for row=0,3 do
      for col=0,3 do
        sample(sheet, source, col*step+8, row*step+8, step-16, step-16, col*16, row*16, 16, 16)
      end
    end
  elseif name == 'buildings' then
    -- Preserve the four continuous 16x32 door/window modules in the lower half.
    sample(sheet, source, 0, 0, source.width, source.height, 0, 0, 64, 64)
  else
    -- Repack source objects so trees and bench never cross their allocated tile regions.
    sample(sheet, source, 0, 8, 627, 660, 1, 1, 30, 30)
    sample(sheet, source, 627, 8, 627, 660, 33, 1, 30, 30)
    sample(sheet, source, 65, 716, 525, 258, 1, 33, 30, 14)
    sample(sheet, source, 35, 1000, 280, 232, 1, 50, 14, 12)
    sample(sheet, source, 370, 1000, 200, 232, 18, 49, 12, 14)
    sample(sheet, source, 710, 667, 180, 554, 35, 33, 10, 30)
    sample(sheet, source, 1022, 667, 180, 554, 51, 33, 10, 30)
  end
  sourceSprite:close()
  sheets[name] = sheet
  save(sheet, 'tiles_city_' .. name, 4)
end

local atlas = Image(192, 64, ColorMode.INDEXED)
atlas:drawImage(sheets.terrain, Point(0,0))
atlas:drawImage(sheets.buildings, Point(64,0))
atlas:drawImage(sheets.props, Point(128,0))
save(atlas, 'tiles_city_atlas', 4)

-- Assemble a small street from the actual exported tile pixels for visual QA.
local preview = Image(640, 360, ColorMode.INDEXED)
local function stamp(name, sx, sy, w, h, x, y)
  local source = sheets[name]
  for py=0,h-1 do
    for px=0,w-1 do
      local dx, dy = x+px, y+py
      if dx>=0 and dx<preview.width and dy>=0 and dy<preview.height then
        local index = source:getPixel(sx+px, sy+py)
        if index ~= 0 then preview:drawPixel(dx,dy,index) end
      end
    end
  end
end
for row=0,22 do
  for col=0,39 do
    if row>=10 and row<=14 then
      local sx, sy = 0, 0
      if row==12 then sx,sy=16,32 end
      if col==18 or col==19 then sx,sy=32,32 end
      stamp('terrain',sx,sy,16,16,col*16,row*16)
    elseif row==9 then
      stamp('terrain',0,48,16,16,col*16,row*16)
    elseif row==15 then
      stamp('terrain',32,48,16,16,col*16,row*16)
    elseif row>=7 and row<=17 then
      stamp('terrain',32,0,16,16,col*16,row*16)
    else
      stamp('terrain',0,16,16,16,col*16,row*16)
    end
  end
end
local function building(x,y,width,brick)
  for col=0,width-1 do
    stamp('buildings',brick and 16 or 0,0,16,16,x+col*16,y)
    stamp('buildings',brick and 48 or 32,0,16,16,x+col*16,y+16)
    for row=2,3 do stamp('buildings',brick and 16 or 0,16,16,16,x+col*16,y+row*16) end
  end
  stamp('buildings',brick and 16 or 0,32,16,32,x+math.floor(width/2)*16,y+32)
  stamp('buildings',brick and 48 or 32,16,16,16,x+16,y+32)
  stamp('buildings',brick and 48 or 32,16,16,16,x+(width-2)*16,y+32)
end
building(48,48,9,false)
building(240,48,8,true)
building(432,48,9,false)
for _, x in ipairs({16,208,400,592}) do stamp('props',0,0,32,32,x,80) end
for _, x in ipairs({32,160,400,560}) do stamp('props',32,32,16,32,x,108) end
for _, x in ipairs({80,240,448}) do stamp('props',0,32,32,16,x,264) end
for _, x in ipairs({32,144,352,512,592}) do stamp('props',32,0,32,32,x,300) end
for _, x in ipairs({176,384,544}) do stamp('props',0,48,16,16,x,280) end
stamp('props',16,48,16,16,280,264)
save(preview,'tiles_city_street_preview',2)
print('Saved three 64x64 tile sheets, 192x64 combined atlas and 640x360 street preview.')
