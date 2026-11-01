local root=assert(app.params.root)
local dir=root..'/assets/art/style-test/city-expansion/'
local f=assert(io.open(dir..'atlas_manifest.json'));local manifest=json.decode(f:read('*a'));f:close()
local pal=Palette{fromFile=root..'/assets/palette/resurrect-64.gpl'}
local allowed={}
for i=0,#pal-1 do local c=pal:getColor(i);allowed[app.pixelColor.rgba(c.red,c.green,c.blue,255)]=true end
local function load(path)
 local s=app.open(dir..path);local im=Image(s.width,s.height,ColorMode.RGB);im:drawSprite(s,1);s:close();return im
end
local atlases={}
for _,name in ipairs({'atlases/buildings.png','atlases/props.png'}) do atlases[name]=load(name) end
local checked=0
local function check(im,name)
 local opaque,transparent=0,0
 for it in im:pixels() do
  local a=app.pixelColor.rgbaA(it())
  assert(a==0 or a==255,name..': non-binary alpha')
  if a==255 then assert(allowed[it()],name..': color outside palette');opaque=opaque+1 else transparent=transparent+1 end
 end
 assert(opaque>0 and transparent>0,name..': missing sprite or transparent background')
 checked=checked+1
end
local regions={}
for _,asset in ipairs(manifest.assets) do
 local im=load(asset.path)
 assert(im.width==asset.width and im.height==asset.height,asset.name..': unexpected size')
 assert(im.width%16==0 and im.height%16==0,asset.name..': off grid size')
 local r=asset.region;assert(r[1]%16==0 and r[2]%16==0,asset.name..': off grid origin')
 check(im,asset.name)
 local atlas=atlases[asset.atlas]
 assert(r[1]>=0 and r[2]>=0 and r[1]+r[3]<=atlas.width and r[2]+r[4]<=atlas.height,'Atlas bounds')
 regions[asset.atlas]=regions[asset.atlas] or {}
 for _,old in ipairs(regions[asset.atlas]) do
  assert(r[1]>=old[1]+old[3] or old[1]>=r[1]+r[3] or r[2]>=old[2]+old[4] or old[2]>=r[2]+r[4],asset.name..': overlap')
 end
 table.insert(regions[asset.atlas],r)
 for y=0,im.height-1 do for x=0,im.width-1 do
  local a,b=im:getPixel(x,y),atlas:getPixel(x+r[1],y+r[2])
  assert(a==b or (app.pixelColor.rgbaA(a)==0 and app.pixelColor.rgbaA(b)==0),asset.name..': atlas differs')
 end end
end
for name,im in pairs(atlases) do check(im,name) end
assert(#manifest.assets==32 and checked==34)
print('PASS: 32 assets + 2 atlases, dimensions, palette, binary alpha, nonoverlapping 16px regions, exact atlas pixels.')

