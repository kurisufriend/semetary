defmodule Semetary.Malsurrector do

  @endpoints %{
    "rentry" => %{
      "urls" => ["rentry.co", "rentry.org"],
      "handler" => &Semetary.Malsurrector.handle_rentry/1
    },
    "litter.catbox.moe" => %{
      "urls" => ["litter.catbox.moe"],
      "handler" => &Semetary.Malsurrector.handle_litter/1
    },
    "vocaroo.com" => %{
      "urls" => ["vocaroo.com"],
      "handler" => &Semetary.Malsurrector.handle_vocaroo/1
    },
    "pastebin.com" => %{
      "urls" => ["pastebin.com"],
      "handler" => &Semetary.Malsurrector.handle_pastebin/1
    }
  }

  def init() do
    path = "./data"
    unless File.exists?(path) do
      File.mkdir!(path)
    end
    @endpoints |> Map.keys |> Enum.each(fn endpoint ->
      unless File.exists?(path<>"/"<>endpoint) do
        File.mkdir!(path<>"/"<>endpoint)
      end
    end)
  end

  def post_processing(post) do
    if post["com"] do
      body = post["com"] |> String.replace("<wbr>", "")
      url_capture = @endpoints |> Map.keys |> Enum.map(fn key -> @endpoints[key]["urls"] end)
        |> List.flatten |> Enum.join("|")
      instances = (Regex.compile!("(|https:\/\/|http:\/\/)(#{url_capture})\/[^ \n<>]*")
       |> Regex.scan(body))
      if instances != [] do
        instances
        |> Enum.each(fn i ->
          link = hd(i)
          @endpoints |> Map.keys |> Enum.each(fn key ->
            if link |> String.contains?(key) do
              @endpoints[key]["handler"].(link)
            end
          end)
          # IO.puts(link)
          # IO.puts(body)
        end)
      end
    end
  end
  def handle_pastebin(link) do
    id = link |> String.split("/", trim: true) |> List.last
    IO.puts("pastebin")
    IO.puts(id)
  end

  def handle_vocaroo(link) do
    id = link |> String.split("/", trim: true) |> List.last
    heads = %{
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
      "Accept-Encoding" => "gzip, deflate, br",
      "Accept-Language" => "en-US,en;q=0.5",
      "Connection" => "keep-alive",
      "Host" => "media1.vocaroo.com",
      "Referer" => "https://vocaroo.com/",
      "Sec-Fetch-Dest" => "document",
      "Sec-Fetch-Mode" => "navigate",
      "Sec-Fetch-Site" => "same-site",
      "Sec-Fetch-User" => "?1",
      "Upgrade-Insecure-Requests" => "1",
      "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:122.0) Gecko/20100101 Firefox/122.0"
    }
    voccy = Req.get!("https://media1.vocaroo.com/mp3/"<>id, headers: heads)
    if voccy.status == 200 do
      File.write!("./data/vocaroo.com/"<>id<>".mp3", voccy.body)
    end
    IO.puts("vocaroo")
    IO.puts(id)
  end

  def handle_rentry(link) do
    id = link |> String.split("/", trim: true) |> List.last
    IO.puts("rentry")
    IO.puts(id)
  end

  def handle_litter(link) do
    id = link |> String.split("/", trim: true) |> List.last
    IO.puts("litter")
    IO.puts(id)
  end


end
