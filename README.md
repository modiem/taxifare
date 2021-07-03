# Taxifare Prediction
Deploy a Machine Learning API to predict taxifare in New York.
[live demo]: https://modiem.herokuapp.com/ 
 

[screenshot]: img/Screenshot.png "Screen Shot"

### Data
👉Training data came from kaggle compitation "New York City Taxi Fare Prediction"

```bash
kaggle competitions download -c new-york-city-taxi-fare-prediction
```
### Model
 👉 the `model.joblib` wraps a pipeline that covers both data transformation and model training.
``` python
print(model.named_steps["features"])

>>> ColumnTransformer(n_jobs=None, remainder='drop', sparse_threshold=0.3,
         transformer_weights=None,
         transformers=[('distance', Pipeline(memory=None,
     steps=[('distancetransformer', DistanceTransformer(distance_type='euclidian')), ('robustscaler', RobustScaler(copy=True, quantile_range=(25.0, 75.0), with_centering=True,
       with_scaling=True))]), ['pickup_latitude', 'pickup_longitude', 'drop...scaling=True))]), ['pickup_latitude', 'pickup_longitude', 'dropoff_latitude', 'dropoff_longitude'])]),
```
```python
print(model.named_steps["rgs"])

>>> Lasso(alpha=1.0, copy_X=True, fit_intercept=True, max_iter=1000,
   normalize=False, positive=False, precompute=False, random_state=None,
   selection='cyclic', tol=0.0001, warm_start=False)
```


### Usage 

- receive through route `/predict_fare`
```python
import requests

# fill the parameters for the prediction
params = dict(
  key='2012-10-06 12:10:20.0000001',
  pickup_datetime='2012-10-06 12:10:20 UTC',
  pickup_longitude=40.7614327,
  pickup_latitude=-73.9798156,
  dropoff_longitude=40.6413111,
  dropoff_latitude=-73.9797156,
  passenger_count=1
)

taxifare_api_url = "https://predict-taxifare-iwuisdewea-ez.a.run.app/predict_fare/"

# retrieve the response
response = requests.get(taxifare_api_url, params=params).json()

print(response)
```


