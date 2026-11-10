defmodule RocolaWeb.AdminLiveTest do
  use RocolaWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  alias Rocola.Spotify.Fake

  setup do
    Fake.reset()
    :ok
  end

  test "lists both devices", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/admin")
    assert html =~ "Living Room (Fake Sonos)"
    assert html =~ "Locked Speaker (restricted)"
  end

  test "restricted device is unavailable with a disabled, inert button", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin")
    assert view |> element("#device-fake-locked") |> render() =~ "Unavailable"
    assert has_element?(view, "#device-fake-locked button[disabled]")
    refute has_element?(view, "#device-fake-locked [phx-click]")
  end

  test "Play here makes the device active and flashes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin")
    html = view |> element("#device-fake-living-room button", "Play here") |> render_click()
    assert html =~ "Playing on Living Room (Fake Sonos)"
    assert view |> element("#device-fake-living-room") |> render() =~ "Playing here"
    refute has_element?(view, "#device-fake-living-room button", "Play here")
  end

  test "a forged select for a restricted device is refused", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin")
    html = render_click(view, "select", %{"id" => "fake-locked"})
    assert html =~ "That device can&#39;t be controlled"
    assert Fake.commands() == []
  end

  test "Refresh shows newly appeared devices", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/admin")
    refute html =~ "Kitchen"

    {:ok, devs} = Fake.devices()

    :ok =
      Fake.put_devices(
        devs ++ [%{id: "k", name: "Kitchen", is_active: false, is_restricted: false}]
      )

    html = view |> element("button", "Refresh") |> render_click()
    assert html =~ "Kitchen"
  end

  test "shows an error when Spotify is unreachable", %{conn: conn} do
    :ok = Fake.put_devices({:error, :unavailable})
    {:ok, _view, html} = live(conn, ~p"/admin")
    assert html =~ "Couldn&#39;t reach Spotify"
  end

  test "shows a hint when there are no devices", %{conn: conn} do
    :ok = Fake.put_devices([])
    {:ok, _view, html} = live(conn, ~p"/admin")
    assert html =~ "No devices found. Open Spotify on a speaker or phone, then refresh."
  end
end
