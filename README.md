# Deploy ML API serving predictions
Here you'll be able to deploy a minimal API to return predictions from pretrained model.

## Summary

### Data
Training data came from kaggle compitation "New York City Taxi Fare Prediction"
👉
```bash
kaggle competitions download -c new-york-city-taxi-fare-prediction
```
### Model
 👉 this `model.joblib` contains the whole pipeline (preprocssing + model)

### API
- receive through route `/predict_fare`, jsons looking like:
```python
input = {"pickup_datetime": 2012-12-03 13:10:00 UTC,
        "pickup_latitude": 40.747,
        "pickup_longitude": -73.989,
        "dropoff_latitude": 40.802,
        "dropoff_longitude": -73.956,
        "passenger_count": 2}
```
- apply predictions
- return predictions


