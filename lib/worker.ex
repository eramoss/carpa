defmodule Worker do
  def run(repo, branch, command) do
    File.mkdir_p("tmp")
    IO.puts "Running command: #{command} for #{repo} on branch #{branch}"
    clone_inside_tmp(repo, branch)
    dir = "tmp/#{hash_string(repo)}"
    System.cmd("bash", ["-c", "cd #{dir} && #{command}"], into: IO.stream(:stdio, :line))
    System.cmd("rm", ["-rf", dir])
  end

  defp clone_inside_tmp(repo, branch) do
    System.cmd("git", ["clone", repo, "tmp/#{hash_string(repo)}"],into: IO.stream(:stdio, :line))
    System.cmd("git", ["-C" ,"tmp/#{hash_string(repo)}","checkout", branch], into: IO.stream(:stdio, :line))
  end

  defp hash_string(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
  end
end
