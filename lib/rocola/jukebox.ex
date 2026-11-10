defmodule Rocola.Jukebox do
  @moduledoc """
  The jukebox context. LiveViews talk to this module, never to `Rocola.Spotify`
  directly. Device rules live here: restricted devices are never sent commands.
  """
  alias Rocola.Spotify

  @doc "Spotify Connect devices, available ones first, then by name."
  @spec list_devices() :: {:ok, [Spotify.device()]} | {:error, term}
  def list_devices do
    with {:ok, devices} <- Spotify.devices() do
      {:ok, Enum.sort_by(devices, &{&1.is_restricted, &1.name})}
    end
  end

  @doc """
  Transfers playback to `id`. Unknown or restricted devices are refused here,
  before any command reaches Spotify.
  """
  @spec select_device(String.t()) :: :ok | {:error, :restricted_device | :device_not_found | term}
  def select_device(id) do
    with {:ok, devices} <- Spotify.devices() do
      case Enum.find(devices, &(&1.id == id)) do
        nil -> {:error, :device_not_found}
        %{is_restricted: true} -> {:error, :restricted_device}
        _ -> Spotify.transfer_playback(id)
      end
    end
  end
end
