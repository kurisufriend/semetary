defmodule Semetary.Imageboard do

  @baseurl "https://a.4cdn.org"
  def wget(uri) do
    if GenServer.call(:ratelimiter, :activate) == :goahead do
      Req.get!(uri)
    else
      Process.sleep(1_000)
      wget(uri)
    end
  end
  def boards() do
    wget(@baseurl<>"/boards.json")
  end
  def threads(board) do
    wget(@baseurl<>"/"<>board<>"/threads.json")
  end
  def thread(board, id) do
    wget(@baseurl<>"/"<>board<>"/thread/"<>to_string(id)<>".json")
  end
  def catalog(board) do
    wget(@baseurl<>"/"<>board<>"/catalog.json")
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
