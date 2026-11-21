-- Notebook UI extension of the existing Aseprite-authored notebook HUD button.
-- Usage: aseprite --batch --script-param root=/project --script this_file.lua
local root=assert(app.params.root,'Pass project root')
local out=root..'/assets/art/ui/notebook/'
local original=Palette{fromFile=root..'/assets/palette/resurrect-64.gpl'}
local palette=Palette(#original+1)
palette:setColor(0,Color{r=46,g=34,b=47,a=0})
local lookup={}
for i=0,#original-1 do
  local c=original:getColor(i)
  palette:setColor(i+1,c)
  lookup[string.format('%02x%02x%02x',c.red,c.green,c.blue)]=i+1
end
local function c(hex) return assert(lookup[hex],hex) end
local C={ink=c('4c3e24'),dark=c('2e222f'),paper=c('fdcbb0'),edge=c('ab947a'),
  cover=c('374e4a'),green=c('165a4c'),pale=c('c7dcd0'),gold=c('fbb954'),
  gray=c('625565'),lightgray=c('9babb2'),rust=c('9e4539'),stitch=c('b2ba90'),
  dim=c('3e3546'),leaf=c('547e64'),water=c('4d65b4')}
local assets,groups={},{}
local function image(w,h) return Image(w,h,ColorMode.INDEXED) end
local function pixel(im,x,y,v)
  assert(x>=0 and y>=0 and x<im.width and y<im.height,'Pixel outside canvas')
  im:drawPixel(x,y,v)
end
local function rect(im,x,y,w,h,v)
  assert(w>=0 and h>=0 and x>=0 and y>=0 and x+w<=im.width and y+h<=im.height,'Rectangle outside canvas')
  for yy=y,y+h-1 do for xx=x,x+w-1 do im:drawPixel(xx,yy,v) end end
end
local function line(im,x0,y0,x1,y1,v)
  local dx,dy=math.abs(x1-x0),-math.abs(y1-y0)
  local sx,sy=x0<x1 and 1 or -1,y0<y1 and 1 or -1
  local err=dx+dy
  while true do
    pixel(im,x0,y0,v)
    if x0==x1 and y0==y1 then break end
    local e2=2*err
    if e2>=dy then err=err+dy;x0=x0+sx end
    if e2<=dx then err=err+dx;y0=y0+sy end
  end
end
local function border(im,x,y,w,h,v)
  rect(im,x,y,w,1,v);rect(im,x,y+h-1,w,1,v)
  rect(im,x,y,1,h,v);rect(im,x+w-1,y,1,h,v)
end
local function paste(dst,src,x,y)
  assert(x>=0 and y>=0 and x+src.width<=dst.width and y+src.height<=dst.height,'Paste outside canvas')
  for yy=0,src.height-1 do for xx=0,src.width-1 do
    local p=src:getPixel(xx,yy)
    if p~=0 then dst:drawPixel(x+xx,y+yy,p) end
  end end
end
local function sprite(im)
  local s=Sprite(im.width,im.height,ColorMode.INDEXED)
  s:setPalette(palette);s.transparentColor=0;s.cels[1].image=im
  return s
end
local function save(name,im,group,state,slice)
  local s=sprite(im);s:saveAs(out..name..'.png');s:close()
  local item={name=name,image=im,group=group,state=state or 'default',slice=slice}
  table.insert(assets,item)
  groups[group]=groups[group] or {};table.insert(groups[group],item)
  return im
end
local function focus(w,h)
  local im=image(w,h)
  border(im,0,0,w,h,C.dark);border(im,1,1,w-2,h-2,C.gold)
  for _,p in ipairs({{0,0},{w-1,0},{0,h-1},{w-1,h-1}}) do pixel(im,p[1],p[2],0) end
  return im
end

-- Static open notebook: 480x300, left index and wider right reading page.
local book=image(480,300)
rect(book,5,6,474,293,C.dark)
rect(book,2,2,474,292,C.dark)
rect(book,3,3,472,290,C.cover)
rect(book,4,4,470,1,C.leaf);rect(book,4,5,1,286,C.leaf)
rect(book,8,35,463,246,C.edge)
rect(book,9,36,178,241,C.paper);rect(book,199,36,271,241,C.paper)
rect(book,10,37,176,1,C.pale);rect(book,200,37,269,1,C.pale)
rect(book,187,36,2,241,C.edge);rect(book,189,36,8,241,C.paper)
rect(book,197,36,2,241,C.edge)
for _,y in ipairs({69,121,173,225,265}) do
  rect(book,186,y,14,3,C.edge);rect(book,186,y,14,1,C.ink)
  pixel(book,186,y+1,C.pale);pixel(book,199,y+1,C.pale)
end
rect(book,9,278,461,1,C.edge);rect(book,9,279,461,11,C.paper)
rect(book,7,291,466,1,C.edge);rect(book,8,293,466,1,C.paper)
rect(book,9,295,465,1,C.edge)
save('ui_notebook_open',book,'notebook_open')

-- Closed cover, for the prologue or opening animation.
local cover=image(240,300)
rect(cover,7,5,231,293,C.dark)
rect(cover,5,4,231,292,C.edge)
rect(cover,6,291,228,2,C.paper);rect(cover,6,295,228,1,C.paper)
rect(cover,2,2,231,290,C.dark);rect(cover,3,3,229,288,C.cover)
rect(cover,4,4,227,1,C.leaf);rect(cover,4,5,1,284,C.leaf)
rect(cover,12,5,2,284,C.dark);rect(cover,14,5,1,284,C.leaf)
border(cover,23,16,198,262,C.leaf)
rect(cover,38,48,168,58,C.ink);rect(cover,39,49,166,56,C.edge)
rect(cover,41,51,162,52,C.paper);rect(cover,42,52,160,1,C.pale)
for _,y in ipairs({42,85,128,171,214,257}) do rect(cover,6,y,4,1,C.stitch) end
rect(cover,203,108,6,190,C.dark);rect(cover,204,108,4,190,C.rust)
save('ui_notebook_cover',cover,'notebook_cover')

-- 9-slice panels; every ornament remains within its fixed 8px border.
local panel=image(32,32)
rect(panel,1,1,30,30,C.edge);rect(panel,2,2,28,28,C.paper)
rect(panel,2,2,28,1,C.pale);rect(panel,2,3,1,27,C.pale)
save('panels/ui_notebook_page',panel,'panels','page',8)
local source=image(32,32)
rect(source,0,0,32,32,C.paper);rect(source,2,3,2,26,C.green)
save('panels/ui_notebook_source',source,'panels','source',8)
local epiphany=image(32,32)
rect(epiphany,2,3,29,28,C.dark);rect(epiphany,1,1,29,28,C.dark)
rect(epiphany,2,2,27,26,C.cover);rect(epiphany,5,5,21,20,C.edge)
rect(epiphany,6,6,19,18,C.paper);rect(epiphany,6,6,19,1,C.pale)
save('panels/ui_epiphany_panel',epiphany,'panels','epiphany',8)

local stateNames={'normal','hover','pressed','disabled','focus'}
local function control(w,h,state,kind)
  if state=='focus' then return focus(w,h) end
  local im=image(w,h)
  local pressed=state=='pressed' or state=='selected'
  local disabled=state=='disabled'
  local selected=state=='selected'
  local fill=disabled and C.lightgray or (selected and C.cover or (state=='hover' and C.pale or (pressed and C.edge or C.paper)))
  local y=pressed and 3 or 2
  rect(im,3,4,w-4,h-5,C.dark)
  rect(im,2,y,w-4,h-5,C.dark)
  rect(im,3,y+1,w-6,h-7,fill)
  rect(im,3,y+1,w-6,1,disabled and C.edge or (pressed and C.cover or (state=='hover' and C.gold or C.pale)))
  rect(im,3,y+2,1,h-9,disabled and C.edge or (pressed and C.cover or C.pale))
  if kind=='entry' and selected then rect(im,3,y+1,2,h-7,C.gold) end
  if kind=='tab' then
    rect(im,2,h-3,w-4,3,selected and C.paper or fill)
    if selected then
      rect(im,3,3,w-6,h-3,C.paper)
      rect(im,3,2,w-6,2,C.gold)
    end
  end
  if kind=='close' then
    local ink=disabled and C.gray or C.ink
    local offset=pressed and 1 or 0
    line(im,8,8+offset,15,15+offset,ink)
    line(im,15,8+offset,8,15+offset,ink)
  end
  return im
end
local entries,tabs,actions,closes={},{},{},{}
for _,state in ipairs({'normal','hover','selected','disabled','focus'}) do
  entries[state]=save('entries/ui_notebook_entry_'..state,control(160,32,state,'entry'),'entries',state,8)
  tabs[state]=save('tabs/ui_notebook_tab_'..state,control(72,24,state,'tab'),'tabs',state,8)
end
for _,state in ipairs(stateNames) do
  actions[state]=save('buttons/ui_notebook_action_'..state,control(144,24,state,'action'),'actions',state,8)
  closes[state]=save('buttons/ui_notebook_close_'..state,control(24,24,state,'close'),'close',state)
end

-- Cards: no illustrations behind the text. Their side is encoded in a header strip.
local cards={}
for _,side in ipairs({'myth','fact','unknown'}) do
  local im=image(96,128)
  local unknown=side=='unknown'
  local accent=side=='fact' and C.green or (unknown and C.gray or C.rust)
  rect(im,3,4,92,123,C.dark);rect(im,2,2,91,123,C.dark)
  rect(im,3,3,89,121,unknown and C.edge or C.paper)
  rect(im,4,4,87,1,unknown and C.lightgray or C.pale)
  rect(im,4,5,1,118,unknown and C.lightgray or C.pale)
  rect(im,8,9,79,2,accent)
  rect(im,8,29,79,1,unknown and C.gray or C.edge)
  rect(im,8,99,79,1,unknown and C.gray or C.edge)
  rect(im,83,3,7,14,accent)
  pixel(im,83,16,unknown and C.edge or C.paper)
  pixel(im,89,16,unknown and C.edge or C.paper)
  cards[side]=save('cards/ui_card_'..side,im,'cards',side)
end
cards.focus=save('cards/ui_card_focus',focus(96,128),'cards','focus')

-- Original 16x16 icon set, matching the line weight of the notebook button.
local icons={}
local function icon(name,draw)
  local im=image(16,16);draw(im)
  icons[name]=save('icons/icon_'..name,im,'icons',name)
end
icon('finding_order',function(im)
  line(im,3,1,7,6,C.rust);line(im,12,1,8,6,C.rust)
  line(im,4,1,7,5,C.gold);line(im,11,1,8,5,C.gold)
  local shape={{7,4},{9,7},{13,7},{10,10},{11,14},{7,12},{3,14},{4,10},{1,7},{5,7},{7,4}}
  for i=1,#shape-1 do line(im,shape[i][1],shape[i][2],shape[i+1][1],shape[i+1][2],C.dark) end
  rect(im,5,7,5,5,C.gold);rect(im,6,8,3,3,C.edge);pixel(im,7,9,C.paper)
end)
icon('finding_scroll',function(im)
  rect(im,4,2,9,12,C.dark);rect(im,5,3,7,10,C.paper)
  rect(im,2,1,11,3,C.ink);rect(im,3,2,9,1,C.edge)
  rect(im,4,12,11,3,C.ink);rect(im,5,13,9,1,C.edge)
  rect(im,6,5,4,1,C.rust);rect(im,6,7,5,1,C.ink);rect(im,6,9,3,1,C.ink)
end)
icon('finding_ice',function(im)
  rect(im,1,2,14,12,C.dark);rect(im,2,3,12,10,C.water)
  line(im,2,4,6,4,C.pale);line(im,6,4,8,6,C.pale);line(im,8,6,13,5,C.pale)
  line(im,2,8,5,8,C.pale);line(im,5,8,7,10,C.pale);line(im,7,10,13,10,C.pale)
  line(im,9,3,7,7,C.dark);line(im,7,7,9,8,C.dark);line(im,9,8,7,12,C.dark)
end)
icon('finding_map',function(im)
  rect(im,1,3,14,12,C.dark);rect(im,2,4,12,10,C.paper)
  rect(im,5,4,1,10,C.edge);rect(im,10,4,1,10,C.edge)
  line(im,2,11,5,9,C.leaf);line(im,5,9,9,12,C.leaf);line(im,9,12,13,10,C.leaf)
  rect(im,7,1,6,5,C.dark);rect(im,8,2,4,3,C.rust);line(im,7,6,10,9,C.dark)
  line(im,12,6,10,9,C.dark);rect(im,9,3,2,1,C.paper)
end)
icon('finding_calendar',function(im)
  rect(im,2,2,12,13,C.dark);rect(im,3,3,10,11,C.paper)
  rect(im,3,3,10,3,C.rust);rect(im,4,1,1,3,C.ink);rect(im,11,1,1,3,C.ink)
  for y=8,11,3 do for x=4,10,3 do rect(im,x,y,2,2,C.edge) end end
  rect(im,7,8,2,2,C.green)
end)
icon('notebook_verified',function(im)
  line(im,2,8,6,12,C.dark);line(im,6,12,14,3,C.dark)
  line(im,2,7,6,11,C.green);line(im,6,11,14,2,C.green)
end)
icon('notebook_unchecked',function(im)
  line(im,5,3,10,3,C.rust);pixel(im,4,4,C.rust);pixel(im,11,4,C.rust)
  line(im,11,4,11,6,C.rust);line(im,11,6,8,9,C.rust)
  rect(im,7,9,2,2,C.rust);rect(im,7,13,2,2,C.rust)
end)
icon('notebook_verified_light',function(im)
  line(im,2,8,6,12,C.ink);line(im,6,12,14,3,C.ink)
  line(im,2,7,6,11,C.pale);line(im,6,11,14,2,C.pale)
end)
icon('notebook_unchecked_light',function(im)
  line(im,5,3,10,3,C.paper);pixel(im,4,4,C.paper);pixel(im,11,4,C.paper)
  line(im,11,4,11,6,C.paper);line(im,11,6,8,9,C.paper)
  rect(im,7,9,2,2,C.paper);rect(im,7,13,2,2,C.paper)
end)
icon('notebook_locked',function(im)
  rect(im,3,7,10,8,C.dark);rect(im,4,8,8,6,C.edge)
  line(im,5,7,5,3,C.ink);line(im,5,3,10,3,C.ink);line(im,10,3,10,7,C.ink)
  rect(im,7,10,2,3,C.ink)
end)

-- Editable source documents, with a frame tag for every state.
for name,items in pairs(groups) do
  local s=sprite(items[1].image)
  s.layers[1].name='Artwork only; labels belong in Godot'
  for i,item in ipairs(items) do
    assert(item.image.width==s.width and item.image.height==s.height,'Group dimensions differ: '..name)
    if i>1 then s:newFrame() end
    s.cels[i].image=item.image
    local tag=s:newTag(i,i);tag.name=item.state;s.frames[i].duration=0.2
  end
  s:saveAs(out..'source/'..name..'.aseprite');s:close()
end

-- Export mapping for the editor; all paths are relative to this pack.
local entriesJson={}
for _,item in ipairs(assets) do
  local slice=item.slice and ',"nine_slice":['..item.slice..','..item.slice..','..item.slice..','..item.slice..']' or ''
  table.insert(entriesJson,string.format('{"file":"%s.png","width":%d,"height":%d,"group":"%s","state":"%s"%s}',
    item.name,item.image.width,item.image.height,item.group,item.state,slice))
end
local manifest=assert(io.open(out..'manifest.json','w'))
manifest:write('{"base_viewport":[640,360],"palette":"Resurrect 64","text_in_textures":false,"assets":[\n'..table.concat(entriesJson,',\n')..'\n]}\n')
manifest:close()

-- Save preview composites with temporary bitmap lettering (not production text).
local drawText=dofile(out..'source/preview_font.lua')
local function text(im,t,x,y,ink) drawText(im,t,x,y,ink or C.ink) end
local function nine(src,w,h)
  local dst=image(w,h)
  local function coord(n,total,original)
    if n<8 then return n elseif n>=total-8 then return original-(total-n) else return 8+(n-8)%(original-16) end
  end
  for y=0,h-1 do for x=0,w-1 do dst:drawPixel(x,y,src:getPixel(coord(x,w,src.width),coord(y,h,src.height))) end end
  return dst
end
local function exportPreview(im,name,scale)
  local s=sprite(im);s:saveAs(out..'preview/'..name..'.png')
  if scale then
    app.command.SpriteSize{ui=false,width=im.width*scale,height=im.height*scale,method='nearest-neighbor'}
    s:saveAs(out..'preview/'..name..'_'..scale..'x.png')
  end
  s:close()
end
local demo=image(640,360)
rect(demo,0,0,640,360,C.dim)
paste(demo,book,80,30)
text(demo,'БЛОКНОТ ДОКЛАДА',98,46,C.pale)
paste(demo,tabs.selected,354,42);paste(demo,tabs.normal,426,42)
text(demo,'ТЕЗИСЫ',369,51);text(demo,'НАХОДКИ',439,51)
paste(demo,closes.normal,528,40)
text(demo,'МОИ ТЕЗИСЫ',98,74);text(demo,'3/5',235,74,C.green)
local titles={'ЕДИНСТВО','ДОСПЕХИ','ПОДО ЛЬДОМ','МАСШТАБ БИТВЫ','КТО С МЕЧОМ...'}
for i,title in ipairs(titles) do
  local y=88+(i-1)*38
  paste(demo,i==2 and entries.selected or entries.normal,96,y)
  local ink=i==2 and C.paper or C.ink
  text(demo,tostring(i),104,y+12,ink);text(demo,title,118,y+12,ink)
  paste(demo,i==2 and icons.notebook_verified_light or ((i>1 and i<5) and icons.notebook_verified or icons.notebook_unchecked),237,y+8)
end
text(demo,'ЛЕДОВОЕ ПОБОИЩЕ / 1242',98,291)
text(demo,'К2 / ФАКТ',293,79,C.green);text(demo,'МУЗЕЙ',496,79,C.green)
text(demo,'ТЯЖЕЛЫЕ ДОСПЕХИ',293,102)
rect(demo,293,117,241,1,C.edge)
for i,t in ipairs({'В 1242 ГОДУ ОБЕ СТОРОНЫ НОСИЛИ', 'КОЛЬЧУГИ, ШЛЕМЫ И ЩИТЫ.', 'СПЛОШНЫЕ ЛАТЫ ПОЯВЯТСЯ', 'ТОЛЬКО В XIV-XV ВЕКАХ.'}) do text(demo,t,293,137+(i-1)*14) end
paste(demo,nine(source,241,45),293,223)
text(demo,'ИСТОЧНИК',305,229,C.green)
text(demo,'А. Н. КИРПИЧНИКОВ,',305,245)
text(demo,'ДРЕВНЕРУССКОЕ ОРУЖИЕ',305,256)
paste(demo,actions.normal,293,282)
text(demo,'КАК Я ДУМАЛ РАНЬШЕ',311,291)
text(demo,'ЗАКРЫТЬ / TAB',450,312)
exportPreview(demo,'notebook_layout',2)

local board=image(640,480)
rect(board,0,0,640,480,C.dim)
text(board,'ОБЛОЖКА',12,9,C.pale)
paste(board,cover,12,22)
text(board,'МИФ',268,9,C.pale);text(board,'ФАКТ',373,9,C.pale);text(board,'НЕ ОТКРЫТО',478,9,C.pale)
paste(board,cards.myth,268,22);paste(board,cards.fact,373,22);paste(board,cards.unknown,478,22)
text(board,'ВКЛАДКИ / СТРОКИ / КНОПКИ',268,165,C.pale)
for i,state in ipairs({'normal','hover','selected','disabled','focus'}) do
  local y=183+(i-1)*34
  paste(board,state=='focus' and tabs.normal or tabs[state],268,y)
  paste(board,state=='focus' and entries.normal or entries[state],349,y)
  local act=state=='selected' and 'pressed' or state
  paste(board,act=='focus' and closes.normal or closes[act],520,y)
  if state=='focus' then paste(board,tabs.focus,268,y);paste(board,entries.focus,349,y);paste(board,closes.focus,520,y) end
end
text(board,'НАХОДКИ И ОТМЕТКИ / 16X16',12,339,C.pale)
for i,name in ipairs({'finding_order','finding_scroll','finding_ice','finding_map','finding_calendar','notebook_verified','notebook_unchecked','notebook_locked'}) do paste(board,icons[name],16+(i-1)*28,356) end
text(board,'ПРОЗРЕНИЕ / РАСТЯГИВАЕМАЯ ПАНЕЛЬ',268,363,C.pale)
paste(board,nine(epiphany,300,88),268,380)
text(board,'ПРОЗРЕНИЕ',385,393,C.green)
text(board,'БЫЛО / СТАЛО / ИСТОЧНИК',354,416)
paste(board,actions.normal,349,435)
text(board,'ВЕРНУТЬСЯ В БЛОКНОТ',364,443)
text(board,'PNG БЕЗ ТЕКСТА',12,401,C.pale)
text(board,'ПАЛИТРА RESURRECT 64',12,419,C.pale)
text(board,'ПРЕВЬЮ / НЕ ДЛЯ ИГРЫ',12,437,C.pale)
exportPreview(board,'notebook_asset_sheet',2)

-- Verify each saved production PNG, including exact size, colors and hard alpha.
for _,item in ipairs(assets) do
  local s=app.open(out..item.name..'.png')
  assert(s.width==item.image.width and s.height==item.image.height,'Wrong size: '..item.name)
  assert(s.colorMode==ColorMode.INDEXED,'Expected indexed: '..item.name)
  local im,p=s.cels[1].image,s.palettes[1]
  for it in im:pixels() do
    local col=p:getColor(it())
    assert(col.alpha==0 or col.alpha==255,'Partial transparency: '..item.name)
    if col.alpha==255 then assert(lookup[string.format('%02x%02x%02x',col.red,col.green,col.blue)],'Wrong palette: '..item.name) end
  end
  if item.state=='focus' then
    for y=2,s.height-3 do for x=2,s.width-3 do assert(im:getPixel(x,y)==0,'Opaque focus interior: '..item.name) end end
  end
  s:close()
end
print('Notebook UI: '..#assets..' production PNGs saved and verified; sources and previews exported.')
