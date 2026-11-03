defmodule Rocola.Spotify.FakeTest do
  use ExUnit.Case, async: false
  alias Rocola.Spotify

  setup do
    Rocola.Spotify.Fake.reset()
    :ok
  end

  test "search finds seeded songs, case-insensitive" do
    assert {:ok, [_ | _] = r} = Spotify.search("aurora")
    assert Enum.all?(r, &(&1.artist == "Aurora"))
  end

  test "has 50 songs and one restricted device" do
    assert {:ok, all} = Spotify.search("")
    assert length(all) == 50
    assert {:ok, devs} = Spotify.devices()
    assert [%{is_restricted: true}] = Enum.filter(devs, & &1.is_restricted)
  end

  test "restricted devices reject playback transfer" do
    assert {:error, :restricted_device} = Spotify.transfer_playback("fake-locked")
  end

  test "queueing needs an active device, then first song plays and the rest queue (add-only)" do
    [a, b] = Enum.take(elem(Spotify.search(""), 1), 2)
    assert {:error, :no_active_device} = Spotify.add_to_queue(a.uri)
    :ok = Spotify.transfer_playback("fake-living-room")
    :ok = Spotify.add_to_queue(a.uri)
    :ok = Spotify.add_to_queue(b.uri)
    assert {:ok, ^a} = Spotify.now_playing()
    assert {:ok, [^b]} = Spotify.queue()
  end
end
