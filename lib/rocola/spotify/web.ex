defmodule Rocola.Spotify.Web do
  @moduledoc "Real Spotify Web API adapter (Req + TokenServer). Stub until real playback is wanted."
  @behaviour Rocola.Spotify

  @impl true
  def search(_), do: {:error, :not_implemented}
  @impl true
  def devices, do: {:error, :not_implemented}
  @impl true
  def transfer_playback(_), do: {:error, :not_implemented}
  @impl true
  def add_to_queue(_), do: {:error, :not_implemented}
  @impl true
  def queue, do: {:error, :not_implemented}
  @impl true
  def now_playing, do: {:error, :not_implemented}
end
