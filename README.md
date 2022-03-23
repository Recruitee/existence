# Existence

[![Hex Version](https://img.shields.io/hexpm/v/existence)](https://hex.pm/packages/existence)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen)](https://hexdocs.pm/existence)

Asynchronous dependency health checks library.

## Features
* User defined dependencies checks with flexible settings.
* Dependencies checks functions are executed asynchronously.
* Built-in `Plug` module providing customizable response for a http health-check endpoint.
* Support for multiple independent `Existence` instances and associated health-checks
  endpoints (example use case: separate Kubernetes readiness and liveness http probes).
* Checks states are stored and accessed using a dedicated ETS tables per `Existence` instance,
  which means practically unlimited requests per second processing capacity.

## Installation
Add `Existence` library to your application dependencies:
```elixir
def deps do
  [
    {:existence, "~> 0.1.1"}
  ]
end
```

## Usage
Define dependencies checks functions MFA's and start `Existence` child with your application
supervisor
```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    health_checks = [
      check_1: %{mfa: {MyApp.Checks, :check_1, []}},
      check_2: %{mfa: {MyApp.Checks, :check_2, []}}
    ]

    children = [{Existence, checks: health_checks}]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Declare your dependencies checks functions:
```elixir
defmodule MyApp.Checks do
  def check_1(), do: :ok
  def check_2(), do: :ok
end
```

Configure your Phoenix router to respond to the `/healthcheck` endpoint requests using for example
`Plug.Router.forward/2`:
```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  forward("/healthcheck", Existence.Plug)
end
```

Get current overall health-check state:
```elixir
iex> Existence.get_state()
:ok
```

List individual dependencies checks current states:
```elixir
iex> Existence.get_checks()
[check_1: :ok, check_2: :ok]
```

## TODO
- [ ] add `telemetry` event emitted on an overall health-check state change.

