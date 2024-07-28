defmodule Semetary.Malsurrector do

  @endpoints %{
    "rentry" => %{
      "urls" => ["rentry.co", "rentry.org"],
      "handler" => &Semetary.Malsurrector.handle_rentry/2
    },
    "litter.catbox.moe" => %{
      "urls" => ["litter.catbox.moe"],
      "handler" => &Semetary.Malsurrector.handle_litter/2
    },
    "vocaroo" => %{
      "urls" => ["vocaroo.com", "voca.ro"],
      "handler" => &Semetary.Malsurrector.handle_vocaroo/2
    },
#    "pastebin.com" => %{
#      "urls" => ["pastebin.com"],
#      "handler" => &Semetary.Malsurrector.handle_pastebin/2
#    },
    "soundgasm.net" => %{
      "urls" => ["soundgasm.net"],
      "handler" => &Semetary.Malsurrector.handle_soundgasm/2
    }
  }


  def init() do
    path = Application.fetch_env!(:semetary, :data_path)
    mkdir_if_needed!(path)
    @endpoints |> Map.keys |> Enum.each(fn endpoint ->
      mkdir_if_needed!(path<>"/"<>endpoint)
    end)
  end

  def post_processing(post) do
    if post["com"] do
      body = post["com"] |> String.replace("<wbr>", "")
      url_capture = @endpoints |> Map.keys |> Enum.map(fn key -> @endpoints[key]["urls"] end)
        |> List.flatten |> Enum.join("|")
      instances = (Regex.compile!("(|https:\/\/|http:\/\/)(#{url_capture})\/[^ \n<>\\(\\)]*")
       |> Regex.scan(body))
      if instances != [] do
        instances
        |> Enum.each(fn i ->
          bare_link = hd(i)
          link = Enum.join([(if String.starts_with?(bare_link, "http"), do: "", else: "https://"), bare_link])
          @endpoints |> Map.keys |> Enum.each(fn key ->
            if link |> String.contains?(@endpoints[key]["urls"]) do
              @endpoints[key]["handler"].(link, post)
            end
          end)
          # IO.puts(link)
          # IO.puts(body)
        end)
      end
    end
  end
  def handle_pastebin(link, post) do
    id = link |> String.split("/", trim: true) |> List.last
    # IO.puts("pastebin")
    # IO.puts(id)
  end

  def handle_vocaroo(link, post) do
    id = link |> String.split("/", trim: true) |> List.last
    path = Application.fetch_env!(:semetary, :data_path)<>"/vocaroo/"
    unless File.exists?(path<>id<>".mp3") do
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
      voccy = Semetary.Rate.rated_get!("https://media1.vocaroo.com/mp3/"<>id, Application.fetch_env!(:semetary, :data_proxy_map)["vocaroo"], headers: heads)
      if voccy.status == 200 do
        write_if_new!(path<>id<>".mp3", voccy.body)
        write_if_new!(path<>id<>".mp3.meta", Jason.encode!(post))
      else
        raise "o shit vocaroo not 200 #{link}"
      end
    end
  end

  def handle_rentry(link, post) do
    id = link |> String.split("/", trim: true) |> List.last
      |> String.split("#", trim: true) |> hd
    newlink = link |> String.split("#", trim: true) |> hd
    rent = Semetary.Rate.rated_get!(newlink<>"/raw", Application.fetch_env!(:semetary, :data_proxy_map)["rentry"])
    if rent.status == 200 do
      prospect = Application.fetch_env!(:semetary, :data_path)<>"/rentry/"<>id<>".txt"
      if File.exists?(prospect<>".latest") do
        if File.read!(prospect<>".latest") != rent.body do
          File.write!(prospect<>".#{System.os_time}", rent.body)
          File.write!(prospect<>".latest", rent.body)
          File.write!(prospect<>".meta"<>".#{System.os_time}", Jason.encode!(post))
        else
          # if it exists and is not diff, don't do anything (comment to make flow clear) (gay) (penis)
        end
      else
        File.write!(prospect<>".#{System.os_time}", rent.body)
        File.write!(prospect<>".latest", rent.body)
        File.write!(prospect<>".meta"<>".#{System.os_time}", Jason.encode!(post))
      end
    end
  end

  def handle_litter(link, post) do
    id = link |> String.split("/", trim: true) |> List.last
    path = Application.fetch_env!(:semetary, :data_path)<>"/litter.catbox.moe/"
    unless File.exists?(path<>id) do
      litter = Semetary.Rate.rated_get!(link, Application.fetch_env!(:semetary, :data_proxy_map)["litter"], raw: true)
      if litter.status == 200 do
        write_if_new!(path<>id, litter.body)
        write_if_new!(path<>id<>".meta", Jason.encode!(post))
      else
        raise "OH MY GOD THEY KILLED LITTERBOX #{link}"
      end
    end
  end

  def handle_soundgasm(link, post) do
    [user, id] = link |> String.split("/", trim: true) |> Enum.take(-2)
    path = Application.fetch_env!(:semetary, :data_path)<>"/soundgasm.net/"
    unless user == "u" or File.exists?(path<>user<>"/"<>id<>".m4a") do
      page = Semetary.Rate.rated_get!(link, Application.fetch_env!(:semetary, :data_proxy_map)["soundgasm"])
      if page.status == 200 do
        IO.puts(link)
        gasm = (Regex.run(~r/(|https:\/\/|http:\/\/)(media.soundgasm.net)\/[^ \n<>\"\\\)\()]*.m4a/, page.body)
        |> hd
        |> Semetary.Rate.rated_get!(Application.fetch_env!(:semetary, :data_proxy_map)["soundgasm"]))
        if gasm.status == 200 do
          mkdir_if_needed!(path<>user)
          write_if_new!(path<>user<>"/"<>id<>".m4a", gasm.body)
          write_if_new!(path<>user<>"/"<>id<>".m4a.meta", Jason.encode!(post))
        else
          raise "failed to gasm the sound"
        end
      else
        raise "failed to sound the gasm #{link}"
      end
    end
  end

  defp write_if_new!(path, content, update \\ false) do
    unless File.exists?(path) do
      File.write!(path, content)
      IO.puts(["wrote" , path])
    end
  end

  defp mkdir_if_needed!(path) do
    unless File.exists?(path) do
      File.mkdir!(path)
    end
  end

end
