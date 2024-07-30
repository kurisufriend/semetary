defmodule Semetary.Imageboard do

  @baseurl "https://a.4cdn.org"
  @scrapebase "https://boards.4chan.org/"
  def wget(uri, pool \\ :default) do
    if !pool or GenServer.call(:ratelimiter, {:activate, pool}) == :goahead do

      try do
        Semetary.Sonky.proxied_get!(uri, pool)
      rescue e ->
        IO.puts("yo, shit #{uri} failed w, retrying")
        IO.inspect(e)
        Process.sleep(100)
        wget(uri, pool)
      end


      #if is_binary(res.body) and res.status_code == 200 do
      #  try do
      #    %HTTPoison.Response{res | body: res.body |> Jason.decode!}
      #  rescue e ->
      #    IO.inspect(e)
      #    IO.inspect(res)
      #    raise("shit's fucked! i don't give a good goddamn")
      #  end
      #else
      #  res
      #end
      # Req.get!(uri)
    else
      Process.sleep(100)
      wget(uri)
    end
  end
  def boards() do
    wget(@baseurl<>"/boards.json")
  end
  def threads(board) do
    wget(@baseurl<>"/"<>board<>"/threads.json", String.to_atom(board<>"_board_pool"))
  end
  def archive(board) do
    wget(@baseurl<>"/"<>board<>"/archive.json", String.to_atom(board<>"_board_pool"))
  end
  def thread(board, id) do
    if Application.fetch_env!(:semetary, :use_api) do
      wget(@baseurl<>"/"<>board<>"/thread/"<>to_string(id)<>".json", String.to_atom(board<>"_thread_pool"))
    else
      res = wget(@scrapebase<>"/"<>board<>"/thread/"<>to_string(id), String.to_atom(board<>"_thread_pool"))
      if res.status == 200 do
        html = Floki.parse_document!(res.body)
        res = %{res | body: %{"archived" => (if html |> Floki.find(".closed") |> Floki.text == "Thread archived.\nYou cannot reply anymore.", do: 1, else: "no lol")}}
        %{res | body: Map.put(res.body, "posts", Floki.find(html, ".post") |> Enum.map(fn p ->
          %{
            "no" => p |> Floki.find(".postNum") |> hd |> Floki.find("a") |> List.last |> Floki.text,
            "com" => p |> Floki.find(".postMessage") |> Floki.text
          }
         end))}
      end
    end
  end
  @spec catalog(binary()) :: Req.Response.t()
  def catalog(board) do
    wget(@baseurl<>"/"<>board<>"/catalog.json", String.to_atom(board<>"_board_pool"))
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
