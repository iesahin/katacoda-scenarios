#!/bin/bash
# rerun the commands of the previous parts

set -o verbose

### Initialize a Git project
:; git init

### Initialize DVC
:; dvc init -q
:; git commit -m "Initialize DVC project"

### Get a data file
:; mkdir data
:; dvc get \
       https://github.com/iterative/dataset-registry \
       get-started/data.xml \
       -o data/data.xml

### Make it smaller
:; head -n 12000 data/data.xml > data/data.xml.1
:; mv data/data.xml.1 data/data.xml

### Track a data file
:; dvc add data/data.xml

### Commit to Git
:; git add data/.gitignore data/data.xml.dvc
:; git commit -m "Add raw data to project"

### Setup a data storage
:; dvc remote add --default mystorage /tmp/data-storage
:; git commit .dvc/config -m "Configure data storage"

### Push cached files to data storage
:; dvc push

### Get the code
:; wget https://code.dvc.org/get-started/code.zip
:; unzip code.zip
:; rm code.zip

### Install python requirements
:; virtualenv -p python3 .env
:; echo ".env/" >> .gitignore
:; source .env/bin/activate
:; pip install -r src/requirements.txt
:; git add .gitignore
:; git commit -m "Ignore virtualenv directory"

### Stage: prepare.dvc
:; dvc run \
       -f prepare.dvc \
       -d src/prepare.py \
       -d data/data.xml \
       -o data/prepared \
       python \
           src/prepare.py \
           data/data.xml
:; git add data/.gitignore prepare.dvc
:; git commit -m "Create data preparation stage"
:; dvc push