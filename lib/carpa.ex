defmodule Carpa do
  use GenServer
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def check_repo(repo, branch) do
    GenServer.call(__MODULE__, {:check_repo, repo, branch})
  end

  def handle_call({:check_repo, repo, branch}, _from, state) do
    IO.puts "Checking #{repo} on branch #{branch}"
    {:reply, :ok, state}
  end

end
