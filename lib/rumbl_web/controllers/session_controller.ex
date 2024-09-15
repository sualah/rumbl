defmodule RumblWeb.SessionController do
  use RumblWeb, :controller

  alias Rumbl.Accounts

  def new(conn, _) do
    # Empty map for the session data
    session_params = %{"username" => "", "password" => ""}

    render(conn, :new, session_params: session_params)
  end

  def create(conn, %{
        "session" => %{
          "username" => username,
          "password" => password
        }
      }) do
    case Accounts.authenticate_by_username_and_pass(username, password) do
      {:ok, user} ->
        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "Welcome back, #{user.name}!")
        |> redirect(to: ~p"/users")

      {:error, _reason} ->
        session_params = %{"username" => username}

        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render(:new, session_params: session_params)
    end
  end

  def delete(conn, _) do
    conn
    |> RumblWeb.Auth.logout()
    |> redirect(to: ~p"/")
  end
end
