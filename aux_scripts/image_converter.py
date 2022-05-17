#%%
from PIL import Image
import PIL
import os
from pathlib import Path

#%%
path = Path('converted/')
path_originals = Path('stimuli')

if not os.path.exists(path):
    os.makedirs(path)

#%% Define functions
def compress_image(image, infile, size='same'):
    if size != 'same':
      width = 1920
      height = 1080
    else:
      width = image.size[0]
      height = image.size[1]

    name = infile.split('.')
    first_name = path  / f'{name[0]}.jpeg'
    
    if image.size[0] > width and image.size[1] > height:
        image.thumbnail(size, Image.ANTIALIAS)
        image.save(first_name, quality=100)
    elif image.size[0] > width:
        wpercent = (width/float(image.size[0]))
        height = int((float(image.size[1])*float(wpercent)))
        image = image.resize((width,height), PIL.Image.ANTIALIAS)
        image.save(first_name,quality=100)
    elif image.size[1] > height:
        wpercent = (height/float(image.size[1]))
        width = int((float(image.size[0])*float(wpercent)))
        image = image.resize((width,height), PIL.Image.ANTIALIAS)
        image.save(first_name, quality=100)
    else:
        image.save(first_name, quality=100)
        
def processImage(format=None):
  listing = os.listdir(path_originals)

  for infile in listing:
    if (not infile.startswith('.')) and (infile[-4:] != format):
      img = Image.open(path_originals / infile)
      name = infile.split('.')
      first_name = path / f'{name[0]}.jpeg'

      if img.format == "JPEG":
        image = img.convert('RGB')
        compress_image(image, infile)
        img.close()

      elif img.format == "GIF":
        i = img.convert("RGBA")
        bg = Image.new("RGBA", i.size)
        image = Image.composite(i, bg, i)
        compress_image(image, infile)
        img.close()

      elif img.format == "PNG":
        try:
          image = Image.new("RGB", img.size, (255,255,255))
          image.paste(img,img)
          compress_image(image, infile)
        except ValueError:
          image = img.convert('RGB')
          compress_image(image, infile)
        img.close()

      elif img.format == "BMP":
        image = img.convert('RGB')
        compress_image(image, infile)
        img.close()
  print('Done!')
# %%
processImage(format='jpeg')
# %%
