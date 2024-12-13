defmodule App.DB.Migrations.CreateLobbies do
  use Ecto.Migration

  def change do
    create table(:lobbies) do
      add :target_guess_range,  :integer, default: 20
      add :time_per_round,      :integer, default: 15
      add :number_of_rounds,    :integer, default: 1

      add :users,       :map,           default: %{}
      add :round_data,  {:array, :map}, default: []
    end
  end
end
