import Config

# Solo configuración de base de datos y otras que dependan de variables de entorno
if config_env() == :prod do
secret_key_base = System.get_env("SECRET_KEY_BASE") || raise "missing SECRET_KEY_BASE"
IO.puts("🔑 SECRET_KEY_BASE en producción: #{String.slice(secret_key_base, 0, 10)}...")
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

  # Elimina la definición de host y la configuración del endpoint (ya está en prod.exs)
end
