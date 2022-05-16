defmodule Charmer.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    poolboy_opts = extract_poolboy_opts(opts)
    worker_opts = extract_worker_opts(opts)

    children = [
      :poolboy.child_spec(:worker, poolboy_opts, worker_opts)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def stop() do
    Supervisor.stop(__MODULE__)
  end

  defp extract_poolboy_opts(opts) do
    [size: opts[:pool_size], max_overflow: opts[:pool_max_overflow]]
    |> Keyword.merge(name: {:local, :worker}, worker_module: Charmer.Worker)
  end

  defp extract_worker_opts(opts) do
    [python_exec: opts[:python_exec], python_path: opts[:python_path]]
  end
end
