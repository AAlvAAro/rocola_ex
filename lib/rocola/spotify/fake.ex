defmodule Rocola.Spotify.Fake do
  @moduledoc """
  In-memory Spotify for dev and test: ~50 seeded songs, 2 devices (one `is_restricted`),
  and simulated playback. Mirrors real API limits: add-only queue, restricted devices
  reject commands, playback needs an active device. No network, no token.
  """
  use Agent
  @behaviour Rocola.Spotify

  @artists ~w(Aurora Lumen Nova Tidal Ember Vesper Quartz Harbor Willow Cobalt)
  @words ~w(Midnight Echo Golden Static Paper)

  @tracks (for {a, i} <- Enum.with_index(@artists), {w, j} <- Enum.with_index(@words) do
             %{
               uri: "fake:track:#{i}-#{j}",
               name: "#{w} #{a}",
               artist: a,
               duration_ms: 150_000 + i * 7_000 + j * 3_000
             }
           end)

  @devices [
    %{
      id: "fake-living-room",
      name: "Living Room (Fake Sonos)",
      is_active: false,
      is_restricted: false
    },
    %{
      id: "fake-locked",
      name: "Locked Speaker (restricted)",
      is_active: false,
      is_restricted: true
    }
  ]

  def start_link(_), do: Agent.start_link(&seed/0, name: __MODULE__)

  @doc "Back to the seeded state (for tests)."
  def reset, do: Agent.update(__MODULE__, fn _ -> seed() end)

  @doc "Test/dev seam: replace the device list, or make `devices/0` return an error."
  @spec put_devices([Rocola.Spotify.device()] | {:error, term}) :: :ok
  def put_devices({:error, reason}),
    do: Agent.update(__MODULE__, &%{&1 | devices: [], devices_error: reason})

  def put_devices(devices) when is_list(devices),
    do: Agent.update(__MODULE__, &%{&1 | devices: devices, devices_error: nil})

  @doc "Test/dev seam: every `transfer_playback/1` received, in order, rejected ones included."
  @spec commands() :: [{:transfer_playback, String.t()}]
  def commands, do: Agent.get(__MODULE__, &Enum.reverse(&1.commands))

  defp seed, do: %{devices: @devices, devices_error: nil, commands: [], queue: [], now: nil}

  @impl true
  def search(q) do
    q = String.downcase(q)

    {:ok,
     Enum.filter(@tracks, &String.contains?(String.downcase(&1.name <> " " <> &1.artist), q))}
  end

  @impl true
  def devices do
    case Agent.get(__MODULE__, & &1) do
      %{devices_error: nil, devices: devices} -> {:ok, devices}
      %{devices_error: reason} -> {:error, reason}
    end
  end

  @impl true
  def transfer_playback(id) do
    Agent.get_and_update(__MODULE__, fn s ->
      s = %{s | commands: [{:transfer_playback, id} | s.commands]}

      case Enum.find(s.devices, &(&1.id == id)) do
        nil -> {{:error, :device_not_found}, s}
        %{is_restricted: true} -> {{:error, :restricted_device}, s}
        _ -> {:ok, %{s | devices: Enum.map(s.devices, &%{&1 | is_active: &1.id == id})}}
      end
    end)
  end

  @impl true
  def add_to_queue(uri) do
    Agent.get_and_update(__MODULE__, fn s ->
      cond do
        not Enum.any?(s.devices, & &1.is_active) ->
          {{:error, :no_active_device}, s}

        track = Enum.find(@tracks, &(&1.uri == uri)) ->
          {:ok, advance(%{s | queue: s.queue ++ [track]})}

        true ->
          {{:error, :track_not_found}, s}
      end
    end)
  end

  @impl true
  def queue, do: {:ok, Agent.get(__MODULE__, & &1.queue)}

  @impl true
  def now_playing, do: {:ok, Agent.get(__MODULE__, & &1.now)}

  # ponytail: no timer; the first queued song starts playing immediately. Add a
  # Process.send_after tick that pops the queue when real-time playback sim is needed.
  defp advance(%{now: nil, queue: [t | rest]} = s), do: %{s | now: t, queue: rest}
  defp advance(s), do: s
end
