import Config

# Configuración del endpoint (se aplica en compilación y runtime)
config :walkie_talkie, WalkieTalkieWeb.Endpoint,
  force_ssl: [
    rewrite_on: [:x_forwarded_proto],
    exclude: [
      hosts: ["localhost", "127.0.0.1"]
    ]
  ],
  url: [
    host: System.get_env("PHX_HOST", "localhost"),
    port: 443,
    scheme: "https"
  ],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT", "8080"))
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configuración de Swoosh
config :swoosh, api_client: Swoosh.ApiClient.Req
config :swoosh, local: false

# Nivel de logs
config :logger, level: :info
