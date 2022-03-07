ExUnit.start(capture_log: true)

defmodule ExistenceTest.Common do
  def start(config, init_sleep \\ 10) do
    _pid = ExUnit.Callbacks.start_supervised!({Existence, config})
    Process.sleep(init_sleep)
    :ok
  end
end
