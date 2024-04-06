defmodule Carpa do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
    CheckRepo.start_link()
  end

  def reg_repo(repo,branch,command) do
    Agent.update(__MODULE__, fn state -> Map.put(state, {repo,branch}, command) end)
  end

  def get_job_command(repo, branch) do
    Agent.get(__MODULE__, fn state -> Map.get(state, {repo,branch}) end)
  end
end
