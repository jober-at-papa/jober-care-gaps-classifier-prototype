# CareGapClassifier

Prototype to use a naive bayesian filter to automatically classify
`service_requests.description` text by `service_request_needs.name`.

```
$ bin/build-test-data 100 > check.csv
$ bin/build-test-data 3000 > train.csv
$ mix run bin/test-it-out.exs
Of 4735 entries, classified 4735 (100.0 %) correctly.
```

# Training data

`test-full.csv` was exported from https://joinpapa.looker.com/sql/ts3vkvdbwjxtjg

# TODO
* Not sure if necessary, but training data to identify when there _is_ no care gap?
