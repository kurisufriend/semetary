defmodule Semetary.Imageboard do

  @baseurl "https://a.4cdn.org"
  def wget(uri, pool \\ :default) do
    if GenServer.call(:ratelimiter, :activate) == :goahead do
      res = try do
        Semetary.Sonky.proxied_get(uri, pool)
      rescue e ->
        IO.puts("yo, shit #{uri} failed w #{e}, retrying")
        wget(uri, pool)
      end

      %HTTPoison.Response{res | body: res.body |> Jason.decode!}
      # Req.get!(uri)
    else
      Process.sleep(1_000)
      wget(uri)
    end
  end
  def boards() do
    wget(@baseurl<>"/boards.json", :noproxy)
  end
  def threads(board) do
    wget(@baseurl<>"/"<>board<>"/threads.json", String.to_atom(board<>"_board_pool"))
  end
  def thread(board, id) do
    wget(@baseurl<>"/"<>board<>"/thread/"<>to_string(id)<>".json", String.to_atom(board<>to_string(id)<>"_pool"))
  end
  def catalog(board) do
    wget(@baseurl<>"/"<>board<>"/catalog.json", :noproxy)
  end
end

defmodule Semetary.Imageboard.Board do
  defstruct board: "", threads: %{}
end

defmodule Semetary.Imageboard.Thread do
  defstruct board: "", no: 0, last_update: 0, on_page: 0, reply_number: 0, postsSet: MapSet.new()
end

defmodule Semetary.Imageboard.Post do
  defstruct post: %{}
end
