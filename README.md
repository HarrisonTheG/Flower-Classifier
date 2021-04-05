# Flower-Classifier
iOS App on Flower Identification using machine learning model. Using phone camera to take picture of a flower, the result would be image and short description from Wikipedia

To Use this app:
1. Need to train for download your own FlowerClassifier mlmodel and renamed it as "FlowerClassifier.mlmodel"
2. Incorporate FlowerClassifier.mlmodel to .xworkspace project

Frameworks used on this project:
1. CoreML: to incorporate mlmodel and make prediction
2. Vision: to process input images
3. SDWebImage: to help on loading image asynchronously
4. Alamofire: to help on HTTP networking
5. SwiftyJSON: to help working with JSON data
