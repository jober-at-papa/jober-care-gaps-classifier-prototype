# CareGapClassifier

Prototype to use a naive bayesian filter to automatically classify
`service_requests.description` text by `service_request_needs.name`.

```
$ mix run bin/test-it-out.exs

Training...
Classifying...
--------------------------------------------------------------------------------
   Total: 80731
  Unsure: 26798 - 33.19% (identification threshold: 50.0%)
   Right: 27113 - 50.27% of those classified, 33.58% of total
   Wrong: 26820 - 49.73% of those classified, 33.22% of total
--------------------------------------------------------------------------------
```

# Training data

`test-full.csv` was exported from https://joinpapa.looker.com/sql/ts3vkvdbwjxtjg
