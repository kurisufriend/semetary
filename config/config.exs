import Config

config :floki, :html_parser, Floki.HTMLParser.Html5ever

# the 4chan API has a reccomended rate limit of one second per GET request.
# the preloaded config values here do not use any proxies, and fully obey that ordinance,
#  meaning that, for all 78 boards, assuming 150 threads per board, it will take you a little over
#  195 MINUTES to GET every thread for the first time, by which time the human race will probably be extinct.
# to mitigate this, you can either add HTTP proxies in ./resources/proxies.txt, then enable them in this
#  config, you can simply scrape fewer boards, or you can increase the rates by an amount that makes scraping
#  from a single IP address reasonable.

config :semetary,
  # what boards to scrape for media links
  boards: ["3","a","aco","adv","an","b","bant","biz","c","cgl","ck","cm","co","d","diy","e","f","fa","fit","g","gd","gif","h","hc","his","hm","hr","i","ic","int","jp","k","lgbt","lit","m","mlp","mu","n","news","o","out","p","po","pol","pw","qa","qst","r","r9k","s","s4s","sci","soc","sp","t","tg","toy","trash","trv","tv","u","v","vg","vip","vm","vmg","vp","vr","vrpg","vst","vt","w","wg","wsg","wsr","x","xs","y"],

  # each board and external media endpoint can be ratelimited by its own "pool". this determines
  #  how often that pool can make requests.
  # note that it is safe to lower this value below 1_000 if you're chugging with a reasonable number of
  #  proxies.
  # it is now safe to use 300 if you have use_api set to `false' ;^)
  per_pool_rate: 300,

  # this determines the base floor on your machine making requests /in general/.
  global_rate: 10,

  # this determines how often the boards are updated to check for new/dead threads.
  board_refresh_rate: 5 * 60 * 1_000,

  # this determines how often threads check themselves for death/archival.
  fourohfour_check_rate: 5 * 60 * 1_000,

  # this determines where all the scraped media goes! make sure you have the correct perms ;^)
  data_path: "./data",

  # the atom provided identifies both the rate limiting pool and the use of proxies.
  # "soundgasm" => :soundgasm gives external requests to sg it's own pool, and tells it
  # to use the given proxies. if you were to replace :soundgasm with :noproxy, it would share a rate
  # with other :noproxy (i.e. raw) requests and not use any HTTP proxy.
  # if you wanted to proxy litter requests, you would replace "litter" => :noproxy with
  # "litter" => :whatever_you_want.
  data_proxy_map: %{
    #"soundgasm" => :soundgasm, # <-- e.g.
    "soundgasm" => :noproxy,
    "rentry"    => :noproxy,
    "litter"    => :noproxy,
    "vocaroo"   => :noproxy
  },

  # use the proxies provided in ./resources/proxies.txt
  # if this is off, no requests will be routed through a proxy.
  use_proxies: false,

  # use the 4chan API instead of page-scraping. applies (for now) only to the thread endpoint.
  use_api: false
