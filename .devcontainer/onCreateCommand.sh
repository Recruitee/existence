#!/bin/bash

mix local.hex --force
mix local.rebar --force

mix deps.get
mix deps.compile --return-errors
mix compile --return-errors

MIX_ENV=test mix deps.compile --return-errors
MIX_ENV=test mix compile --return-errors

exit 0
