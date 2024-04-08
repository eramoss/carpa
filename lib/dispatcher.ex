defmodule Dispatcher do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(init_arg) do
    {:ok, init_arg}
  end
  def dispatch(repo, branch, current_commit) do
    GenServer.call(__MODULE__, {:dispatch, repo, branch, current_commit})
  end
  def handle_call({:dispatch, repo, branch, current_commit}, _from, state) do
    spawn(fn ->
      job_command = Carpa.get_job_command(repo, branch)
      if job_command == nil do
        Logger.error "No command for #{repo} on branch #{branch}"
      else
        Logger.info "Running job for #{repo} on branch #{branch}"
        Task.async(fn -> Worker.run(repo,branch,job_command, current_commit) end)
      end
    end)
    {:reply, :ok, state}
  end
end
