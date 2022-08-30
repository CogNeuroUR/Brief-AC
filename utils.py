import os

import cv2

def check_stem(fname, n_items=8):
    """Checks whether given (image) file name contains a given nr. of words (splits)."""
    if not len(fname.split('_')) == n_items:
        raise Exception(f'Given file name contains a wrong nr. of splits ({n_items})! ({fname})')
    return n_items

def check_items_in_stem(fname, n_items=8):
    """Checks whether given (image) file name contains a given nr. of words (splits)."""
    if not len(fname.split('_')) == n_items:
        return False
        #raise Exception(f'Given file name contains a wrong nr. of splits ({n_items})! ({fname})')
    return True

def check_ctxt_congruency(fname, debug=False):
    """
    Checks the context congruency based on the items in the picture file name.
    IDEA: having a filename composed of items that are split by underscores,
    extract the context congruency based on a naming lookup table.
    
    Parameters:
    -----------
    fname : str or pathlike
        Picture file name.
    debug : bool
        Debugging (True for some verbose.)
        
        
    Returns
    -------
    True, if context exemplar and action's source context are compatible,
    otherwise False.
    """
    
    # Lookup table
    dict_lookup = {
    'camera' : 0,
    'img_nr' : 1,
    'ctxt_exemplar' : 2,
    'ctxt' : 3,
    'action' : 4,
    'condition' : 5,
    'view' : 6,
    'actor' : 7
    }
    
    test = ['kitchen', 'office', 'workshop']
    ctxt_exemplar = fname.split('_')[dict_lookup['ctxt_exemplr']].split('-')[0]
    ctxt = fname.split('_')[dict_lookup['ctxt']]
    
    if debug:
        print('Checking:', fname)
        print('\tExemplar:', ctxt_exemplar)
        print('\tContext:', ctxt)
    
    # initial check
    if ctxt_exemplar not in test:
        raise Exception('Wrong ctxt_exemplar name:', ctxt_exemplar)
    if ctxt not in test:
        raise Exception(f'Wrong ctxt name "{ctxt}" in {fname}')
    
    # final check
    if ctxt_exemplar == ctxt:
        return True
    else:
        return False
    

def fname_lookup_table():
    # Lookup table
    dict_lookup = {
    'camera' : 0,
    'img_nr' : 1,
    'ctxt_exemplar' : 2,
    'ctxt' : 3,
    'action' : 4,
    'condition' : 5,
    'view' : 6,
    'actor' : 7
    }
    return dict_lookup
    
def check_user_input(message='Are you sure you want to perform this operation? (y/n)'):
    print(message)
    if input('Your call: ') == 'y':
        print('Confirmed.')
        return True
    else:
        print('Declined!')
        return False
    
def check_mkdir(path):
  """
  Check if folder "path" exists. If not, creates one. 
  
  Returns
  -------
  If exists, returns "True", otherwise create a folder at "path" and return "False"
  """
  if not os.path.exists(path):
    os.mkdir(path)
    return False
  else:
    return True

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