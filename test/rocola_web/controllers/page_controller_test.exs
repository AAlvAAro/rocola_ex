defmodule RocolaWeb.PageControllerTest do
  use RocolaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "The jukebox for your"
  end
end
