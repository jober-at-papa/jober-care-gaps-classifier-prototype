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

# train = "train.csv"
train = "test-full.csv"
check = "check.csv"

{args, _, _} =
  OptionParser.parse(
    System.argv(),
    strict: [
      train: :integer,
      check: :integer
    ]
  )

IO.puts("Building training and verification data...")
pwd = System.get_env("PWD")
# System.cmd("#{pwd}/bin/build-test-data", [args[:train] |> Integer.to_string(), train])
System.cmd("#{pwd}/bin/build-test-data", [args[:check] |> Integer.to_string(), check])

IO.puts("Training...")

classifier = CareGapClassifier.from_csv(train)

IO.puts("Classifying...")

{right, wrong} =
  File.stream!(check)
  |> CSV.decode()
  |> Enum.to_list()
  |> Enum.reduce({0, 0}, fn {:ok, [_fp, type, need, text]}, {right, wrong} ->
    guess = classifier |> CareGapClassifier.classify(text)
    ProgressBar.render(right + wrong, args[:check])

    # IO.puts("--------------------------------------------------------------------------------")
    # IO.puts("  TOKENS: #{text}")
    # IO.puts("EXPECTED: #{{type, need} |> inspect}")
    # IO.puts("     GOT: #{guess |> inspect}")

    if guess == {type, need} do
      {right + 1, wrong}
    else
      {right, wrong + 1}
    end
  end)

pct = (right / (right + wrong) * 100) |> Float.round(2)
IO.puts("\nOf #{right + wrong} entries, classified #{right} (#{pct} %) correctly.")
