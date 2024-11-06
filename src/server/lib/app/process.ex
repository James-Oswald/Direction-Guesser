defmodule App.Process do
  use GenServer

  #just the basic query james posted in discord
  @wikidata_query """
  SELECT ?cityLabel ?population ?countryLabel ?gps_cords
  WITH {
    SELECT DISTINCT *
    WHERE {
      ?city wdt:P31/wdt:P279* wd:Q515.
      ?city wdt:P1082 ?population.
      ?city wdt:P625 ?gps_cords.
      ?city wdt:P17 ?country
    }
    ORDER BY DESC(?population)
    LIMIT 300
  } AS %i
  WHERE {
    INCLUDE %i
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en" . }
  }
  ORDER BY DESC(?population)
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call([:random_city], _from, state) do
    url = "https://query.wikidata.org/sparql?query=" <> URI.encode(@wikidata_query)

    IO.inspect(url)

    case HTTPoison.get(url, [{"Accept", "application/sparql-results+json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parsed_data} = Jason.decode(body)
        IO.inspect(parsed_data, label: "WikiData Response")
        entry = Enum.random(parsed_data["results"]["bindings"])
        {:reply, {:ok, entry["cityLabel"]["value"] <> ", " <>  entry["countryLabel"]["value"]}, state}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Failed to fetch data: #{reason}")
        {:reply, {:error}, state}
    end
  end
end
