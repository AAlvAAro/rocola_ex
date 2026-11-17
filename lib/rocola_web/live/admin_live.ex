defmodule RocolaWeb.AdminLive do
  @moduledoc "Host page: pick the Spotify Connect device to play on."
  use RocolaWeb, :live_view

  alias Rocola.Jukebox

  @impl true
  def mount(_params, _session, socket), do: {:ok, load_devices(socket)}

  @impl true
  def handle_event("refresh", _params, socket), do: {:noreply, load_devices(socket)}

  def handle_event("select", %{"id" => id}, socket) do
    socket =
      case Jukebox.select_device(id) do
        :ok ->
          name = Enum.find_value(socket.assigns.devices, id, &(&1.id == id && &1.name))

          socket
          |> load_devices()
          |> put_flash(:info, "Playing on #{name}")

        {:error, :restricted_device} ->
          put_flash(socket, :error, "That device can't be controlled")

        {:error, :device_not_found} ->
          put_flash(socket, :error, "Device is gone, refresh")

        {:error, _} ->
          put_flash(socket, :error, "Couldn't switch device. Try again.")
      end

    {:noreply, socket}
  end

  defp load_devices(socket) do
    case Jukebox.list_devices() do
      {:ok, devices} -> assign(socket, devices: devices, error: nil)
      {:error, reason} -> assign(socket, devices: [], error: reason)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-semibold">Devices</h1>
        <.button phx-click="refresh">Refresh</.button>
      </div>

      <p :if={@error} class="text-error mb-4">Couldn't reach Spotify</p>

      <p :if={!@error and @devices == []} class="opacity-70">
        No devices found. Open Spotify on a speaker or phone, then refresh.
      </p>

      <ul class="space-y-2">
        <li
          :for={d <- @devices}
          id={"device-#{d.id}"}
          class={[
            "flex items-center justify-between rounded-box border border-base-300 p-4",
            d.is_restricted && "opacity-50"
          ]}
        >
          <span>{d.name}</span>
          <%= cond do %>
            <% d.is_restricted -> %>
              <div class="flex items-center gap-2">
                <span class="badge">Unavailable</span>
                <button type="button" class="btn btn-sm" disabled>Play here</button>
              </div>
            <% d.is_active -> %>
              <span class="badge badge-success">Playing here</span>
            <% true -> %>
              <.button phx-click="select" phx-value-id={d.id}>Play here</.button>
          <% end %>
        </li>
      </ul>
    </Layouts.app>
    """
  end
end
