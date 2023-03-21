#%%
import cv2
from pathlib import Path

#%% Functions
def image_resize(image, width = None, height = None, inter = cv2.INTER_AREA):
    # initialize the dimensions of the image to be resized and
    # grab the image size
    dim = None
    (h, w) = image.shape[:2]

    # if both the width and height are None, then return the
    # original image
    if width is None and height is None:
        return image

    # check to see if the width is None
    if width is None:
        # calculate the ratio of the height and construct the
        # dimensions
        r = height / float(h)
        dim = (int(w * r), height)

    # otherwise, the height is None
    else:
        # calculate the ratio of the width and construct the
        # dimensions
        r = width / float(w)
        dim = (width, int(h * r))

    # resize the image
    resized = cv2.resize(image, dim, interpolation = inter)

    # return the resized image
    return resized


def center_crop(img, dim):
	"""Returns center cropped image
	Args:
	img: image to be center cropped
	dim: dimensions (width, height) to be cropped
	"""
	width, height = img.shape[1], img.shape[0]

	# process crop width and height for max available dimension
	crop_width = dim[0] if dim[0]<img.shape[1] else img.shape[1]
	crop_height = dim[1] if dim[1]<img.shape[0] else img.shape[0] 
	mid_x, mid_y = int(width/2), int(height/2)
	cw2, ch2 = int(crop_width/2), int(crop_height/2) 
	crop_img = img[mid_y-ch2:mid_y+ch2, mid_x-cw2:mid_x+cw2]
	return crop_img

#%%#############################################################################
# Test on a single image
################################################################################
#%% Test on a single image
path_to_stimuli = Path('../stimuli_demo/selected')

img = cv2.imread(str(path_to_stimuli / 'target_kitchen_chopping-vegetables.bmp'),
                 cv2.IMREAD_UNCHANGED)
 
print('Original Dimensions : ',img.shape)
 
#%% Resizing to keep aspect ratio
img_resized = image_resize(img, height = 720)

print(img_resized.shape)

#%% Center-cropping
img_cropped = center_crop(img_resized, (960, 720))
print(img_cropped.shape)
#%% Write
cv2.imwrite(str(path_to_stimuli / 'target_kitchen_chopping-vegetables_cropped.bmp'),
            img_cropped)

#%%#############################################################################
# Resize and crop all images
################################################################################
#%% Collect file names
l_images = []
path_to_stimuli = Path('../stimuli_demo/raw/selected/')

if path_to_stimuli.exists():
  l_images = [str(x) for x in path_to_stimuli.glob('**/target*.JPG') if x.is_file()]

# %%
for path_img in l_images:
  
  print(path_img)
  img = cv2.imread(path_img, cv2.IMREAD_UNCHANGED)
  #pil_img = Image.open(path_img).convert('RGB')
  #img = np.array(pil_img)
  img = img[:, :, ::-1].copy()
  print('Original Dimensions : ',img.shape)
 
  #Resizing to keep aspect ratio
  img_resized = image_resize(img, height = 720)
  print('Resized: ', img_resized.shape)

  # Center-cropping
  img_cropped = center_crop(img_resized, (960, 720))
  print('Cropped: ', img_cropped.shape)
  # Write
  cv2.imwrite(path_img, img_cropped)
