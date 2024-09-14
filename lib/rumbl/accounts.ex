defmodule Rumbl.Accounts do
  @moduledoc """
   The Accounts context
  """
  alias Rumbl.Repo
  alias Rumbl.Accounts.User


  def get_user(id) do
    # Enum.find(list_users(), fn map -> map.id == id end)
    Repo.get(User, id)
  end

  def get_user!(id) do
    # Enum.find(list_users(), fn map -> map.id == id end)
    Repo.get!(User, id)
  end
  def get_user_by(params) do
    # Enum.find(list_users(), fn map ->
    #   Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    # end)
    Repo.get_by(User, params)
  end

  def list_users do
   Repo.all(User)
  end
end
