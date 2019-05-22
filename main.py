import os
from gradient_statsd import Client
from datetime import datetime, timedelta
from random import randint
import time
import sys
import pickle
import pandas as pd
import numpy as np
import csv
import collections
import sqlite3
import json
import copy
import shutil
import logging

# from uniseg.wordbreak import word_break, words
import tldextract
import nvector as nv
from sklearn.metrics.pairwise import pairwise_distances, cosine_similarity
import usaddress

# from urlparse import urlparse
from urllib.parse import urlparse
import re
from string import punctuation
from sklearn.model_selection import train_test_split
from sklearn.neighbors import NearestNeighbors
from scipy.spatial.distance import cosine, cdist
from scipy.sparse import coo_matrix, csr_matrix, hstack

# from nltk.util import ngrams
import difflib

import multiprocessing as mp

from scipy.sparse.csgraph import connected_components
from sklearn.metrics import precision_score, recall_score

import random

from fastai import *

from fastai.text import *
from fastai.utils import mem
import copy

# ------------------------------------------------
print(os.listdir("/storage"))

PLACES_DIR = "data/places_03_enc/places/"

good_places = pickle.load(open("data/places_03/good_place_set.p", "rb"))

place_to_true = pickle.load(open("data/place_to_true_03.p", "rb"))
true_sets = pickle.load(open("data/true_sets_03.p", "rb"))
place_false_tpcs = pickle.load(open("data/place_false_tpcs_03.p", "rb"))
place_to_tpc = pickle.load(open("data/place_to_tpc_03.p", "rb"))
tpc_places = pickle.load(open("data/tpc_places_03.p", "rb"))
tag_places = pickle.load(open("data/tag_places_03.p", "rb"))


def tokenize(inp, _type: "desc", excl=[]):
    excl = set(excl)
    if _type == "tag":
        excl.update(
            [
                "xxpad",
                "xxbos",
                "xxeos",
                "xxfld",
                "xxrep",
                "xxwrep",
                "=",
                ".",
                ",",
                "&",
                "/",
                "-",
                ":",
            ]
        )
        inp = inp.lower().replace("_", " ").replace(";", " ")
    elif _type == "name":
        excl.update(
            [
                "xxpad",
                "xxbos",
                "xxeos",
                "xxfld",
                "xxrep",
                "xxwrep",
                "=",
                ".",
                ",",
                "&",
                "/",
                "-",
                ":",
            ]
        )
        inp = inp.lower().replace("_", " ").replace(";", " ")
    toks = []
    for tok in tokenizer.process_one(inp):
        if tok not in excl:
            toks.append(tok)
    return toks


source_id_to_idx = pickle.load(open("data/source_id_to_idx_02.p", "rb"))
source_idx_to_name = pickle.load(open("data/source_idx_to_name_02.p", "rb"))
source_id_to_name = pickle.load(open("data/source_id_to_name_02.p", "rb"))
NUM_SOURCES = len(source_id_to_idx)

tag_tok_to_idx = pickle.load(open("data/tag_tok_to_idx_02.p", "rb"))
tag_idx_to_tok = pickle.load(open("data/tag_idx_to_tok_02.p", "rb"))

tag_name_to_id = {}
with open("data/pickle_jar/tag_names.csv", "r") as f:
    reader = csv.reader(f)
    for row in reader:
        tag_name_to_id[row[1]] = int(row[0])

tag_idfs = pickle.load(
    open("data/pickle_jar/category_idfs.p", "rb"), fix_imports=True, encoding="latin1"
)

global_idfs = pickle.load(
    open("data/pickle_jar/global_idfs.p", "rb"), fix_imports=True, encoding="latin1"
)

locality_idfs = pickle.load(open("data/locality_idfs_03.p", "rb"))

address_idfs = pickle.load(
    open("data/pickle_jar/location_idfs.p", "rb"), fix_imports=True, encoding="latin1"
)
address_idfs["__DEFAULT__"] = {"__DEFAULT__": 1.0}

tok_means = np.load("data/pickle_jar/tok_mean.npy")
tok_stds = np.load("data/pickle_jar/tok_std.npy")

geo_means = np.load("data/pickle_jar/geo_mean.npy")
geo_stds = np.load("data/pickle_jar/geo_std.npy")

loc_to_idx = pickle.load(
    open("data/pickle_jar/loc_to_idx.p", "rb"), fix_imports=True, encoding="latin1"
)

web_to_idx = pickle.load(
    open("data/pickle_jar/web_to_idx.p", "rb"), fix_imports=True, encoding="latin1"
)

tok_type_to_idx = {"name_tok": 0, "name_punct": 1}
idx = 2
for dd in [loc_to_idx, web_to_idx]:
    for k in dd.keys():
        tok_type_to_idx[k] = idx
        idx += 1

NUM_TOK_TYPES = len(tok_type_to_idx)

loc_keys_array = np.load("data/loc_keys_array.npy")

loc_key_nbrs = NearestNeighbors(n_neighbors=2, algorithm="ball_tree").fit(
    loc_keys_array
)


def nearest_loc_key(lng, lat):
    inp = np.array([[lng, lat]])
    dist, idx = loc_key_nbrs.kneighbors(inp)
    nearest = idx[0][0]
    loc_key_string = loc_keys_strings[nearest]

    return loc_key_string


def dedupe_loc_parse(parsed_list, orig_string):
    out_dict = {}
    for val, key in parsed_list:
        if key not in out_dict:  # place first instance of each in the out_dict
            out_dict[key] = val
    return out_dict
