defmodule RumblWeb.UserHTML do
  use RumblWeb, :html

  alias Rumbl.Accounts

  embed_templates "user_html/*"

  def first_name(%Accounts.User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end

end
