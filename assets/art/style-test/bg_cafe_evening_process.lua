local root = app.params.root
local sprite = app.open(root .. '/assets/art/style-test/bg_cafe_evening_source.png')
assert(sprite, 'Could not open source background')
app.command.SpriteSize { ui=false, width=640, height=360, method='nearest-neighbor' }
sprite:setPalette(Palette { fromFile=root .. '/assets/palette/resurrect-64.gpl' })
app.command.ChangePixelFormat { format='indexed', dithering='none' }
assert(sprite.width == 640 and sprite.height == 360, 'Unexpected background dimensions')
assert(sprite.colorMode == ColorMode.INDEXED, 'Expected indexed colors')
sprite:saveAs(root .. '/assets/art/style-test/bg_cafe_evening.aseprite')
sprite:saveAs(root .. '/assets/art/style-test/bg_cafe_evening.png')
print('Saved 640x360 indexed background')
