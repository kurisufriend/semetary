defmodule Semetary.Sonky.State do
  defstruct pool: [], index: 0, length: 0
end
defmodule Semetary.Sonky.Pool do
  use GenServer
  def start_link(pool_state) do
    GenServer.start_link(__MODULE__, pool_state, name: :proxy_pool)
  end

  @impl true
  def init(pool_state) do
    poolst = (File.read!("./resources/proxies.txt")
     |> String.replace("\r", "")
     |> String.split("\n", trim: true))
    pool_state = %Semetary.Sonky.State{
      pool: poolst |> Enum.map(fn line -> String.split(line, ":") end),
      index: 0,
      length: poolst |> length
    }
    {:ok, pool_state}
  end

  @impl true
  def handle_call(:get, _, pool_state) do
    pool_state = %Semetary.Sonky.State{pool_state | index: pool_state.index + 1}
    {
      :reply,
      pool_state.pool |> Enum.at(pool_state.index |> rem(pool_state.length)),
      pool_state
    }
  end
end
defmodule Semetary.Sonky do

  def proxied_get!(uri, pool \\ :default, opts \\ []) do
    proxy = GenServer.call(:proxy_pool, :get)
    if pool != :noproxy and Application.fetch_env!(:semetary, :use_proxies) do
      #HTTPoison.get!(uri, [], [
      #  proxy: {:socks5, Enum.at(proxy, 1)|>to_charlist, Enum.at(proxy, 2)|>String.to_integer},
      #  socks5_user: Enum.at(proxy, 3), socks5_pass: Enum.at(proxy, 4),
      #  hackney: [pool: pool]
      #])
      auth = Enum.at(proxy, 3)<>":"<>Enum.at(proxy, 4) |> Base.encode64
      Req.get!(uri, [
        connect_options: [
          proxy: {:http, Enum.at(proxy, 1), Enum.at(proxy, 2)|>String.to_integer, []},
          proxy_headers: [{"Proxy-Authorization", "Basic #{auth}"}]
        ]
      ] ++ opts
      )
    else
      #HTTPoison.get!(uri, [], [
      #  hackney: [pool: pool]
      #])
      Req.get!(uri, opts)
    end
  end

end
