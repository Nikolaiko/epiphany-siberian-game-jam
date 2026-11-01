-- Reproducible Aseprite export; no game scenes or existing assets are modified.
local root=assert(app.params.root, 'Pass --script-param root=<project>')
local dir=root..'/assets/art/style-test/city-expansion/'
local file=assert(io.open(dir..'generation_manifest.json','r'))
local manifest=json.decode(file:read('*a'));file:close()
local original=Palette{fromFile=root..'/assets/palette/resurrect-64.gpl'}
local palette=Palette(#original+1);palette:setColor(0,Color{r=0,g=0,b=0,a=0})
for i=0,#original-1 do palette:setColor(i+1,original:getColor(i)) end
local colors,cache={},{}
local architecture='2e222f 3e3546 625565 966c6c ab947a 694f62 7f708a 9babb2 313638 45293f 9e4539 cd683d e6904e fdcbb0 323353 484a77'
local function subset(hexes)
 colors={};cache={}
 for i=0,#original-1 do local c=original:getColor(i)
  if hexes:find(string.format('%02x%02x%02x',c.red,c.green,c.blue),1,true) then
   colors[#colors+1]={i=i+1,r=c.red,g=c.green,b=c.blue}
  end
 end
end
local function index(v)
 if app.pixelColor.rgbaA(v)<128 then return 0 end
 if cache[v] then return cache[v] end
 local r,g,b=app.pixelColor.rgbaR(v),app.pixelColor.rgbaG(v),app.pixelColor.rgbaB(v)
 local best,distance=1,math.huge
 for _,c in ipairs(colors) do
  local d=(r-c.r)^2+(g-c.g)^2+(b-c.b)^2
  if d<distance then best,distance=c.i,d end
 end
 cache[v]=best;return best
end
local function source(name)
 local s=app.open(dir..'sources/'..name..'_source.png')
 local im=Image(s.width,s.height,ColorMode.RGB);im:drawSprite(s,1);s:close();return im
end
local function bounds(im,r)
 local l,t,rr,b=r[1]+r[3],r[2]+r[4],-1,-1
 for y=r[2],r[2]+r[4]-1 do for x=r[1],r[1]+r[3]-1 do
  if app.pixelColor.rgbaA(im:getPixel(x,y))>=128 then l,t,rr,b=math.min(l,x),math.min(t,y),math.max(rr,x),math.max(b,y) end
 end end
 assert(rr>=l and b>=t,'Empty extraction region')
 return l,t,rr-l+1,b-t+1
end
local function reduce(im,region,w,h)
 local sx,sy,sw,sh=bounds(im,region)
 -- Uniform scaling keeps native proportions; align the base to the lower edge.
 local scale=math.min(w/sw,h/sh)
 local dw,dh=math.max(1,math.floor(sw*scale+0.5)),math.max(1,math.floor(sh*scale+0.5))
 local dx,dy=math.floor((w-dw)/2),h-dh
 local out=Image(w,h,ColorMode.INDEXED)
 for y=0,dh-1 do for x=0,dw-1 do
  local counts,selected,bestCount={},0,0
  local total,opaque=0,0
  local x0,x1=math.floor(sx+x*sw/dw),math.min(im.width-1,math.ceil(sx+(x+1)*sw/dw)-1)
  local y0,y1=math.floor(sy+y*sh/dh),math.min(im.height-1,math.ceil(sy+(y+1)*sh/dh)-1)
  for yy=y0,y1 do for xx=x0,x1 do
   local c=index(im:getPixel(xx,yy));total=total+1
   if c~=0 then
    opaque=opaque+1;counts[c]=(counts[c] or 0)+1
    if counts[c]>bestCount then selected,bestCount=c,counts[c] end
   end
  end end
  -- Binary coverage. Retains thin branches/rails, removes translucent halos.
  if opaque/total<0.4 then selected=0 end
  out:drawPixel(dx+x,dy+y,selected)
 end end
 return out
end
local function save(im,path)
 local s=Sprite(im.width,im.height,ColorMode.INDEXED);s:setPalette(palette)
 s.transparentColor=0;s.cels[1].image=im
 s:saveAs(dir..path..'.aseprite');s:saveAs(dir..path..'.png');s:close()
end
local function blit(dst,im,x,y)
 for yy=0,im.height-1 do for xx=0,im.width-1 do
  local c=im:getPixel(xx,yy);if c~=0 then dst:drawPixel(x+xx,y+yy,c) end
 end end
end
local images,assets={},{}
local function export(name,im,category,sourceName)
 save(im,category..'/'..name);images[name]=im
 assets[#assets+1]={name=name,path=category..'/'..name..'.png',width=im.width,height=im.height,anchor={im.width/2,im.height},source='sources/'..sourceName..'_source.png'}
end
for _,job in ipairs(manifest.jobs) do if job.kind=='building' then
 subset(architecture)
 local im=source(job.name)
 export(job.name,reduce(im,{0,0,im.width,im.height},job.width,job.height),'buildings',job.name)
 print('Exported '..job.name)
end end
-- Regions measured from the generated sheets, rather than assuming the AI obeyed a grid.
local regions={
 props_street={{30,110,540,410},{575,275,365,245},{965,290,340,225},{1340,300,155,220},{190,760,100,170},{510,650,160,285},{875,525,150,410},{1190,680,255,260}},
 props_park={{40,20,350,690},{400,150,385,560},{790,35,420,680},{1220,480,290,235},{35,760,390,225},{510,725,215,260},{825,830,315,160},{1200,810,305,175}},
 props_courtyard={{15,160,440,265},{480,160,420,265},{915,210,405,220},{1330,70,430,365},{55,500,380,320},{560,510,280,310},{945,620,350,185},{1430,515,220,310}}
}
for _,job in ipairs(manifest.jobs) do if job.kind=='props' then
 subset(architecture..' 4c3e24 676633 374e4a 547e64 92a984 c7dcd0')
 local im=source(job.name)
 for i,item in ipairs(job.items) do
  export(item.name,reduce(im,regions[job.name][i],item.width,item.height),'props',job.name)
 end
 print('Exported '..job.name)
end end
local atlasBuildings=Image(1024,384,ColorMode.INDEXED)
local atlasProps=Image(512,288,ColorMode.INDEXED)
local bi,pi=0,0
for _,asset in ipairs(assets) do
 if asset.path:sub(1,10)=='buildings/' then
  local x=(bi%4)*256+math.floor((256-asset.width)/32)*16
  local y=math.floor(bi/4)*192+192-asset.height
  blit(atlasBuildings,images[asset.name],x,y)
  asset.atlas='atlases/buildings.png';asset.region={x,y,asset.width,asset.height}
  bi=bi+1
 else
  local x=(pi%8)*64
  -- Bus shelter uses 80px, allocate a custom 96px slot by using separate rows below.
  pi=pi+1
 end
end
-- Eight objects per category row; 96px-wide slots keep the 80px shelter separate.
atlasProps=Image(768,288,ColorMode.INDEXED);pi=0
for _,asset in ipairs(assets) do if asset.path:sub(1,6)=='props/' then
 local x=(pi%8)*96+math.floor((96-asset.width)/32)*16
 local y=math.floor(pi/8)*96+96-asset.height
 blit(atlasProps,images[asset.name],x,y)
 asset.atlas='atlases/props.png';asset.region={x,y,asset.width,asset.height};pi=pi+1
end end
save(atlasBuildings,'atlases/buildings');save(atlasProps,'atlases/props')
local out=assert(io.open(dir..'atlas_manifest.json','w'))
out:write(json.encode{tile_size=16,filter='nearest',palette='Resurrect 64',assets=assets});out:write('\n');out:close()
-- Contact sheet at native scale with calm palette background, only for preview.
local preview=Image(1024,720,ColorMode.INDEXED)
local bg=1;for i=0,#original-1 do local c=original:getColor(i);if c.red==55 and c.green==78 and c.blue==74 then bg=i+1 end end
preview:clear(bg)
blit(preview,atlasBuildings,0,16);blit(preview,atlasProps,128,416)
save(preview,'previews/overview')
local ps=Sprite(preview.width,preview.height,ColorMode.INDEXED);ps:setPalette(palette);ps.cels[1].image=preview
app.command.SpriteSize{ui=false,width=2048,height=1440,method='nearest-neighbor'}
ps:saveAs(dir..'previews/overview_2x.png');ps:close()
print('Saved 32 palette-indexed assets, two atlases and overview.')

