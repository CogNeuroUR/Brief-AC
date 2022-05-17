from codecs import ignore_errors
import importlib
import os
import pathlib
from pathlib import Path
import shutil

import cv2
import numpy as np
import pandas as pd

from tqdm import tqdm
import matplotlib.pyplot as plt

import utils
importlib.reload(utils)

class StimulusSet:
    def __init__(self, path, fname_lookup, format='JPG', name='stimulus set',
                 keep_outliers=True, ignore_pattern=None):
        if type(path) != pathlib.PosixPath:
            path = pathlib.Path(path)
        self.path = path
        if type(fname_lookup) == dict:
            self.fname_lookup = fname_lookup
        self.name = name
        self.format = format
        self.filelist = list(path.glob(f'**/*.{format}'))
        print('Found files:', len(self.filelist))
        
        self.ignore_pattern = ignore_pattern
        if self.ignore_pattern != None:
            # check if string
            if type(self.ignore_pattern) == str:
                # remove files from filelist that contain the given pattern
                self.filelist = [fname for fname in self.filelist if self.ignore_pattern not in fname.stem]
            else:
                raise Exception(f'Given pattern to be ignored (\'{self.ignore_pattern}\') is not a string!')
            
        self.keep_outliers = keep_outliers
        if not self.keep_outliers:
            # if True, remove files from filelist that have a diff. stem
            self.filelist = self.check_fname_structure()
        
        self.df = self.create_dataframe()
    
    # TODO: implement multi-type sets, i.e. with multiple look-up tables (like for iso-context, resting, action).
        
    # instance methods
    def check_stem(self, fname, n_items=8, error=False):
        """Checks whether given (image) file name contains a given nr. of words (splits)."""
        if not len(fname.split('_')) == n_items:
            if error:
                raise Exception(f'Given file name contains a wrong nr. of splits ({n_items})! ({fname})')
            print(f'{fname} has a different nr. of items than {n_items}!')
        return len(fname.split('_')) == n_items
    
    def check_fname_structure(self):
        filelist = []
        for fname in self.filelist:
            if self.check_stem(fname.stem, len(self.fname_lookup.keys())):
                filelist.append(fname)
            else:
                if self.keep_outliers:
                    filelist.append(fname)
                  
        print('Files checked!')
        return filelist
    
    def create_dataframe(self, sort_by=['ctxt', 'ctxt_exemplar', 'view', 'action', 'actor']):
        l_collection = []
        for fname in self.filelist:
            self.check_stem(str(fname.stem), len(self.fname_lookup.keys()))
            l_items = []
            for i in range(len(self.fname_lookup.keys())):
                l_items.append(fname.stem.split('_')[i])
            l_collection.append(l_items + [fname, fname.name])
        
        columns = [key for key in self.fname_lookup.keys()] #+ ['new_fname']
        df = pd.DataFrame(l_collection, columns=columns + ['path_to_file', 'fname'])
        df.sort_values(by=sort_by, inplace=True, ignore_index=True)
        
        print('Dataframe initialized.')
        return df
    
    def general_info(self):
        print('Gathering info ...')
        resolutions = []
        for index, row in self.df.iterrows():
            img = cv2.imread(str(row['path_to_file']), cv2.IMREAD_UNCHANGED)
            l_resolutions.append(img.shape)
        #l_resolutions = np.unique(l_resolutions)
        
        #print('Resolutions (aspect ratios) found:')
        #print([(x[:2], x[1]/x[0]) for x in l_resolutions])
        
        return l_resolutions
    
    def rename(self, name_structure=[]):
        """Rename files by removing or re-ordering items in fnames."""
        
        if not name_structure:
            name_structure = [key for key in self.fname_lookup.keys()]
        else:
            # check if given structure items are in the fname_lookup
            for key in name_structure:
                if key not in self.fname_lookup.keys():
                    raise Exception('Given item is not in fname_lookup:', key)
        
        # iterate over items in df
        for index, row in tqdm(self.df.iterrows()):
            # define new name
            stem = '_'.join([row[x] for x in name_structure]) 
            fname = stem + '.' + self.format
            row['fname'] = fname
            
        return self.df
    
    def to_grayscale(self, img):
        return cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    def write_files(self, path_out, size='same', color='same'):
        utils.check_mkdir(path_out)    
        
        # iterate over items in df
        for index, row in tqdm(self.df.iterrows()):
            path_outfile = Path(path_out) / row['fname']
            # resize, if requested
            if size != 'same':
                if type(size) == int:
                    width = size
                    height = None
                elif len(size) == 2:
                    width = max(size)
                    height = min(size)
                    
                img = cv2.imread(str(row['path_to_file']), cv2.IMREAD_UNCHANGED)
                
                
                img = utils.image_resize(img, width=width, height=height)
                
                #print(img.shape)
                # convert to grayscale if requested
                if color == 'gray':
                    img = self.to_grayscale(img)
                cv2.imwrite(str(path_outfile), img)
            else:
                shutil.copy(src=row['path_to_file'], dst=path_outfile)


    def visualize_grid(self, plot=True, savefig=False, save_path='grid.pdf',
                       dpi=200, size_pic=(640*3, 427*3)):
        # TODO: make it generalizable, by removing the following param definitions
        n_ctxts = len(self.df['ctxt'].unique())
        n_ctxt_exs = 2
        n_actors = len(self.df['actor'].unique())
        n_views = len(self.df['view'].unique())
        n_actions = 3

        n_rows = n_actions*n_actors*n_views
        n_columns = n_ctxts*n_ctxt_exs

        print('N_rows: ', n_rows)
        print('N_columns: ', n_columns)
        print('N_files: ', len(self.df))

        with plt.style.context('dark_background'):
            fig, ax = plt.subplots(n_rows,
                                n_columns,
                                dpi=dpi,
                                figsize=(n_columns*3, n_rows*2))

        # plot in a column-wise manner (each column : context exemplar)
        for j in tqdm(range(len(self.df.ctxt_exemplar.unique()))):
            ctxt_exemplar = self.df.ctxt_exemplar.unique()[j]
            for index, row in self.df[self.df.ctxt_exemplar == ctxt_exemplar].iterrows():
                i = index - n_rows*j
                #print(f'index={index}, row={i}, col={j}')
                
                if plot:
                    img = cv2.resize(cv2.imread(str(row['path_to_file']), cv2.IMREAD_UNCHANGED), size_pic)
                    ax[i, j].imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
                label = row['action'] #+ ' ' + row['actor']
                #ax[i, j].set_title(label)
                ax[i, j].set_xlabel(label)

        for a, col in zip(ax[0, :], self.df.ctxt_exemplar.unique()):
            a.set_title(col, fontsize=20)
            
        for a, row in zip(ax[:, 0], list(self.df.actor.unique())*6):
            a.set_ylabel(row, fontsize=10)

        for a in ax.flat:
            a.set_xticks([])
            a.set_yticks([])
        plt.tight_layout(h_pad=0.5, w_pad=0.5)
        if savefig:
            plt.savefig(save_path)
    