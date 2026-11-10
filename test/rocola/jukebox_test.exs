defmodule Rocola.JukeboxTest do
  use ExUnit.Case, async: false
  alias Rocola.Jukebox
  alias Rocola.Spotify.Fake

  setup do
    Fake.reset()
    :ok
  end

  test "list_devices/0 returns available devices first, keeping is_restricted" do
    assert {:ok, [first, second]} = Jukebox.list_devices()
    assert %{id: "fake-living-room", is_restricted: false} = first
    assert %{id: "fake-locked", is_restricted: true} = second
  end

  test "list_devices/0 sorts restricted last, then by name" do
    :ok =
      Fake.put_devices([
        %{id: "r", name: "A restricted", is_active: false, is_restricted: true},
        %{id: "b", name: "Bedroom", is_active: false, is_restricted: false},
        %{id: "a", name: "Attic", is_active: false, is_restricted: false}
      ])

    assert {:ok, devs} = Jukebox.list_devices()
    assert Enum.map(devs, & &1.id) == ["a", "b", "r"]
  end

  test "select_device/1 transfers playback to an available device" do
    assert :ok = Jukebox.select_device("fake-living-room")
    assert {:ok, devs} = Jukebox.list_devices()
    assert %{is_active: true} = Enum.find(devs, &(&1.id == "fake-living-room"))
  end

  test "select_device/1 refuses a restricted device without sending a command" do
    assert {:error, :restricted_device} = Jukebox.select_device("fake-locked")
    assert Fake.commands() == []
  end

  test "select_device/1 rejects an unknown device without sending a command" do
    assert {:error, :device_not_found} = Jukebox.select_device("nope")
    assert Fake.commands() == []
  end

  test "select_device/1 passes back a devices/0 error and sends no command" do
    :ok = Fake.put_devices({:error, :unavailable})
    assert {:error, :unavailable} = Jukebox.select_device("fake-living-room")
    assert Fake.commands() == []
  end
end
