defmodule Fw do
  use Application

  @interface :eth0
  # @opts [mode: "static", ip: "10.0.10.3", mask: "16", subnet: "255.255.0.0"]
  @opts [mode: "dhcp"]

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Phoenix.PubSub.PG2, [Nerves.PubSub, [poolsize: 1]]),
      worker(Task, [fn -> start_network end], restart: :transient)
    ]

    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_network do
    Nerves.Networking.setup @interface, @opts
    opts = Application.get_env(:fw, :wlan0)
    Nerves.InterimWiFi.setup "wlan0", opts
  end

end
