defmodule App.Process do
  require Logger
 # ---
  import :math, only: [sin: 1, cos: 1, atan2: 2, sqrt: 1, pow: 2, pi: 0]

  defp calculate_bearing(lat1, lon1, lat2, lon2) do
    lat1_rad = deg_to_rad(lat1)
    lat2_rad = deg_to_rad(lat2)
    delta_lon = deg_to_rad(lon2 - lon1)

    y = sin(delta_lon) * cos(lat2_rad)
    x = cos(lat1_rad) * sin(lat2_rad) - sin(lat1_rad) * cos(lat2_rad) * cos(delta_lon)
    atan2(y, x) |> rad_to_deg() |> normalize_bearing()
  end

  defp deg_to_rad(deg), do: deg * (pi() / 180)
  defp rad_to_deg(rad), do: rad * (180 / pi())
  defp normalize_bearing(bearing) when bearing < 0, do: bearing + 360
  defp normalize_bearing(bearing), do: bearing
 # ---
  defp calculate_score(user_bearing, user_lat, user_lon, target_lat, target_lon) do
    correct_bearing = calculate_bearing(user_lat, user_lon, target_lat, target_lon)
    diff = abs(user_bearing - correct_bearing)
    accuracy = max(0, 100 - (diff / 180) * 100)
    round(accuracy)
  end
 # ---
  defp calculate_nearby(user_lat, user_lon, range) do
    query =
      """
      SELECT DISTINCT ?placeLabel ?location WHERE {
        SERVICE wikibase:around {
           ?place wdt:P625 ?location .
           bd:serviceParam wikibase:center "Point(#{user_lat},#{user_lon})"^^geo:wktLiteral   .
           bd:serviceParam wikibase:radius "#{range}" .
           bd:serviceParam wikibase:distance ?distance .
        } .

         SERVICE wikibase:label {
            bd:serviceParam wikibase:language "en" .
         }
      }

      ORDER BY RAND() LIMIT 100
      """
    url =
      "https://query.wikidata.org/sparql?query=" <> URI.encode(query)

    case HTTPoison.get(url, [{"Accept", "application/sparql-results+json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, json} = Jason.decode(body)
        json
        |> Map.get("results")
        |> Map.get("bindings")
        |> Enum.map(fn (binding) ->
           [ name:  binding |> Map.get("placeLabel") |> Map.get("value"),
             coord: binding |> Map.get("location")   |> Map.get("value") |> parse_point ] end)
        |> Enum.random
    end
  end

  defp parse_point("Point(" <> coords) do
    # Use a regex to capture the two numbers inside the parentheses
    ~r/(-?\d+\.\d+)\s+(-?\d+\.\d+)/
    |> Regex.run(coords)                    # Match the regex against the coordinates part
    |> case do
         [_, lat, lon] ->
           {String.to_float(lat), String.to_float(lon)}  # Convert the matched strings to floats
         _ ->
       end
  end
 # ---
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info("(process): started #{inspect(state)}")
    {:ok, state}
  end

  @impl true
  def handle_call({:calculate_score, %{user_bearing: user_bearing, user_lat: user_lat, user_lon: user_lon, target_lat: target_lat, target_lon: target_lon}}, _from, state) do
    {:reply, calculate_score(user_bearing, user_lat, user_lon, target_lat, target_lon), state}
  end

  @impl true
  def handle_call({:calculate_nearby, %{user_lat: user_lat, user_lon: user_lon, range: range}}, _from, state) do
    {:reply, calculate_nearby(user_lat, user_lon, range), state}
  end
 # ---
end
