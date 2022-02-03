defmodule Existence do
  @moduledoc """
  Existence - dependency health checks library
  """

  defdelegate child_spec(init_arg), to: Existence.GenCheck
end
