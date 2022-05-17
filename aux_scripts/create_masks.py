#%% Imports
import importlib
import os
import pathlib
from pathlib import Path
import random

import pandas as pd
from tqdm import tqdm

import cv2
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
from scipy import ndimage

import utils
import stimset
importlib.reload(utils)
importlib.reload(stimset)

# %% Load files and create StimulusSet
path_input = Path('../stimuli_new')
l_files = list(path_input.glob('**/*.png'))

dict_lookup = {
    'type' : 0, # target, mask
    'ctxt' : 1,
    'ctxt_exemplar' : 2,
    'action' : 3,
    'view' : 4,
    'actor' : 5
}

my_set = stimset.StimulusSet(path_input, dict_lookup, 'png',
                             keep_outliers=False, ignore_pattern='mask')
#my_set.check_fname_structure()
df = my_set.create_dataframe()
print(df.head())

# %%
img = cv2.imread(str(my_set.filelist[0]))
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
print(img.shape)

plt.imshow(img)

# %% Rotation
from scipy import ndimage
img_scipy = ndimage.rotate(img, 90, reshape=True)
plt.imshow(img_scipy)
#cv2.imwrite('rotate_scipy.png', img_scipy)

# %%
im = img
M = 22
N = 32

# https://stackoverflow.com/a/47581978
tiles = [im[x:x+M,y:y+N] for x in range(0,im.shape[0],M) for y in range(0,im.shape[1],N)]


#%% From tiles back to image
a_tiles = np.concatenate(tiles, axis=0)
print(a_tiles.shape)
im_new = np.reshape(tiles, im.shape[:2])
print(im_new.shape)
plt.imshow(im_new)

# %%
import random

# 1) shuffle positions in a list
idxs_shuffled = [i for i in range(len(tiles))]
random.shuffle(idxs_shuffled)
tiles = [tiles[i] for i in idxs_shuffled]

# 2) random rotation (0, 90, 180, 270)
# iterate through tiles
for i in range(len(tiles)):
    #angle = random.choice([0, 90, 180, 270])
    angle = random.choice([0, 180])
    tiles[i] = ndimage.rotate(tiles[i], angle)
    
# 3) reconstruct (TODO)
im_shuff = np.reshape(tiles, im.shape)
plt.imshow(im_shuff)

#%% ==========================================================================
# IDEA
# Given a size of (square) tiles to split the image into,
# 1) Find the biggest area that can be split (uniformly) from that image with
# the tiles
# 2) Perform shuffling on those tiles AND ingnore the rest (?)
# 3) Reconstruct
# 
# THIS IS HOW PREVIOUS CODE (TZ'S) WORKED, WHICH IN TURN WAS TAKEN FROM AL.

#%%
M = 20

#%%
def reshape_split(img : np.ndarray, kernel_size : tuple):
    h, w = img.shape
    h_tile, w_tile = kernel_size
    
    tiled_array = img.reshape(h // h_tile,
                              h_tile,
                              w // w_tile,
                              w_tile)
    
    #tiled_array = tiled_array.swapaxes(1,2) # only for RGB
    return tiled_array
# %%
W = 16
H = 11
t_size = (H, W)
tiles = reshape_split(img, t_size)
print(tiles.shape)
# %%
untiled = tiles.reshape(img.shape)
plt.imshow(untiled)

#%% 1) Load image
img = cv2.imread(str(my_set.filelist[0]))
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
print(img.shape)

plt.imshow(img)

#%% 2) Create tile
W = 16
H = 11
t_size = (H, W)
tiles = reshape_split(img, t_size)
print(tiles.shape)

#%% 3) Random rotation
import random
n_tiles = tiles.shape[0] * tiles.shape[2]
print(n_tiles)

for i in range(tiles.shape[0]):
    # i : height
    for j in range(tiles.shape[2]):
        # j : width
        angle = random.choice([0, 180])
        tiles[i, :, j, :] = ndimage.rotate(tiles[i, :, j, :], angle)
        
untiled_rotated = tiles.reshape(img.shape)
plt.imshow(untiled_rotated)

#%% Test
tiles_rotated_flat = np.reshape(tiles, (-1, H, W))
plt.imshow(tiles_rotated_flat.reshape(img.shape))

#%% 4) Shuffle order
tiles_rotated_flat = np.reshape(tiles, (-1, H, W)) #np.reshape(untiled_rotated, (-1, H, W))
print('Rotated flat:', tiles_rotated_flat.shape)
idxs_shuffled = [i for i in range(tiles_rotated_flat.shape[0])]
random.shuffle(idxs_shuffled)
#tiles_flat = tiles_flat[idxs_shuffled, :, :]

tiles_rotated_shuff = tiles_rotated_flat
np.random.shuffle(tiles_rotated_shuff)
print('Rotated shuffled flat:', tiles_rotated_shuff.shape)

#%% 5) Recreate
untiled_rotated_shuff = tiles_rotated_shuff.reshape(img.shape)
untiled_rotated = tiles_rotated_flat.reshape(img.shape)
plt.imshow(untiled_rotated)
plt.show(block=False)
plt.imshow(untiled_rotated_shuff)
cv2.imwrite('untiled_shuffled.png', untiled_rotated_shuff)

# %%
# %%
