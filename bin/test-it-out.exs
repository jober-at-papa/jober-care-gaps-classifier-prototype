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

data = "test-full.csv"
threshold = 0.5

IO.puts("Training...")

classifier = CareGapClassifier.new_from_csv(data)

IO.puts("Classifying...")

{right, wrong, unsure} =
  File.stream!(data)
  |> CSV.decode()
  |> Enum.reduce({0, 0, 0}, fn {:ok, [_fp, type, need, text]}, {right, wrong, unsure} ->
    classifier
    |> CareGapClassifier.classify(text, threshold: threshold)
    |> case do
      {:unsure, _} -> {right, wrong, unsure + 1}
      {_, :unsure} -> {right, wrong, unsure + 1}
      {^type, ^need} -> {right + 1, wrong, unsure}
      _ -> {right, wrong + 1, unsure}
    end
  end)

total = right + wrong + unsure
total_classified = right + wrong

pct_unsure = (unsure / total * 100) |> Float.round(2)

pct_right = (right / total_classified * 100) |> Float.round(2)
pct_right_total = (right / total * 100) |> Float.round(2)

pct_wrong = (wrong / total_classified * 100) |> Float.round(2)
pct_wrong_total = (wrong / total * 100) |> Float.round(2)

id_threshold = (threshold * 100) |> Float.round(2)

IO.puts("""
--------------------------------------------------------------------------------
   Total: #{total}
  Unsure: #{unsure} - #{pct_unsure}% (identification threshold: #{id_threshold}%)
   Right: #{right} - #{pct_right}% of those classified, #{pct_right_total}% of total
   Wrong: #{wrong} - #{pct_wrong}% of those classified, #{pct_wrong_total}% of total
--------------------------------------------------------------------------------
""")
