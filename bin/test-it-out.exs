#!/usr/bin/env elixir

# ------------------------------------------------------------------------------
# CSV input generated with query in prod:
# ------------------------------------------------------------------------------
# select srn.name as class, string_agg(srn.description, '|') as text
# from service_requests sr
# join service_request_types srt on srt.id = sr.service_request_type_id
# join service_request_needs srn on sr.service_request_need_id = srn.id
# where srt.name = 'Care Gaps'
# group by srn.name

classifier =
  CareGapClassifier.init()
  |> CareGapClassifier.train_from_csv("training_input.csv")

{right, wrong} =
  File.stream!("test_input.csv")
  |> CSV.decode()
  |> Enum.reduce({0, 0}, fn {:ok, [class, text]}, {right, wrong} ->
    guess = classifier |> CareGapClassifier.classify_one(text)

    if guess == class do
      {right + 1, wrong}
    else
      {right, wrong + 1}
    end
  end)

pct = (right / (right + wrong) * 100) |> Float.round(2)
IO.puts("Of #{right + wrong} entries, classified #{right} (#{pct} %) correctly.")
