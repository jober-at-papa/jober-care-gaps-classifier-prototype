#!/usr/bin/env elixir

# ------------------------------------------------------------------------------
# CSV input generated with query in prod:
#
#     https://joinpapa.looker.com/sql/ts3vkvdbwjxtjg
# ------------------------------------------------------------------------------
# SELECT (sr.status = 'CLOSED-NOT A NEED')                AS false_positive
#      , srt.code                                         AS type
#      , srn.name                                         AS need
#      , REGEXP_REPLACE(sr.description, '\s+', ' ', 'ng') AS text
#   FROM service_requests sr
#   JOIN service_request_types srt ON srt.id = sr.service_request_type_id
#   JOIN service_request_needs srn ON sr.service_request_need_id = srn.id
#  WHERE sr.status NOT IN ('NEW', 'IN PROGRESS')
# ------------------------------------------------------------------------------

train = "train.csv"
check = "check.csv"

IO.puts("Training...")

classifier =
  CareGapClassifier.init()
  |> CareGapClassifier.train_from_csv(train)

IO.puts("Classifying...")

check_data = File.stream!(check) |> CSV.decode() |> Enum.to_list()
num_rows = check_data |> length

{right, wrong} =
  check_data
  |> Enum.reduce({0, 0}, fn {:ok, [false_pos, type, need, text]}, {right, wrong} ->
    ProgressBar.render(right + wrong, num_rows)

    qualifier =
      if false_pos == "f" do
        "spam"
      else
        "ham"
      end

    class = [type, need, qualifier] |> Enum.join(":")
    guess = classifier |> CareGapClassifier.classify_one(text)

    if guess == class do
      {right + 1, wrong}
    else
      {right, wrong + 1}
    end
  end)

pct = (right / (right + wrong) * 100) |> Float.round(2)
IO.puts("Of #{right + wrong} entries, classified #{right} (#{pct} %) correctly.")
