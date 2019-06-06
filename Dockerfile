FROM paperspace/fastai:1.0-CUDA9.2-base-3.0-v1.0.6

RUN env

COPY requirements.txt /root

RUN pip install --upgrade --requirement /root/requirements.txt

