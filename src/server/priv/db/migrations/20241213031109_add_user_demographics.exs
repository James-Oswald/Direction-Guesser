defmodule App.DB.Migrations.AddUserDemographics do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :age, :integer, null: true
      add :gender, :string, null: true
    end
  end
end
