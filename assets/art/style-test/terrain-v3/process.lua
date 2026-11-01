-- Aseprite: palette mapping and tile-aligned export of the generated source.
local root=assert(app.params.root)
local dir=root..'/assets/art/style-test/terrain-v3/'
local palette=Palette{fromFile=root..'/assets/palette/resurrect-64.gpl'}
local sourceSprite=app.open(dir..'terrain_source.png')
local source=Image(sourceSprite.width,sourceSprite.height,ColorMode.RGB)
source:drawSprite(sourceSprite,1);sourceSprite:close()
local colors,cache={},{}
local function subset(hexes)
 colors={};cache={}
 for i=0,#palette-1 do local c=palette:getColor(i)
  if hexes:find(string.format('%02x%02x%02x',c.red,c.green,c.blue),1,true) then
   colors[#colors+1]={r=c.red,g=c.green,b=c.blue,value=app.pixelColor.rgba(c.red,c.green,c.blue,255)}
  end
 end
end
local function nearest(v)
 if cache[v] then return cache[v] end
 local r,g,b=app.pixelColor.rgbaR(v),app.pixelColor.rgbaG(v),app.pixelColor.rgbaB(v)
 local best,dist=0,math.huge
 for _,c in ipairs(colors) do
  local d=(r-c.r)^2+(g-c.g)^2+(b-c.b)^2
  if d<dist then best,dist=c.value,d end
 end
 cache[v]=best;return best
end
local out=Image(64,96,ColorMode.RGB)
-- Boundaries measured from the source. Exclude generator's separator lines.
local rows={0,256,512,764,1018,1254,1536}
local cols={0,256,512,768,1024}
for row=0,5 do for col=0,3 do
 local allowed='625565 3e3546 7f708a 966c6c ab947a 9babb2 c7dcd0'
 if row==0 and col<2 then allowed='625565 3e3546 7f708a'
 elseif row==0 then allowed='ab947a 966c6c 625565 9e4539 cd683d e6904e'
 elseif row==1 and col<2 then allowed='374e4a 547e64 676633 9e4539 cd683d e6904e'
 elseif row==1 then allowed='4c3e24 676633 374e4a 547e64 ab947a'
 elseif row==2 then allowed='625565 3e3546 7f708a 9babb2 c7dcd0' end
 subset(allowed)
 local x0,x1=cols[col+1]+4,cols[col+2]-4
 local y0,y1=rows[row+1]+4,rows[row+2]-4
 for y=0,15 do for x=0,15 do
  local sx=math.floor(x0+(x+.5)*(x1-x0)/16)
  local sy=math.floor(y0+(y+.5)*(y1-y0)/16)
  out:drawPixel(col*16+x,row*16+y,nearest(source:getPixel(sx,sy)))
 end end
end end
-- Retouch at native resolution: repeatable slab joints, readable paint and
-- consistent curb junctions. Materials and leaf/grass details come from source.
local function rgb(hex)
 return app.pixelColor.rgba(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16),255)
end
local asphalt,paving,joint,stone,shadow,paint=rgb('625565'),rgb('ab947a'),rgb('966c6c'),rgb('9babb2'),rgb('3e3546'),rgb('c7dcd0')
local generated=Image(out)
for y=0,15 do for x=0,15 do
 local slab=paving
 if y==15 or x==15 then slab=joint end
 out:drawPixel(32+x,y,slab)
 local leaf=generated:getPixel(48+x,y)
 if leaf~=rgb('9e4539') and leaf~=rgb('cd683d') and leaf~=rgb('e6904e') then leaf=slab end
 out:drawPixel(48+x,y,leaf)
 out:drawPixel(x,y,asphalt)
 -- Flat fill tiles avoid a visible repeating field of identical tufts/dots.
 -- Generated texture and autumn accents remain in the adjacent variants.
 out:drawPixel(x,16+y,rgb('374e4a'))
 out:drawPixel(32+x,16+y,rgb('4c3e24'))
 -- A single unobtrusive repair patch, retaining the generated silhouette.
 if generated:getPixel(16+x,y)==shadow then out:drawPixel(16+x,y,rgb('694f62'))
 else out:drawPixel(16+x,y,asphalt) end
 for c=0,3 do
  local marked=(c==0 and x==7 and y>=2 and y<=9)
   or (c==1 and y==7 and x>=2 and x<=9)
   or (c==2 and ((x>=3 and x<=5) or (x>=11 and x<=13)))
   or (c==3 and ((y>=3 and y<=5) or (y>=11 and y<=13)))
  out:drawPixel(c*16+x,32+y,marked and paint or asphalt)
 end
end end
local function paved(row,col,x,y)
 if row==3 then
  if col==0 then return y<8 elseif col==1 then return x>=8
  elseif col==2 then return y>=8 else return x<8 end
 end
 if row==4 then
  if col==0 then return x<8 and y<8 elseif col==1 then return x>=8 and y<8
  elseif col==2 then return x>=8 and y>=8 else return x<8 and y>=8 end
 end
 if col==0 then return x<8 or y<8 elseif col==1 then return x>=8 or y<8
 elseif col==2 then return x>=8 or y>=8 else return x<8 or y>=8 end
end
for row=3,5 do for col=0,3 do for y=0,15 do for x=0,15 do
 local inside=paved(row,col,x,y)
 local value=inside and out:getPixel(32+x,y) or asphalt
 local near1,near2=false,false
 for _,d in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
  if paved(row,col,x+d[1],y+d[2])~=inside then near1=true end
  if paved(row,col,x+2*d[1],y+2*d[2])~=inside then near2=true end
 end
 if inside and near1 then value=stone
 elseif inside and near2 then value=joint
 elseif not inside and near1 then value=shadow end
 out:drawPixel(col*16+x,row*16+y,value)
end end end end
local s=Sprite(out.width,out.height,ColorMode.RGB);s:setPalette(palette);s.cels[1].image=out
s:saveAs(dir..'terrain.aseprite');s:saveAs(dir..'terrain.png')
app.command.SpriteSize{ui=false,width=512,height=768,method='nearest-neighbor'}
s:saveAs(dir..'terrain_preview_8x.png');s:close()
-- Real exported tiles and existing sprites, composited at their native sizes.
local preview=Image(640,360,ColorMode.RGB)
local function tile(col,row,dx,dy)
 for y=0,15 do for x=0,15 do
  if dx+x<640 and dy+y<360 then preview:drawPixel(dx+x,dy+y,out:getPixel(col*16+x,row*16+y)) end
 end end
end
math.randomseed(11012026)
for ty=0,22 do for tx=0,39 do
 local c,r=0,1
 if ty<13 then
  c=math.random()<.025 and 1 or 0
 elseif ty<=15 or ty>=22 then c,r=math.random()<.04 and 3 or 2,0
 elseif ty==16 then c,r=0,3
 elseif ty==21 then c,r=2,3
 else c,r=0,0 end
 tile(c,r,tx*16,ty*16)
end end
for tx=0,39 do tile(1,2,tx*16,304) end
for ty=17,20 do tile(3,2,24*16,ty*16);tile(3,2,25*16,ty*16) end
local function sprite(path,x,bottom)
 local src=app.open(root..'/assets/art/style-test/'..path)
 local im=Image(src.width,src.height,ColorMode.RGB);im:drawSprite(src,1);src:close()
 preview:drawImage(im,Point(x,bottom-im.height))
end
sprite('city-expansion/buildings/building_apartments.png',16,224)
sprite('city-expansion/buildings/building_neighborhood_shop.png',288,224)
sprite('city-v2/cafe.png',480,224)
sprite('city-expansion/props/bus_shelter.png',272,253)
sprite('city-v2/tree_ochre.png',418,224)
sprite('city-v2/lamp_unlit.png',10,262)
sprite('city-v2/lamp_unlit.png',607,262)
sprite('city-expansion/props/bench_backrest.png',538,252)
sprite('city-expansion/props/litter_bin_square.png',579,255)
local student=app.open(root..'/assets/art/style-test/char_student_atlas.png')
local studentImage=Image(student.width,student.height,ColorMode.RGB);studentImage:drawSprite(student,1);student:close()
preview:drawImage(Image(studentImage,Rectangle(0,0,32,32)),Point(164,224))
assert(preview.width==640 and preview.height==360)
local p=Sprite(640,360,ColorMode.RGB);p:setPalette(palette);p.cels[1].image=preview
p:saveAs(dir..'street_preview.aseprite');p:saveAs(dir..'street_preview.png')
app.command.SpriteSize{ui=false,width=1280,height=720,method='nearest-neighbor'}
p:saveAs(dir..'street_preview_2x.png');p:close()
print('Exported 64x96 atlas: 24 tiles of 16x16; Resurrect64 palette.')
