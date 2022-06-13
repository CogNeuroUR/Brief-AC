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
path_input = Path('../stimuli_targets/')
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

# %% Load test image
img = cv2.imread(str(my_set.filelist[0]))
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
print(img.shape)
plt.imshow(img)

#%% ==========================================================================
# IDEA
# Given a size of (square) tiles to split the image into,
# 1) Find the biggest area that can be split (uniformly) from that image with
# the tiles
# 2) Perform shuffling on those tiles AND ingnore the rest (?)
# 3) Reconstruct
# 
# THIS IS HOW PREVIOUS CODE (TZ'S) WORKED, WHICH IN TURN WAS TAKEN FROM AL.


#%% Size of (square) tiles : smallest common divisors
width = img.shape[1]
height = img.shape[0]

minim = min([width, height])

l_divisors = []
for i in range(1, minim+1):
    if((width % i == 0) and (height % i == 0)):
       l_divisors.append(i)
       
print('Common divisors:', l_divisors)

#%% Tiling function
def tile_(im, tw, th=None):
    # https://stackoverflow.com/a/47581978
    if not th:
        th = tw
    #return np.reshape(im, (im.shape[0] // th * im.shape[1] // tw, th, tw))
    return np.reshape(im, (th, tw, -1))

#%% Tiling function
def tile(img, w_tile, h_tile=None):
    # given landscape mode
    h = img.shape[0]
    w = img.shape[1]

    if not h_tile:
        h_tile = w_tile
    
    tiled_array = img.reshape(h // h_tile,
                              h_tile,
                              w // w_tile,
                              w_tile)
    
    #tiled_array = tiled_array.swapaxes(1,2) # only for RGB
    
    tiles = []

    for i in range(tiled_array.shape[0]):
        for j in range(tiled_array.shape[2]):
            tiles.append(tiled_array[i, :, j, :])
            
    return np.array(tiles)

# %% Test tiling
M = 192

tiles = tile(img, M)
print(tiles.shape)
plt.imshow(tiles[2])

#%% From tiles to img
def untile(tiles, shape):
    # check if tiles are compatible with shape
    # TODO
    
    if tiles.shape[1] != tiles.shape[2]:
        raise ValueError('Tiles are not square!')
    
    th = tiles.shape[1]
    tw = tiles.shape[2]
    
    untiled = np.zeros(shape)
    
    k = 0
    for i in range(shape[0]//th):
        for j in range(shape[1]//tw):
            untiled[i*th:(i+1)*th, j*tw:(j+1)*tw] = tiles[k]
            k+=1
            
    return untiled

#%% Test untiling
untiled = untile(tiles, img.shape)
plt.imshow(untiled)


# %% Test tiling & untiling
im = img
M = 192 #32
N = M

tiles = tile(im, M)
print(len(tiles))

# %% Shuffling order and angle
def shuffle_tiles(tiles):  
    # 1) shuffle positions in a list
    idxs_shuffled = [i for i in range(len(tiles))]
    random.shuffle(idxs_shuffled)
    tiles = tiles[idxs_shuffled]

    # 2) random rotation (0, 90, 180, 270)
    if tiles.shape[1] == tiles.shape[2]: 
        angles = [0, 90, 180, 270]
    else:
        angles = [0, 180]
    # iterate through tiles
    for i in range(len(tiles)):
        tiles[i] = ndimage.rotate(tiles[i], random.choice(angles))

    return tiles

#%% Test shuffling
tiles_shuf = shuffle_tiles(tiles)
plt.imshow(untile(tiles_shuf, img.shape))

#%% Write TODO
#cv2.imwrite('untiled_shuffled.png', tiles_shuf)
