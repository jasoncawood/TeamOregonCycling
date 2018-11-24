defmodule TeamOregonWeb.PageController do
  use TeamOregonWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
