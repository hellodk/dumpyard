#!/bin/bash
#
# A script to automate updating the images to use in the ksonnet
# components.
# This script contains the most recent commands run.
# You can update it to run the latest images.
#
# This won't actually update any tags on images. It will just update
# image_tags.yaml
#
# If image_tags.yaml looks good invoke apply_tags.py
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd ${DIR}/.. && pwd )"

IMAGES_FILE=${ROOT_DIR}/releasing/image_tags.yaml

# Assume the testing repo is checkout in git_kubeflow_testing because 
# we depend on the python code in that repo.
export PYTHONPATH=${PYTHONPATH}:${ROOT_DIR}/../git_kubeflow-testing/py

JUPYTER_TAG=v20180707-5a11c84d
RELEASE=v0.2.1

# Fetch shas for Jupyter images
python ${ROOT_DIR}/releasing/add_image_shas.py --pattern=.*tensorflow.*1.*notebook.*:${JUPYTER_TAG} \
	--images_file=${IMAGES_FILE}

# Tag the Jupyter images we want with the desired relase tag.
python ${ROOT_DIR}/releasing/add_image_tag.py --pattern=.*tensorflow.*1.*notebook.*:${JUPYTER_TAG} --tag=${RELEASE} \
    --images_file=${IMAGES_FILE}
