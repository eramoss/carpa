defmodule Worker do
  def run(repo, branch, command) do
    File.mkdir_p("tmp")
    IO.puts "Running command: #{command} for #{repo} on branch #{branch}"
    clone_inside_tmp(repo, branch)
    System.cmd("bash", ["-c", command])
    File.cd("../..")
    File.rm_rf("tmp")
  end

  defp clone_inside_tmp(repo, branch) do
    File.cd("tmp")
    System.cmd("git", ["clone", repo])
    File.cd("#{String.split(repo, "/") |> List.last |> String.replace(~r/\.git$/, "")}")
    System.cmd("git", ["checkout", branch])
  end
end
