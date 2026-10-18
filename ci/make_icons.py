import sys, os
from PIL import Image, ImageDraw
res, root = sys.argv[1], sys.argv[2]
ic = Image.open(os.path.join(root,'icons','icon-512.png')).convert('RGBA')
mk = Image.open(os.path.join(root,'icons','maskable-512.png')).convert('RGBA')
leg={'mdpi':48,'hdpi':72,'xhdpi':96,'xxhdpi':144,'xxxhdpi':192}
fg={'mdpi':108,'hdpi':162,'xhdpi':216,'xxhdpi':324,'xxxhdpi':432}
for k in leg:
    d=os.path.join(res,'mipmap-'+k)
    full=ic.resize((leg[k],leg[k]),Image.LANCZOS); full.save(os.path.join(d,'ic_launcher.png'))
    rnd=full.copy(); m=Image.new('L',(leg[k]*4,)*2,0); ImageDraw.Draw(m).ellipse([0,0,leg[k]*4-1,leg[k]*4-1],fill=255)
    rnd.putalpha(m.resize((leg[k],leg[k]),Image.LANCZOS)); rnd.save(os.path.join(d,'ic_launcher_round.png'))
    mk.resize((fg[k],fg[k]),Image.LANCZOS).save(os.path.join(d,'ic_launcher_foreground.png'))
open(os.path.join(res,'values','ic_launcher_background.xml'),'w').write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#0B1A33</color>\n</resources>\n')
for dn in os.listdir(res):
    p=os.path.join(res,dn,'splash.png')
    if dn.startswith('drawable') and os.path.exists(p): Image.new('RGB',(8,8),(11,26,51)).save(p)
