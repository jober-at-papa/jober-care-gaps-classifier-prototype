defmodule Thing do
  defstruct types: Bayesic.Trainer.new(), needs: %{}

  @finalize_opts [pruning_threshold: 0.33]

  def new() do
    %__MODULE__{}
  end

  def train(thing, type, need, tokens) do
    %__MODULE__{
      types:
        thing.types
        |> Bayesic.train(tokens, type),
      needs:
        thing.needs
        |> Map.put(
          type,
          Map.get(thing.needs, type, Bayesic.Trainer.new()) |> Bayesic.train(tokens, need)
        )
    }
  end

  def finalize(thing) do
    %__MODULE__{
      types:
        thing.types
        |> Bayesic.finalize(@finalize_opts),
      needs:
        thing.needs
        |> Enum.map(fn {type, trainer} -> {type, trainer |> Bayesic.finalize(@finalize_opts)} end)
        |> Map.new()
    }
  end

  def classify(thing, tokens) do
    type =
      thing.types
      |> Bayesic.classify(tokens)
      |> Enum.max_by(fn {_, v} -> v end, fn -> {:no_idea, nil} end)
      |> elem(0)

    need =
      cond do
        type == :no_idea ->
          :no_idea

        type == nil ->
          :no_idea

        true ->
          thing.needs[type]
          |> Bayesic.classify(tokens)
          |> Enum.max_by(fn {_, v} -> v end, fn -> {:no_idea, nil} end)
          |> elem(0)
      end

    {type, need}
  end
end

defmodule CareGapClassifier do
  def from_csv(csv_file) do
    File.stream!(csv_file)
    |> CSV.decode()
    |> Enum.reduce(Thing.new(), fn {:ok, [_fp, type, need, text]}, thing ->
      tokens = text |> String.split() |> stem()
      thing |> Thing.train(type, need, tokens)
    end)
    |> Thing.finalize()
  end

  def classify(classifier, text) do
    classifier |> Thing.classify(text |> String.split() |> stem())
  end

  def stem(text) do
    text
    |> Enum.map(&StoutPorter2.stem/1)
  end
end
