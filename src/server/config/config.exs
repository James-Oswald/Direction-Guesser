import Config

config :app,
  port: 42069

config :app,
  ecto_repos: [App.DB]

config :app, App.DB,
  database: "app.db"
