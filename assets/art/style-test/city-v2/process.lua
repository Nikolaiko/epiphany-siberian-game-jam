local directory = app.params.root .. '/assets/art/style-test/city-v2/'
local original = Palette { fromFile=app.params.root .. '/assets/palette/resurrect-64.gpl' }
local palette = Palette(#original+1)
palette:setColor(0,Color{r=0,g=0,b=0,a=0})
for i=0,#original-1 do palette:setColor(i+1,original:getColor(i)) end
local colors, cache = {}, {}
local function subset(hexes)
  colors,cache = {},{}
  for i=0,#original-1 do
    local c=original:getColor(i)
    if hexes:find(string.format('%02x%02x%02x',c.red,c.green,c.blue),1,true) then table.insert(colors,i) end
  end
end
local buildingColors='2e222f 3e3546 625565 966c6c ab947a 694f62 7f708a 9babb2 313638 45293f 9e4539 cd683d e6904e fdcbb0 323353 484a77'
local majoritySampling = true
local function index(value)
  if app.pixelColor.rgbaA(value)<128 then return 0 end
  if cache[value] then return cache[value] end
  local r,g,b=app.pixelColor.rgbaR(value),app.pixelColor.rgbaG(value),app.pixelColor.rgbaB(value)
  local best,distance=1,math.huge
  for _,i in ipairs(colors) do
    local c=original:getColor(i)
    local d=(r-c.red)^2+(g-c.green)^2+(b-c.blue)^2
    if d<distance then best,distance=i+1,d end
  end
  cache[value]=best
  return best
end
local function sample(dst,src,sx,sy,sw,sh,dx,dy,dw,dh)
  for y=0,dh-1 do for x=0,dw-1 do
    local px=math.min(src.width-1,math.floor(sx+(x+0.5)*sw/dw))
    local py=math.min(src.height-1,math.floor(sy+(y+0.5)*sh/dh))
    local selected=index(src:getPixel(px,py))
    if majoritySampling then
      -- Select the most frequent palette color in the source footprint.
      -- Unlike averaging, this introduces no blended colors or soft alpha.
      local counts, bestCount={},0
      for yy=math.floor(sy+y*sh/dh),math.min(src.height-1,math.ceil(sy+(y+1)*sh/dh)-1) do
        for xx=math.floor(sx+x*sw/dw),math.min(src.width-1,math.ceil(sx+(x+1)*sw/dw)-1) do
          local value=index(src:getPixel(xx,yy))
          counts[value]=(counts[value] or 0)+1
          if counts[value]>bestCount then selected,bestCount=value,counts[value] end
        end
      end
    end
    dst:drawPixel(dx+x,dy+y,selected)
  end end
end
local function save(image,name)
  local s=Sprite(image.width,image.height,ColorMode.INDEXED)
  s:setPalette(palette)
  s.transparentColor=0
  s.cels[1].image=image
  s:saveAs(directory..name..'.aseprite')
  s:saveAs(directory..name..'.png')
  app.command.SpriteSize{ui=false,width=image.width*2,height=image.height*2,method='nearest-neighbor'}
  s:saveAs(directory..name..'_preview_2x.png')
  s:close()
end
local function bounds(image,region)
  local x0,y0,x1,y1=region[1],region[2],region[1]+region[3]-1,region[2]+region[4]-1
  local left,top,right,bottom=x1,y1,x0,y0
  for y=y0,y1 do for x=x0,x1 do
    if app.pixelColor.rgbaA(image:getPixel(x,y))>=128 then
      left,top,right,bottom=math.min(left,x),math.min(top,y),math.max(right,x),math.max(bottom,y)
    end
  end end
  return left,top,right-left+1,bottom-top+1
end
subset(buildingColors)
if app.params.asset ~= 'terrain' then
for _,item in ipairs({{'home',144,128},{'museum',208,144},{'archive',176,128},{'cinema',192,144},{'university',320,160},{'cafe',128,128}}) do
  local s=app.open(directory..item[1]..'_source.png')
  local source=s.cels[1].image
  local x,y,w,h=bounds(source,{0,0,source.width,source.height})
  local output=Image(item[2],item[3],ColorMode.INDEXED)
  sample(output,source,x,y,w,h,0,0,item[2],item[3])
  s:close()
  save(output,item[1])
end
end

local s=app.open(directory..'terrain_source.png')
local source=s.cels[1].image
local terrain=Image(64,64,ColorMode.INDEXED)
majoritySampling=false
subset('625565 3e3546 7f708a ab947a 966c6c 374e4a 547e64 313638 4c3e24 9e4539 cd683d 9babb2')
for y=0,3 do for x=0,3 do
  -- Quiet base surfaces; sparse detail belongs to the dedicated variant tiles.
  if y==0 and x==0 then subset('625565')
  elseif y==0 and x==1 then subset('625565 7f708a')
  elseif y==0 and x==2 then subset('ab947a 625565')
  elseif y==0 and x==3 then subset('ab947a 625565 9e4539 cd683d')
  elseif y==1 and x==0 then subset('374e4a')
  elseif y==1 and x==1 then subset('374e4a 9e4539 cd683d')
  elseif y==1 then subset('4c3e24 625565 374e4a')
  elseif y==2 then subset('625565 9babb2')
  else subset('625565 3e3546 7f708a ab947a') end
  local step=source.width/4
  sample(terrain,source,x*step+6,y*step+6,step-12,step-12,x*16,y*16,16,16)
end end
s:close()
save(terrain,'terrain')

majoritySampling=true
if app.params.asset ~= 'terrain' then
subset(buildingColors..' 676633 547e64')
s=app.open(directory..'props_source.png')
source=s.cels[1].image
-- Source regions follow the visible object layout; trim each silhouette before resizing.
local props={
 {'tree_ochre',{0,0,627,670},64,64},
 {'tree_olive',{627,0,627,670},64,64},
 {'bench',{88,700,562,272},32,16},
 {'shrub',{60,975,425,260},24,16},
 {'litter_bin',{490,975,170,260},16,24},
 {'lamp_lit',{770,670,170,560},16,48},
 {'lamp_unlit',{995,670,150,560},16,48},
}
for _,item in ipairs(props) do
  local x,y,w,h=bounds(source,item[2])
  local output=Image(item[3],item[4],ColorMode.INDEXED)
  sample(output,source,x,y,w,h,0,0,item[3],item[4])
  save(output,item[1])
end
s:close()
end
print('City v2 assets saved: daytime palette, six building atlases, terrain and seven props.')
