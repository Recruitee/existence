# Existence

Asynchronous dependency health checks library.

## Features
* User defined dependencies checks with flexible settings.
* Checks are executed asynchronously as isolated processes.
* Built in `Plug` module providing customizable response for a http health-check endpoint.
* Practically unlimited scalability due to ETS table use as an API "interface".

## Installation
Add library to application dependencies:
```elixir
def deps do
  [
    {:existence, github: "recruitee/existence", branch: "master"}
  ]
end
```

## Usage
Add library child to your application supervisor:
```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [Existence]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Configure checks in your application configuration file, for example:
```elixir
#config/config.exs
config :my_app, Existence,
  check_1: %{
    mfa: {MyApp.Checks, :check_1, []}
  },
  check_2: %{
    mfa: {MyApp.Checks, :check_2, []}
  }
```

Get current health-check state:
```elixir
iex> Existence.get_state()
:ok
```

List dependencies checks with their current states:
```elixir
iex> Existence.get_checks()
[check_1: :ok, check_2: :ok]
```

Configure your Phoenix router to respond to the `/healthcheck` endpoint requests using for example
`Plug.Router.forward/2`:
```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  forward("/healthcheck", Existence.Plug)
end
```

## TODO
- [ ] add `telemetry` event emitted on a health-check state change.

