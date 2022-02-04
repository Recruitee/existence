defmodule Existence do
  alias Existence.GenCheck

  @moduledoc """
  Existence - versatile async dependency health checks library.
  """

  defdelegate get_state(), to: GenCheck
  defdelegate get_check_state(check_id), to: GenCheck

  @doc false
  defdelegate child_spec(init_arg), to: GenCheck
end
