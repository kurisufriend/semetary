defmodule Semetary.Malsurrector do
  def post_processing(post) do
    if post["com"] do
      body = post["com"] |> String.replace("<wbr>", "")
      instances = Regex.scan(~r/(|https:\/\/|http:\/\/)(rentry.co|rentry.org|litter.catbox.moe|vocaroo.com|pastebin.com)\/[^ \n<>]*/, body)
      if instances != [] do
        instances
        |> Enum.each(fn i ->
          cond do
            i |> String.contains("rentry") ->
              _
            i |> String.contains("litter.catbox.moe") ->
              _
            i |> String.contains("vocaroo.com") ->
              _
            i |> String.contains("pastebin.com") ->
              _
          end
          link = hd(i)
          IO.puts(link)
          # IO.puts(body)
        end)
      end
    end
  end
  def handle_pastebin(link) do
    _
  end

  def handle_vocaroo(link) do
    _
  end

  def handle_rentry(link) do
    _
  end

  def handle_litter(link) do
    _
  end

end
