defmodule CheckRepo do
  use GenServer
  alias Dispatcher

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(init_arg) do
    Dispatcher.start_link()
    {:ok, init_arg}
  end

  def check(repo, branch) do
    GenServer.call(__MODULE__, {:check, repo, branch})
  end

  def handle_call({:check, repo, branch}, _from, state) do
    IO.puts "Checking #{repo} on branch #{branch}"
    current_commit = get_current_commit(repo, branch)


    file_name = prepare_file_name(repo, branch)
    File.touch(file_name)
    last_commit = File.read(file_name) |> handle_file_read()

    if current_commit == last_commit do
      IO.puts "No new commits"
    else
      IO.puts "New commits"
      File.write!(file_name, current_commit)
      spawn(Dispatcher, :dispatch, [repo, branch])
    end
    {:reply, :ok, state}
  end

  defp prepare_file_name(repo, branch) do
    hash = hash_string("#{repo}#{branch}")
    file = "last_commit_#{hash}"
    File.mkdir_p(".repos")
    ".repos/#{file}"
  end

  defp get_current_commit(repo, branch) do
    command = "git ls-remote #{repo} refs/heads/#{branch} | cut -f 1"
    System.cmd("bash", ["-c", command]) |> elem(0)
  end

  defp handle_file_read({:ok, content}), do: content
  defp handle_file_read({:error, _reason}), do: ""
  defp hash_string(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
  end

end
