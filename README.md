# ISC 2021 Term Project

Status: Not started

This repository contains code for the Image Similarity Challenge 2021.****

[https://github.com/facebookresearch/isc2021](https://github.com/facebookresearch/isc2021)

# **Getting started**

The [docs](https://github.com/facebookresearch/isc2021/blob/main/docs)  subdirectory has step-by-step instructions on how to reproduce the baseline results from the paper.

# Run script

```bash
root@9e23863b293e:/isc2021_term_project#bash run.sh
```

```bash
############# run.sh #############
##################################

#!bin/bash
############# CONFIG #############
MODEL='ssl_resnet50'
BATCH_SIZE=32
echo $MODEL

############# PCA Whitening #############
python baselines/GeM_baseline.py \
    --model $MODEL \
    --file_list list_files/train \
    --checkpoint /root/.cache/torch/hub/checkpoints/semi_supervised_resnet50-08389792.pth \
    --image_dir images/train \
    --pca_file data/pca_$MODEL.vt \
    --n_train_pca 10000 \
    --train_pca
         
############# FEATURE EXTRACTING #############
############# dev queries #############
python baselines/GeM_baseline.py \
    --model $MODEL \
    --checkpoint /root/.cache/torch/hub/checkpoints/semi_supervised_resnet50-08389792.pth \
    --batch_size $BATCH_SIZE \
    --file_list list_files/dev_queries \
    --image_dir images/dev_queries \
    --o data/dev_queries_ssl_resnet50.hdf5 \
    --pca_file data/pca_$MODEL.vt

############# final queries #############
python baselines/GeM_baseline.py \
    --model $MODEL \
    --checkpoint /root/.cache/torch/hub/checkpoints/semi_supervised_resnet50-08389792.pth \
    --batch_size $BATCH_SIZE \
    --file_list list_files/final_queries \
    --image_dir images/final_queries \
    --o data/final_queries_ssl_resnet50.hdf5 \
    --pca_file data/pca_$MODEL.vt

############ reference #############
python baselines/GeM_baseline.py \
    --model $MODEL \
    --checkpoint /root/.cache/torch/hub/checkpoints/semi_supervised_resnet50-08389792.pth \
    --batch_size $BATCH_SIZE \
    --file_list list_files/references \
    --image_dir images/references \
    --o data/references_${MODEL}.hdf5 \
    --pca_file data/pca_${MODEL}.vt

############# train #############
python baselines/GeM_baseline.py \
    --model $MODEL \
    --checkpoint /root/.cache/torch/hub/checkpoints/semi_supervised_resnet50-08389792.pth \
    --batch_size $BATCH_SIZE \
    --file_list list_files/train \
    --image_dir images/train \
    --o data/train_${MODEL}.hdf5 \
    --pca_file data/pca_${MODEL}.vt

#############################################

############# EVALUATION #############
############# dev queries score normalization #############
python scripts/score_normalization.py \
    --query_descs data/dev_queries_${MODEL}.hdf5 \
    --db_descs data/references_${MODEL}.hdf5 \
    --train_descs data/train_${MODEL}.hdf5 \
    --factor 2.0 --n 10 \
    --o data/predictions_dev_queries_normalized_${MODEL}.csv

############# final queries score normalization #############
python scripts/score_normalization.py \
    --query_descs data/final_queries_${MODEL}.hdf5 \
    --db_descs data/references_${MODEL}.hdf5 \
    --train_descs data/train_${MODEL}.hdf5 \
    --factor 2.0 --n 10 \
    --o data/predictions_final_queries_normalized_${MODEL}.csv

############# evaluate  #############
python scripts/compute_metrics.py \
    --preds_filepath data/predictions_dev_queries_normalized_${MODEL}.csv \
    --gt_filepath list_files/dev_ground_truth.csv
```

# Result

```bash
root@9e23863b293e:/isc2021_term_project#bash run.sh
Track 1 result of 500000 predictions (5000 GT matches)
Average Precision: 0.41759
Recall at P90    : 0.16400
Threshold at P90 : 0.16499
Recall at rank 1:  0.51340
Recall at rank 10: 0.59000
```