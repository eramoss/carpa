defmodule CheckRepo do
  use GenServer
  require Logger

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
    Logger.info("Checking repo #{repo} branch #{branch}")
    current_commit = get_current_commit(repo, branch)


    file_name = prepare_file_name(repo, branch)
    File.touch(file_name)
    last_commit = File.read(file_name) |> handle_file_read()

    if current_commit == last_commit do
      Logger.info "No new commits"
    else
      Logger.info "New commit detected"
      File.write!(file_name, current_commit)
      spawn(Dispatcher, :dispatch, [repo, branch])
    end
    {:reply, :ok, state}
  end

  def prepare_file_name(repo, branch) do
    hash = hash_string("#{repo}#{branch}")
    file = "last_commit_#{hash}"
    File.mkdir_p(".repos")
    ".repos/#{file}"
  end

  def get_current_commit(repo, branch) do
    command = "git ls-remote #{repo} refs/heads/#{branch} | cut -f 1"
    System.cmd("bash", ["-c", command]) |> elem(0)
  end

  def handle_file_read({:ok, content}), do: content
  def handle_file_read({:error, _reason}), do: ""
  def hash_string(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
  end

end
