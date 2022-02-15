defmodule Existence do
  @moduledoc """
  Existence - versatile async dependency health checks library.
  """

  alias Existence.GenCheck

  defdelegate get_state(), to: GenCheck
  defdelegate get_checks(), to: GenCheck

  @doc false
  defdelegate child_spec(init_arg), to: GenCheck
end
