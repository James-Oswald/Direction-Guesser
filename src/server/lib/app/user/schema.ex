defmodule App.User.Schema do
  use Ecto.Schema
  import Ecto.Changeset
 # ---
  @derive {Jason.Encoder, only: [:username, :password, :email, :age, :gender]}
  schema "users" do
    field :username, :string
    field :password, :string
    field :email, :string
    # --- optional demographics ---
    field :age, :integer
    field :gender, :string
  end
 # ---
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email])
    |> validate_required([:username, :password, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint([:username, :email])
  end
end
