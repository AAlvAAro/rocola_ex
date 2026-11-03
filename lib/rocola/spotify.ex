defmodule Rocola.Spotify do
  @moduledoc """
  The only way the rest of the app talks to Spotify. Callers use these functions;
  they delegate to the adapter set in `config :rocola, :spotify`
  (`Rocola.Spotify.Fake` by default, `Rocola.Spotify.Web` later).

  A new capability = a new callback here + `Fake` implementation + `Web` stub.
  """

  @type track :: %{
          uri: String.t(),
          name: String.t(),
          artist: String.t(),
          duration_ms: pos_integer()
        }
  @type device :: %{
          id: String.t(),
          name: String.t(),
          is_active: boolean(),
          is_restricted: boolean()
        }

  @callback search(query :: String.t()) :: {:ok, [track]} | {:error, term}
  @callback devices() :: {:ok, [device]} | {:error, term}
  @callback transfer_playback(device_id :: String.t()) :: :ok | {:error, term}
  # Add-only: Spotify's API can append to the queue but never remove or reorder.
  @callback add_to_queue(uri :: String.t()) :: :ok | {:error, term}
  @callback queue() :: {:ok, [track]} | {:error, term}
  @callback now_playing() :: {:ok, track | nil} | {:error, term}

  defp adapter, do: Application.fetch_env!(:rocola, :spotify)

  def search(q), do: adapter().search(q)
  def devices, do: adapter().devices()
  def transfer_playback(id), do: adapter().transfer_playback(id)
  def add_to_queue(uri), do: adapter().add_to_queue(uri)
  def queue, do: adapter().queue()
  def now_playing, do: adapter().now_playing()
end
