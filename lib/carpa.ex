defmodule Carpa do
  use Agent
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Carpa.Router, options: [port: 4000]}
    ]
    main()
    Supervisor.start_link(children, strategy: :one_for_one)
  end

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

  def main do
    start_link()
    Task.async(fn ->
      big_check_loop()
    end)
  end

  def big_check_loop do
    repo_mapper = Agent.get(__MODULE__, fn state -> state end)
    Enum.each(repo_mapper, fn {{repo, branch}, _command} ->
        CheckRepo.check(repo, branch)
    end)
    Process.sleep(10000)
    big_check_loop()
  end


end
defmodule Carpa.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/reg_repo" do
    {:ok, params, _} = Plug.Conn.read_body(conn)
    params = URI.decode_query(params)
    repo = Map.get(params, "repo")
    branch = Map.get(params, "branch")
    command = Map.get(params, "command")
    Carpa.reg_repo(repo, branch, command)
    send_resp(conn, 200, "Job started")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
