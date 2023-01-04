#!/usr/bin/env elixir

# ------------------------------------------------------------------------------
# CSV input generated with query in prod:
# ------------------------------------------------------------------------------
# select srn.name as class, src.note as text
# from service_request_comments src
# join service_requests sr on sr.id = src.service_request_id
# join service_request_types srt on srt.id = sr.service_request_type_id
# join service_request_needs srn on sr.service_request_need_id = srn.id
# where srt.name = 'Care Gaps'

train = "test.csv"
check = "test.csv"

classifier =
  CareGapClassifier.init()
  |> CareGapClassifier.train_from_csv(train)

{right, wrong} =
  File.stream!(check)
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
