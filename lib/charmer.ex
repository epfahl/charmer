defmodule Charmer do
  @moduledoc """
  ## Basic usage

  More to come...
  """

  @default_timeout 10_000
  @default_opts [
    pool_size: 1,
    pool_max_overflow: 0,
    python_exec: "python3",
    python_path: nil
  ]

  @doc """
  Starts a supervised Python worker pool linked to the current process.`

  ## Options
    * `:pool_size` [default: 1] - number of Python workers
    * `:pool_max_overflow` [default: 0] - number of temporary
      overflow workers (same as `max_overflow` in
      [Poolboy](https://github.com/devinus/poolboy))
    * `:python_exec` [default: "python3"] - name of the Python interpreter executable
      (same as the `:python` parameter in
      [ErlPort's :python.start](http://erlport.org/docs/python.html#python-start-1))
    * `:python_path` [default: nil] - path to Python modules (same as the `:python_path`
      parameter in
      [ErlPort's :python.start](http://erlport.org/docs/python.html#python-start-1))

  ## Return values
  `{:ok, pid}` or `{:error, reason}`
  """
  def start_link(opts \\ []) do
    opts
    |> merge_opts()
    |> Charmer.Supervisor.start_link()
  end

  @doc """
  Terminate the supervisor process and all of its worker children.
  """
  def stop() do
    Charmer.Supervisor.stop()
  end

  @doc """
  Checkout a Python worker from the pool and perform a blocking call with the given
  Python module name, function name, and argument list. The worker is checked backed
  back into the pool after the Python function returns.
  """
  def call(module, function, args, timeout \\ @default_timeout) do
    :poolboy.transaction(
      :worker,
      fn pid ->
        GenServer.call(
          pid,
          {:call, module, function, args},
          timeout
        )
      end,
      timeout
    )
  end

  defp merge_opts(opts) do
    @default_opts |> Keyword.merge(opts)
  end
end
