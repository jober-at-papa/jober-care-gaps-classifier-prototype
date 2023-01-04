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
        stem: &Stemmer.stem/1,
        model: :bernoulli
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
    |> Enum.reduce(classifier.model, fn {:ok, [false_pos, type, need, text]}, model ->
      qualifier =
        if false_pos == "f" do
          "spam"
        else
          "ham"
        end

      class = [type, need, qualifier] |> Enum.join(":")
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
