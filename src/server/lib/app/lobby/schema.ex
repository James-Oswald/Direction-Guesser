defmodule App.Lobby.Schema do
  use Ecto.Schema
 # ---
  schema "lobbies" do
    field :target_guess_range,  :integer, default: 20
    field :time_per_round,      :integer, default: 15
    field :number_of_rounds,    :integer, default: 1

    field :users,       :map,           default: %{}
    field :round_data,  {:array, :map}, default: []
  end
 # ---
end
