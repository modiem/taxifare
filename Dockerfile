FROM python:3.7-buster

COPY api /api
COPY TaxiFareModel /TaxiFareModel
COPY data/model.joblib /model.joblib
COPY requirements.txt /requirements.txt
COPY /Users/moyang/Documents/gcp_keys/taxi-fare-60841db7983e.json /credentials.json

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

CMD uvicorn api.fast:app --host 0.0.0.0 --port $PORT
