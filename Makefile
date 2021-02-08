# ----------------------------------
#         LOCAL SET UP
# ----------------------------------
install_requirements:
	@pip install -r requirements.txt

install:
	@pip install . -U

upload_simple_model:
	@python -m TaxiFareModel.trainer

# ----------------------------------
#         GCP SET UP & STORAGE
# ----------------------------------
# path of the file to upload to gcp (the path of the file should be absolute or should match the directory where the make command is run)
LOCAL_PATH=/Users/moyang/code/modiem/taxifare/data

# project id
PROJECT_ID=taxi-fare-303410

# bucket name
BUCKET_NAME= my_unsensitive_bucket

# bucket directory in which to store the uploaded file (we choose to name this data as a convention)
BUCKET_FOLDER=data

# name for the uploaded file inside the bucket folder (here we choose to keep the name of the uploaded file)
# BUCKET_FILE_NAME=another_file_name_if_I_so_desire.csv
BUCKET_FILE_NAME=$(shell basename ${LOCAL_PATH})

REGION=europe-west1

set_project:
	-@gcloud config set project ${PROJECT_ID}

create_bucket:
	-@gsutil mb -l ${REGION} -p ${PROJECT_ID} gs://${BUCKET_NAME}

upload_data:
	# -@gsutil cp train_1k.csv gs://wagon-ml-my-bucket-name/data/train_1k.csv
	-@gsutil cp -r ${LOCAL_PATH} gs://${BUCKET_NAME}
	# ${BUCKET_FOLDER}/${BUCKET_FILE_NAME}

# ----------------------------------
#         GCP AI Platform
# ----------------------------------
##### Machine configuration - - - - - - - - - - - - - - - -

REGION=europe-west4

PYTHON_VERSION=3.7
FRAMEWORK=scikit-learn
RUNTIME_VERSION=2.3

##### Training  - - - - - - - - - - - - - - - - - - - - - -

# will store the packages uploaded to GCP for the training
BUCKET_TRAINING_FOLDER = 'trainings'


##### Package params  - - - - - - - - - - - - - - - - - - -

PACKAGE_NAME=TaxiFareModel
FILENAME=trainer

##### Job - - - - - - - - - - - - - - - - - - - - - - - - -

JOB_NAME=taxi_fare_training_pipeline_$(shell date +'%Y%m%d_%H%M%S')

run_locally:
	@python -m ${PACKAGE_NAME}.${FILENAME}

gcp_submit_training:
	gcloud ai-platform jobs submit training ${JOB_NAME} \
		--job-dir gs://${BUCKET_NAME}/${BUCKET_TRAINING_FOLDER} \
		--package-path ${PACKAGE_NAME} \
		--module-name ${PACKAGE_NAME}.${FILENAME} \
		--python-version=${PYTHON_VERSION} \
		--runtime-version=${RUNTIME_VERSION} \
		--region ${REGION} \
		--stream-logs

# ----------------------------------
#         API COMMANDS
# ----------------------------------

deploy_gcp:
	gcloud run deploy \
		--image eu.gcr.io/taxi-fare-303410/api \
		--platform managed \
		--region europe-west4 \
		--set-env-vars "GOOGLE_APPLICATION_CREDENTIALS=/credentials.json"

# ----------------------------------
#    CLEANING COMMAND
# ----------------------------------

clean:
	@rm -fr */__pycache__
	@rm -fr __pycache__
	@rm -fr */.ipynb_checkpoints
	@rm -fr .ipynb_checkpoints
	@rm -fr __init__.py
	@rm -fr build
	@rm -fr dist
	@rm -fr $TaxiFareModel-*.dist-info
	@rm -fr $TaxiFareModel.egg-info

##### Prediction API - - - - - - - - - - - - - - - - - - - - - - - - -

run_api:
	uvicorn api.fast:app --reload  # load web server with code autoreload

