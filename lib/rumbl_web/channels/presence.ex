defmodule RumblWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :rumbl,
    pubsub_server: Rumbl.PubSub

  def fetch(_topic, entries) do
    # This function transforms a list of entries that looks like this:
    #
    # %{"user_id" => %{metas: [metadata_from_channel_and_phx_ref}}
    # %{"2" => %{metas: [%{device: "browser", phx_ref: "F21H0lxkXwGlVQMh"}]}}
    #
    # Into this:
    # %{"user_id" => %{username: "username"}}
    # %{"2" => %{username: "chrismccord"}}

    users =
      entries
      |> Map.keys()
      |> Rumbl.Accounts.list_users_by_ids()
      |> Enum.into(
        %{},
        fn user ->
          {to_string(user.id), %{username: user.username}}
        end
      )

    for {key, %{metas: metas}} <- entries, into: %{} do
      {key, %{metas: metas, user: users[key]}}
    end
  end
end
