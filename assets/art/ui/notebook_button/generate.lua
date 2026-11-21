-- Rebuild the notebook HUD button with Aseprite --batch --script-param root=...
-- All artwork is drawn at native resolution using Resurrect 64 palette indices.
local root = assert(app.params.root, 'Pass --script-param root=/path/to/project')
local output = root .. '/assets/art/ui/'
local source = output .. 'notebook_button/'
local original = Palette { fromFile=root .. '/assets/palette/resurrect-64.gpl' }
local palette = Palette(#original + 1)
palette:setColor(0, Color { r=46, g=34, b=47, a=0 })
local colors = {}
for i=0,#original-1 do
  local c = original:getColor(i)
  palette:setColor(i+1, c)
  colors[string.format('%02x%02x%02x', c.red, c.green, c.blue)] = i+1
end
local function color(hex) return assert(colors[hex], 'Not in palette: ' .. hex) end
local C = {
  outline=color('2e222f'), ink=color('4c3e24'), paper=color('fdcbb0'),
  edge=color('ab947a'), cover=color('374e4a'), pale=color('c7dcd0'),
  green=color('165a4c'), gold=color('fbb954'), gray=color('625565'),
  lightgray=color('9babb2'), dim=color('3e3546')
}
local W,H = 128,32
local function blank(w,h) return Image(w,h,ColorMode.INDEXED) end
local function rect(img,x,y,w,h,value)
  for yy=y,y+h-1 do for xx=x,x+w-1 do
    if xx>=0 and yy>=0 and xx<img.width and yy<img.height then
      img:drawPixel(xx,yy,value)
    end
  end end
end
local function frame(img,x,y,w,h,value)
  rect(img,x,y,w,1,value); rect(img,x,y+h-1,w,1,value)
  rect(img,x,y,1,h,value); rect(img,x+w-1,y,1,h,value)
end
local function composite(dst,src,x,y)
  for yy=0,src.height-1 do for xx=0,src.width-1 do
    local value=src:getPixel(xx,yy)
    if value~=0 then dst:drawPixel(x+xx,y+yy,value) end
  end end
end

-- Original 16x16 pixel notebook symbol, not a rasterized Lucide icon.
local function notebook(img,x,y,ink,pages,binding)
  rect(img,x+2,y+1,10,14,ink)
  rect(img,x+3,y+2,8,11,pages)
  rect(img,x+3,y+2,2,11,binding)
  rect(img,x+3,y+13,8,1,binding)
  rect(img,x+6,y+4,4,1,ink)
  rect(img,x+6,y+6,3,1,ink)
  rect(img,x+6,y+8,4,1,ink)
  rect(img,x+1,y+4,3,1,ink)
  rect(img,x+1,y+10,3,1,ink)
  -- Small pencil at the right edge.
  for k=0,5 do
    img:drawPixel(x+14-math.floor(k/2),y+3+k,ink)
    img:drawPixel(x+13-math.floor(k/2),y+3+k,binding)
  end
  img:drawPixel(x+10,y+9,ink)
end

local states = {'active','rollover','pressed','disabled','focus'}
local images = {}
for _,name in ipairs(states) do
  local img=blank(W,H)
  if name=='focus' then
    -- TextureButton draws texture_focused ON TOP of the current state.
    -- Keep the entire center transparent, including its icon and label areas.
    frame(img,0,0,W,H,C.outline)
    frame(img,1,1,W-2,H-2,C.gold)
    rect(img,0,0,1,1,0); rect(img,W-1,0,1,1,0)
    rect(img,0,H-1,1,1,0); rect(img,W-1,H-1,1,1,0)
  else
    local pressed=name=='pressed'
    local disabled=name=='disabled'
    local hover=name=='rollover'
    local y=pressed and 3 or 2
    local fill=disabled and C.lightgray or (pressed and C.edge or (hover and C.pale or C.paper))
    local ink=disabled and C.gray or C.ink
    local shadow=disabled and C.dim or C.cover
    local top=disabled and C.edge or (pressed and C.cover or (hover and C.gold or C.pale))
    -- Fixed canvas and stable hit area. Pressed content moves exactly 1px down.
    rect(img,3,4,123,27,C.outline)
    rect(img,3,4,122,26,shadow)
    rect(img,2,y,123,27,C.outline)
    rect(img,3,y+1,121,25,fill)
    rect(img,3,y+1,121,1,top)
    rect(img,3,y+2,1,23,top)
    rect(img,4,y+24,120,1,disabled and C.edge or C.edge)
    rect(img,123,y+2,1,23,disabled and C.edge or C.edge)
    notebook(img,8,8+(pressed and 1 or 0),ink,fill,disabled and C.edge or C.cover)
    local keyY=8+(pressed and 1 or 0)
    rect(img,97,keyY+1,23,16,shadow)
    rect(img,96,keyY,23,16,ink)
    rect(img,97,keyY+1,21,14,disabled and C.edge or (pressed and C.paper or C.edge))
    if not pressed then rect(img,97,keyY+1,21,1,disabled and C.lightgray or C.paper) end
  end
  images[name]=img
  local sprite=Sprite(W,H,ColorMode.INDEXED)
  sprite:setPalette(palette)
  sprite.transparentColor=0
  sprite.cels[1].image=img
  sprite:saveAs(output .. 'ui_button_notebook_' .. name .. '.png')
  sprite:close()
end

-- Editable source: one named frame per exported state.
local master=Sprite(W,H,ColorMode.INDEXED)
master:setPalette(palette)
master.transparentColor=0
master.layers[1].name='Button artwork (labels are rendered in Godot)'
for i,name in ipairs(states) do
  if i>1 then master:newFrame() end
  master.cels[i].image=images[name]
  local tag=master:newTag(i,i)
  tag.name=name
  master.frames[i].duration=0.2
end
master:saveAs(source .. 'ui_button_notebook.aseprite')
master:close()

-- Preview-only bitmap lettering. Production textures deliberately have no text.
local glyphs={
 ['A']={'01110','10001','10001','11111','10001','10001','10001'},
 ['B']={'11110','10001','10001','11110','10001','10001','11110'},
 ['C']={'01111','10000','10000','10000','10000','10000','01111'},
 ['D']={'11110','10001','10001','10001','10001','10001','11110'},
 ['E']={'11111','10000','10000','11110','10000','10000','11111'},
 ['F']={'11111','10000','10000','11110','10000','10000','10000'},
 ['H']={'10001','10001','10001','11111','10001','10001','10001'},
 ['I']={'111','010','010','010','010','010','111'},
 ['L']={'10000','10000','10000','10000','10000','10000','11111'},
 ['M']={'10001','11011','10101','10101','10001','10001','10001'},
 ['N']={'10001','11001','11001','10101','10011','10011','10001'},
 ['O']={'01110','10001','10001','10001','10001','10001','01110'},
 ['P']={'11110','10001','10001','11110','10000','10000','10000'},
 ['R']={'11110','10001','10001','11110','10100','10010','10001'},
 ['S']={'01111','10000','10000','01110','00001','00001','11110'},
 ['T']={'11111','00100','00100','00100','00100','00100','00100'},
 ['U']={'10001','10001','10001','10001','10001','10001','01110'},
 ['V']={'10001','10001','10001','10001','10001','01010','00100'},
 ['a']={'00000','00000','01110','00001','01111','10001','01111'},
 ['b']={'10000','10000','11110','10001','10001','10001','11110'},
 ['Б']={'11111','10000','10000','11110','10001','10001','11110'},
 ['л']={'00000','00000','01111','01001','01001','01001','10001'},
 ['о']={'00000','00000','01110','10001','10001','10001','01110'},
 ['к']={'00000','00000','10001','10010','11100','10010','10001'},
 ['н']={'00000','00000','10001','10001','11111','10001','10001'},
 ['т']={'00000','00000','11111','00100','00100','00100','00100'}
}
local function text(img,value,x,y,ink)
  for _,code in utf8.codes(value) do
    local ch=utf8.char(code)
    local g=glyphs[ch]
    if g then
      for row,bits in ipairs(g) do for col=1,#bits do
        if bits:sub(col,col)=='1' then img:drawPixel(x+col-1,y+row-1,ink) end
      end end
      x=x+#g[1]+1
    else x=x+4 end
  end
end
local preview=blank(232,216)
rect(preview,0,0,preview.width,preview.height,C.cover)
local rows={{'NORMAL','active'},{'HOVER','rollover'},{'PRESSED','pressed'},{'FOCUS','active'},{'DISABLED','disabled'}}
for i,row in ipairs(rows) do
  local y=12+(i-1)*40
  text(preview,row[1],10,y+12,C.pale)
  composite(preview,images[row[2]],94,y)
  if row[1]=='FOCUS' then composite(preview,images.focus,94,y) end
  local dy=row[2]=='pressed' and 1 or 0
  local ink=row[2]=='disabled' and C.gray or C.ink
  text(preview,'Блокнот',94+33,y+12+dy,ink)
  text(preview,'Tab',94+99,y+12+dy,ink)
end
local board=Sprite(preview.width,preview.height,ColorMode.INDEXED)
board:setPalette(palette)
board.transparentColor=0
board.cels[1].image=preview
board:saveAs(source .. 'ui_button_notebook_preview.png')
app.command.SpriteSize { ui=false, width=preview.width*3, height=preview.height*3, method='nearest-neighbor' }
board:saveAs(source .. 'ui_button_notebook_preview_3x.png')
board:close()

-- Validate the exported files, not just the in-memory drawings.
for _,name in ipairs(states) do
  local sprite=app.open(output .. 'ui_button_notebook_' .. name .. '.png')
  assert(sprite.width==W and sprite.height==H, 'Wrong dimensions: '..name)
  assert(sprite.colorMode==ColorMode.INDEXED, 'Expected indexed PNG: '..name)
  local image=sprite.cels[1].image
  local p=sprite.palettes[1]
  for pixel in image:pixels() do
    local c=p:getColor(pixel())
    assert(c.alpha==0 or c.alpha==255, 'Partial alpha: '..name)
    if c.alpha==255 then
      assert(colors[string.format('%02x%02x%02x',c.red,c.green,c.blue)], 'Non-palette color: '..name)
    end
  end
  if name=='focus' then assert(image:getPixel(64,16)==0, 'Focus must be a transparent overlay') end
  sprite:close()
end
print('Saved and validated five 128x32 indexed PNG states, Aseprite source, and two previews.')
