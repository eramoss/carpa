defmodule Dispatcher do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(init_arg) do
    {:ok, init_arg}
  end
  def dispatch(repo, branch) do
    GenServer.call(__MODULE__, {:dispatch, repo, branch})
  end
  def handle_call({:dispatch, repo, branch}, _from, state) do
    spawn(fn ->
      job_command = Carpa.get_job_command(repo, branch)
      if job_command == nil do
        IO.puts "No job command found for #{repo} on branch #{branch}"
      else
        IO.puts "Dispatching worker with command: #{job_command} for #{repo} on branch #{branch}"
        Task.async(fn -> Worker.run(repo,branch,job_command) end)
      end
    end)
    {:reply, :ok, state}
  end
end
