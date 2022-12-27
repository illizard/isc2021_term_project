#!bin/bash
MODEL='ssl_resnet50'
echo $MODEL
############# Query #############
# python baselines/GeM_baseline.py \
#     --model MODEL \
#     --file_list list_files/dev_queries \
#     --image_dir images/dev_queries \
#     --o data/queries_ssl_resnet50.hdf5 \
#     --pca_file data/pca_ssl_resnet50.vt

############ Reference #############
python baselines/GeM_baseline.py \
   --model $MODEL \
   --batch_size 32 \
   --file_list list_files/references \
   --image_dir images/references \
   --o data/references_${MODEL}.hdf5 \
   --pca_file data/pca_${MODEL}.vt

# ############# Train #############
# python baselines/GeM_baseline.py \
#     --model ssl_resnet50 \
#     --file_list list_files/train \
#     --image_dir images/train \
#     --o data/train_ssl_resnet50.hdf5 \
#     --pca_file data/pca_ssl_resnet50.vt

############# dev q score_normalization #############
python scripts/score_normalization.py \
    --query_descs data/dev_queries_${MODEL}.hdf5 \
    --db_descs data/references_${MODEL}.hdf5 \
    --train_descs data/train_${MODEL}.hdf5 \
    --factor 2.0 --n 10 \
    --o data/predictions_dev_queries_normalized_${MODEL}.csv

############# final q score_normalization #############
python scripts/score_normalization.py \
    --query_descs data/final_queries_${MODEL}.hdf5 \
    --db_descs data/references_${MODEL}.hdf5 \
    --train_descs data/train_${MODEL}.hdf5 \
    --factor 2.0 --n 10 \
    --o data/predictions_final_queries_normalized_${MODEL}.csv

# ############# evaluate  #############
# python scripts/compute_metrics.py \
#     --preds_filepath data/predictions_dev_queries_normalized.csv \
#     --gt_filepath list_files/dev_ground_truth.csv