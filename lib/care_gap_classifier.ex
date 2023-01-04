defmodule CareGapClassifier do
  alias SimpleBayes
  alias Stemmer

  defstruct [:model]

  @type t :: %__MODULE__{model: model}

  @type model :: %SimpleBayes{}

  @spec init() :: t
  def init() do
    init(
      SimpleBayes.init(
        model: :bernoulli,
        stem: &Stemmer.stem/1,
        smoothing: 0.5
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
