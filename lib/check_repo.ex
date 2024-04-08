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
    current_commit = Utils.get_current_commit(repo, branch)


    file_name = Utils.prepare_file_name(repo, branch)
    File.touch(file_name)
    last_commit = File.read(file_name) |> Utils.handle_file_read()
    if !Utils.is_already_running_test?(repo, branch) do
      if current_commit == last_commit do
        Logger.info "No new commits"
      else
        Logger.info "New commit detected"
        File.write!(file_name, current_commit)
        spawn(Dispatcher, :dispatch, [repo, branch])
      end
    end
    {:reply, :ok, state}
end

end
