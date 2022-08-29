#%% Imports
import importlib
import os
import pathlib
from pathlib import Path
import random

import pandas as pd
from tqdm import tqdm

import cv2
from matplotlib.patches import Circle
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
from scipy import ndimage

import utils
import stimset
importlib.reload(utils)
importlib.reload(stimset)

# %% Load files and create StimulusSet
path_input = Path('stimuli_targets/')
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

#%% ==========================================================================
# %% Load test image
img = cv2.imread(str(my_set.filelist[0]))
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

#%%
xbg = 1500
black_bg = np.zeros((xbg, xbg))
fig,ax = plt.subplots(1)
plt.axis('off')

plt.imshow(black_bg)
plt.show()

#%% Overlay picture on backgroun
x_offset=(black_bg.shape[0] - img.shape[1])//2
y_offset=(black_bg.shape[1] - img.shape[0])//2
overlayed = black_bg
overlayed[y_offset:y_offset+img.shape[0], x_offset:x_offset+img.shape[1]] = img
plt.imshow(overlayed)

#%% Draw circle
(y, x) = img.shape
center = (x//2,y//2)
fig,ax = plt.subplots(1)
plt.style.use('grayscale')

plt.axis('off')
ax.imshow(img)
plt.xlim(-450, x + 450)

circ20 = Circle(center,x//2, fill=False, edgecolor='red', linestyle='--', label=r"$20.4^\circ$")
circ15 = Circle(center,3*x//8, fill=False, edgecolor='orange', linestyle='--', label=r"$15.3^\circ$")
circ10 = Circle(center,x//4, fill=False, edgecolor='green', linestyle='--', label=r"$10.2^\circ$")
circ5 = Circle(center,x//8, fill=False, edgecolor='purple', linestyle='--', label=r"$5.1^\circ$")

ax.add_patch(circ20)
ax.add_patch(circ15)
ax.add_patch(circ10)
ax.add_patch(circ5)

ax.legend(title='Excentricity')
plt.show()

#%% Function
def overlay_excentricity(img):
    (y, x) = img.shape
    center = (x//2,y//2)
    fig,ax = plt.subplots(1)
    plt.style.use('grayscale')

    plt.axis('off')
    ax.imshow(img)
    plt.xlim(-450, x + 450)

    circ20 = Circle(center,x//2, fill=False, edgecolor='red', linestyle='--', label=r"$20.4^\circ$")
    circ15 = Circle(center,3*x//8, fill=False, edgecolor='orange', linestyle='--', label=r"$15.3^\circ$")
    circ10 = Circle(center,x//4, fill=False, edgecolor='green', linestyle='--', label=r"$10.2^\circ$")
    circ5 = Circle(center,x//8, fill=False, edgecolor='purple', linestyle='--', label=r"$5.1^\circ$")

    ax.add_patch(circ20)
    ax.add_patch(circ15)
    ax.add_patch(circ10)
    ax.add_patch(circ5)
    
    ax.legend(title='Eccentricity')
    return fig

#%% plot random picture
path_out = Path('plots/excentricity/')
utils.check_mkdir(path_out)

files = random.sample(l_files, 10)

for file in files:
    img = cv2.imread(str(file))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # make overlay
    fig = overlay_excentricity(img)
    # savefig
    fig.savefig(path_out / file.name, dpi=300)

#%%



#%% Write TODO
#cv2.imwrite('untiled_shuffled.png', tiles_shuf)
