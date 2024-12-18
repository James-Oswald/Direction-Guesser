defmodule App.Lobby.Schema do
  use Ecto.Schema
 # ---
  @derive {Jason.Encoder, only: [:target_guess_range, :time_per_round, :number_of_rounds, :users, :round_data]}
  schema "lobbies" do
    field :target_guess_range,  :integer, default: 20
    field :time_per_round,      :integer, default: 15
    field :number_of_rounds,    :integer, default: 1
    field :location,            :string

    field :users,       :map,           default: %{}
    field :round_data,  {:array, :map}, default: []
  end
 # ---
end
