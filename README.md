# CareGapClassifier

Prototype to use a naive bayesian filter to automatically classify
`service_requests.description` text by `service_request_needs.name`.

```
$ mix run bin/test-it-out.exs
Of 4735 entries, classified 4735 (100.0 %) correctly.
```

**Training data:** https://joinpapa.looker.com/sql/k4rwvgfgg6gzjs

**Practice data:** https://joinpapa.looker.com/sql/h98w8455fpmxjg

# TODO
* Not sure if necessary, but training data to identify when there _is_ no care gap?
