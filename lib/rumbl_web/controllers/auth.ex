defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  # Duplicated the import from rumbl_web.ex into here to avoid a circular
  # dependency between this module and rumbl_web.
  # This import is needed to use the new ~p syntax for saying routes.
  use Phoenix.VerifiedRoutes,
    endpoint: RumblWeb.Endpoint,
    router: RumblWeb.Router,
    statics: RumblWeb.static_paths()

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Rumbl.Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  @spec authenticate_user(any(), any()) :: any()
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
