defmodule CheckRepo do
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
    last_commit_hash = "git ls-remote #{repo} refs/heads/#{branch} | cut -f 1"
    last_commit_hash = System.cmd("bash", ["-c", last_commit_hash]) |> elem(0)

    System.cmd("touch", ["last_commit_hash.txt"])
    last_commit_checked = File.read!("last_commit_hash.txt")
    if last_commit_hash == last_commit_checked do
      IO.puts "No new commits"
    else
      IO.puts "New commits"
      File.write!("last_commit_hash.txt", last_commit_hash)
    end
    {:reply, :ok, state}
  end
end
