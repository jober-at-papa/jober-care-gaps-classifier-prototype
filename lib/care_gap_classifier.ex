defmodule CareGapClassifier do
  defstruct types: Bayesic.Trainer.new(),
            needs: %{}

  @finalize_opts [pruning_threshold: 0.5]

  def new(), do: %__MODULE__{}
  def new(types, needs), do: %__MODULE__{types: types, needs: needs}

  def new_from_csv(csv_file) do
    File.stream!(csv_file)
    |> CSV.decode()
    |> Enum.reduce(new(), fn {:ok, [_false_positive, type, need, text]}, classifier ->
      tokens = text |> String.split() |> stem()
      classifier |> train(type, need, tokens)
    end)
    |> finalize()
  end

  def train(classifier, type, need, tokens) do
    %__MODULE__{
      types:
        classifier.types
        |> Bayesic.train(tokens, type),
      needs:
        classifier.needs
        |> Map.put(
          type,
          Map.get(classifier.needs, type, Bayesic.Trainer.new()) |> Bayesic.train(tokens, need)
        )
    }
  end

  defp finalize(classifier) do
    %__MODULE__{
      types:
        classifier.types
        |> Bayesic.finalize(@finalize_opts),
      needs:
        classifier.needs
        |> Enum.map(fn {type, trainer} -> {type, trainer |> Bayesic.finalize(@finalize_opts)} end)
        |> Map.new()
    }
  end

  def classify(classifier, input, opts) do
    threshold = Keyword.get(opts, :threshold, 0.5)
    tokens = input |> stem

    type =
      classifier.types
      |> Bayesic.classify(tokens)
      |> Enum.max_by(fn {_, v} -> v end, fn -> {:unsure, nil} end)

    need =
      case type do
        {:unsure, nil} ->
          {:unsure, nil}

        {_, pct} when pct <= threshold ->
          {:unsure, nil}

        {type, _} ->
          classifier.needs[type]
          |> Bayesic.classify(tokens)
          |> Enum.max_by(fn {_, v} -> v end, fn -> {:unsure, nil} end)
      end

    {type |> elem(0), need |> elem(0)}
  end

  defp stem(text) when is_binary(text), do: text |> String.split() |> stem()
  defp stem(text) when is_list(text), do: text |> Enum.map(&StoutPorter2.stem/1)
end
