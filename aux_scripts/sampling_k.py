#%% 
import numpy as np

# %%
def sample_k(N, k):
  np.random.seed(np.random.choice(np.arange(2000)))
  return np.random.choice(N-(k-1), k, replace=False) + np.arange(k) + 1

# %%
sample_k(36, 18)
# %%
