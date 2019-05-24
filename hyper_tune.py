from paperspace-sdk import hyper_tune
from .model import train_model

hparam_def = {
    "dense_len": 8 + hp.randint("dense_len", 120),
    "dropout": hp.uniform("dropout", 0., 0.8),
    "activation": hp.choice("activation", ["relu", "tanh", "sigmoid"]),
}

hyper_tune(train_model, hparam_def, algo=tpe.suggest, max_evals=25)
