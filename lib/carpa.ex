defmodule Carpa do
  use Agent
  use Application

  @tools_command_map %{
    cmake: "mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug ../ && cmake --build . --config Debug && ctest -j10 -C Debug -T test --output-on-failure",
    mix: "mix deps.get && mix test",
    npm: "npm install && npm run test",
    make: "make && make test",
    ruby: "bundle install && bundle exec rake test",
    rust: "cargo build && cargo test",
    python: "pip install -r requirements.txt && python -m unittest discover",
    cabal: "cabal build && cabal test",
    gradle: "./gradlew build && ./gradlew test",
  }
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

  def reg_repo(repo,branch,tool) do
    Agent.update(__MODULE__, fn state -> Map.put(state, {repo,branch}, tool) end)
  end

  def get_job_command(repo, branch) do
    tool = Agent.get(__MODULE__, fn state -> Map.get(state, {repo,branch}) end)
    tool = String.to_atom(tool)
    Map.get(@tools_command_map, tool)
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
    tool = Map.get(params, "tool")
    Carpa.reg_repo(repo, branch, tool)
    send_resp(conn, 200, "Job started")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
