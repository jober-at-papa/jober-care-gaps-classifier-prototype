defmodule CareGapClassifier do
  alias SimpleBayes
  alias Stemmer

  defstruct [:model]

  @type t :: %__MODULE__{model: model}

  @type model :: %SimpleBayes{}

  @stop_words ~w(
    a about above after again against all am an and any are aren't as at be
    because been before being below between both but by can't cannot could
    couldn't did didn't do does doesn't doing don't down during each few for from
    further had hadn't has hasn't have haven't having he he'd he'll he's her here
    here's hers herself him himself his how how's i i'd i'll i'm i've if in into
    is isn't it it's its itself let's me more most mustn't my myself no nor not of
    off on once only or other ought our ours ourselves out over own same shan't
    she she'd she'll she's should shouldn't so some such than that that's the
    their theirs them themselves then there there's these they they'd they'll
    they're they've this those through to too under until up very was wasn't we
    we'd we'll we're we've were weren't what what's when when's where where's
    which while who who's whom why why's with won't would wouldn't you you'd
    you'll you're you've your yours yourself yourselves

    member
    @resolution
    outreach
    lvm
  )

  @spec init() :: t
  def init() do
    init(
      SimpleBayes.init(
        stem: &Stemmer.stem/1,
        model: :bernoulli,
        stop_words: @stop_words
      )
    )
  end

  @spec init(model) :: t
  def init(model), do: %__MODULE__{model: model}

  @spec load(String.t()) :: t
  def load(encoded_data) do
    init(SimpleBayes.load(encoded_data: encoded_data))
  end

  @spec save(t) :: String.t()
  def save(classifier) do
    {:ok, _pid, encoded_data} = SimpleBayes.save(classifier.model)
    encoded_data
  end

  @spec train_from_csv(t, String.t()) :: t
  def train_from_csv(classifier, csv_file) do
    File.stream!(csv_file)
    |> CSV.decode()
    |> Enum.reduce(classifier.model, fn {:ok, [class, text]}, model ->
      model |> SimpleBayes.train(class, text)
    end)
    |> init
  end

  @spec classify_one(t, String.t()) :: atom
  def classify_one(classifier, text) do
    classifier.model
    |> SimpleBayes.classify_one(text)
  end
end
