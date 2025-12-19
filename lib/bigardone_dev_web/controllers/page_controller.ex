defmodule BigardoneDevWeb.PageController do
  use BigardoneDevWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
