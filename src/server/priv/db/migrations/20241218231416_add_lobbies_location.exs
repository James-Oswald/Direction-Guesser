defmodule App.DB.Migrations.AddLobbiesLocation do
  use Ecto.Migration

  def change do
    alter table(:lobbies) do
      add :location, :string, null: true
    end
  end
end
