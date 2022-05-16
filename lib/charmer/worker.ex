defmodule Charmer.Worker do
  use GenServer
  use Export.Python

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    {:ok, py_pid} = opts |> extract_erlport_opts() |> Python.start_link()

    {:ok, %{py_pid: py_pid}}
  end

  @impl true
  def handle_call({:call, module, function, args}, _, %{py_pid: py_pid} = state) do
    result = Python.call(py_pid, module, function, args)
    {:reply, result, state}
  end

  defp extract_erlport_opts(opts) do
    [python: opts[:python_exec], python_path: opts[:python_path]]
  end
end
