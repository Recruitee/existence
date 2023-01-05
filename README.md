# Existence

[![Hex Version](https://img.shields.io/hexpm/v/existence)](https://hex.pm/packages/existence)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen)](https://hexdocs.pm/existence)
[![CI](https://github.com/Recruitee/existence/workflows/CI/badge.svg)](https://github.com/Recruitee/existence/actions/workflows/ci.yml)

Asynchronous dependency health checks library.

## Features
* User defined dependencies health-checks with flexible settings, including configurable
  health-check callback function timeout, startup delay and initial check state.
* `Existence.Plug` module providing customizable response for a http health-check endpoint.
* Support for multiple `Existence` instances and associated health-checks endpoints
  (example use case: separate Kubernetes readiness and liveness http probes).
* Dependencies health-checks states are cached and accessed using a dedicated ETS table per
  `Existence` instance, which means practically unlimited requests per second processing capacity
  without putting unnecessary load on a health-checked dependency.

## Installation
Add `Existence` library to your application `mix.exs` file:
```elixir
# mix.exs
def deps do
  [
    {:existence, "~> 0.3.1"}
  ]
end
```

## Usage
Define dependencies checks callback functions MFA's and start `Existence` child with your application
supervisor:
```elixir
# lib/my_app/application.ex
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    health_checks = [
      check_postgres: %{mfa: {MyApp.Checks, :check_postgres, []}}
    ]

    children = [{Existence, checks: health_checks}]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Declare your dependencies checks callback functions, in our example case PostgreSQL health-check:
```elixir
# lib/my_app/checks.ex
defmodule MyApp.Checks do
  def check_postgres() do
    "SELECT 1;"
    |> MyApp.Repo.query()
    |> case do
      {:ok, %Postgrex.Result{num_rows: 1, rows: [[1]]}} -> :ok
      _ -> :error
    end
  end
end
```

Dependency health-check function `check_postgres/0` will be spawned asynchronously by default every
30 seconds, checking if PostgreSQL instance associated with `MyApp.Repo` is healthy.
`check_postgres/0` results will be cached in the ETS table used further to provide responses to user
requests. If `/healthcheck` endpoint requests are issued thousands of times per second, they do not
hit and overload PostgreSQL, instead cached results from ETS are returned.

Current overall health-check state can be examined with `get_state/1`:
```elixir
iex> Existence.get_state()
:ok
```

Dependencies health-checks states can be examined with `get_checks/1`:
```elixir
iex> Existence.get_checks()
[check_postgres: :ok]
```

Library provides Plug module generating responses to the `/healthcheck` endpoint requests.
Example `Existence.Plug` usage with `Plug.Router.forward/2`:
```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  forward("/healthcheck", Existence.Plug)
end
```

