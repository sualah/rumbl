defmodule Rumbl.Accounts.User do
  # defstruct [:id, :name, :username]
  use Ecto.Schema
  # import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :username, :string

    timestamps()
  end

end
