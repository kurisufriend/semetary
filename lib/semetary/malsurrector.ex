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
