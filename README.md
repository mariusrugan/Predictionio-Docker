# Predictionio-Docker
We at Cents for Change use [Apache Incubator's Prediction.io](https://predictionio.incubator.apache.org/). Upon doing some research, we didn't find a docker image that fit our needs (the latest of everything, and Prediction.io 0.11.0).

## Alpine
Furthermore, most boxes we found were using Debian or Ubuntu-- we wanted something lighter, so this docker image uses alpine. Given the number of dependencies, it's still not super fast to download, but it helps!
