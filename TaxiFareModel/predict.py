import os
from math import sqrt

import joblib
import pandas as pd
from TaxiFareModel.params import MODEL_NAME, MODEL_VERSION, BUCKET_NAME, BUCKET_TEST_DATA_PATH
from TaxiFareModel.gcp import download_model
from google.cloud import storage
from sklearn.metrics import mean_absolute_error, mean_squared_error


class Predictor(object):

    PATH_TO_LOCAL_MODEL = 'data/Lasso.joblib'
    GCP_BUCKET_TEST_PATH = "gs://{}/{}".format(BUCKET_NAME, BUCKET_TEST_DATA_PATH)  

    def __init__(self, **kwargs):
        self.kwargs = kwargs
        self.local = kwargs.get("local", True)  
        self.nrows = kwargs.get("nrows", None)

    def get_test_data(self):
        """method to get the test data (or a portion of it) from google cloud bucket
        To predict we can either obtain predictions from train data or from test data"""
        # Add Client() here
        path = "data/test.csv"  # ⚠️ to test from actual KAGGLE test set for submission

        if self.local:
            df = pd.read_csv(path, nrows=self.nrows)
        else:
            df = pd.read_csv(self.GCP_BUCKET_TEST_PATH, nrows=self.nrows)
        return df


    def get_model(self):
        if self.local:
            pipeline = joblib.load(self.PATH_TO_LOCAL_MODEL)
        else:
            pipeline = self.download_model()
        return pipeline


    def evaluate_model(self, y, y_pred):
        MAE = round(mean_absolute_error(y, y_pred), 2)
        RMSE = round(sqrt(mean_squared_error(y, y_pred)), 2)
        res = {'MAE': MAE, 'RMSE': RMSE}
        return res


    def generate_submission_csv(self, kaggle_upload=False):
        df_test = self.get_test_data()
        if self.local:
            pipeline = joblib.load(self.PATH_TO_LOCAL_MODEL)
        else:
            pipeline = self.download_model()
        if "best_estimator_" in dir(pipeline):
            y_pred = pipeline.best_estimator_.predict(df_test)
        else:
            y_pred = pipeline.predict(df_test)
        df_test["fare_amount"] = y_pred
        df_sample = df_test[["key", "fare_amount"]]
        name = "data/predictions.csv"
        df_sample.to_csv(name, index=False)
        print("prediction saved under kaggle format")
        # Set kaggle_upload to False unless you install kaggle cli
        if kaggle_upload:
            kaggle_message_submission = name[:-4]
            command = f'kaggle competitions submit -c new-york-city-taxi-fare-prediction -f {name} -m "{kaggle_message_submission}"'
            os.system(command)


if __name__ == '__main__':

    # ⚠️ in order to push a submission to kaggle you need to use the WHOLE dataset
    p = Predictor(local= False)
    p.generate_submission_csv(kaggle_upload=False)

