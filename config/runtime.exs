import Config

if System.get_env("PHX_SERVER") do
  config :walkie_talkie, WalkieTalkieWeb.Endpoint, server: true
end

# El puerto se define en prod.exs, pero si quieres sobrescribirlo en runtime, puedes dejarlo
# (aunque no es necesario ahora)
# config :walkie_talkie, WalkieTalkieWeb.Endpoint,
#   http: [port: String.to_integer(System.get_env("PORT", "8080"))]

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :walkie_talkie, WalkieTalkie.Repo,
    url: database_url,
    ssl: true,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # La secret_key_base se lee en prod.exs, pero podemos mantener la variable de entorno
  # No es necesario definirla aquí porque ya está en prod.exs

  host = System.get_env("PHX_HOST") || "example.com"

  config :walkie_talkie, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  # Endpoint config ya está en prod.exs, solo añadimos lo que no esté allí (por ejemplo, dns_cluster)
end
