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

#%% Function
def make_masks_across(l_files, tw, th=None, outdir='.'):
    """
    Given a list of picture files, creates masks by:
        (1) tiling the image,
        (2) shuffling tile order and
        (3) randomly rotating each tile (0, 90, 180 or 270 degrees).
    
    Parameters
    ==========
    l_files : list
        List of picture file names.
    tw : int
        Tile width
    th : int or None
        Tile height. If None, then will be equal to "tw".
    """
    # If tile height not given, equal to given tile width
    if not th:
        th = tw
        
    # TODO check if tiles are compatible with shape

    # check if out dir exists
    utils.check_mkdir(outdir)

    # 1) Collect tiles from all target pictures TOGETHER
    l_tiles = []
    i_tilen = 0
    
    # iterate over files
    print('Loading tiles from files ...')
    for fname in tqdm(l_files):
        # load image
        img = cv2.imread(str(fname))
        
        # convert to grayscale, if not already
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # given landscape mode
        h = img.shape[0]
        w = img.shape[1]
        
        #print(img.shape)
    
        # extract tiles as (n_height, th, n_width, tw) array
        tiled_array = img.reshape(h // th, th, w // tw, tw)
        
        # reshape to (n_height x n_width, th, tw)
        # TODO : make it with arrays
        #tiles = []
        for i in range(tiled_array.shape[0]):
            for j in range(tiled_array.shape[2]):
                #tiles.append(tiled_array[i, :, j, :])
                l_tiles.append(tiled_array[i, :, j, :])
        
        # Get nr. of tiles per picture
        i_tilen = (h // th) * (w // tw)
        #l_tiles.append(tiles)
    
    print(f'Created tiles: {len(l_tiles)} ({len(l_tiles)//i_tilen}) ')
    
    # 2) Randomly shuffle tile order TOGETHER
    print('Randomizing tile order ...\n')
    #idxs_shuffled = [i for i in range(len(l_tiles))]
    #random.shuffle(idxs_shuffled)
    #l_tiles = l_tiles[idxs_shuffled]
    # in place
    random.shuffle(l_tiles)
    
    # 3) Randomly rotate [0, 90, 180, 270] EACH tile
    print('Randomly rotating each tile ...')
    if tw == th:    # square
        angles = [0, 90, 180, 270]
    else:   # rectangle 
        angles = [0, 180]
    # iterate through tiles & rotate
    for i in tqdm(range(len(l_tiles))):
        l_tiles[i] = ndimage.rotate(l_tiles[i], random.choice(angles))
    
    # 4) Untile -> mask w/ size of original picture
    # Split entire list of tiles into sub-sets i_tilen-tiles
    print('Untiling & writing to files ...')
    for l in tqdm(range(len(l_tiles)//i_tilen)):
        # Load subset
        tiles = l_tiles[l*i_tilen : (l+1)*i_tilen]
        
        # Untile
        untiled = np.zeros((h, w))
        k = 0
        for i in range(h//th):
            for j in range(w//tw):
                untiled[i*th:(i+1)*th, j*tw:(j+1)*tw] = tiles[k]
                k+=1

        # 5) Assign filename & write
        fname_mask = outdir + '/mask_' + str(l_files[l]).split('/')[-1]
        #print(fname_mask)
        cv2.imwrite(fname_mask, untiled)
    
    print('Finished!')

# %% Load files and create StimulusSet
path_input = Path('targets')
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

#%% Size of (square) tiles : smallest common divisors
width = img.shape[1]
height = img.shape[0]

minim = min([width, height])

l_divisors = []
for i in range(1, minim+1):
    if((width % i == 0) and (height % i == 0)):
       l_divisors.append(i)
       
print('Common divisors:', l_divisors)

#%% Make & write masks
#make_masks_across(l_files, 16, outdir='../masks_across/')
make_masks_across(l_files, 8, outdir='masks_across/')

# %%
