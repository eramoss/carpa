defmodule Worker do
  require Logger

  def run(repo, branch, command) do
    case File.mkdir_p("tmp") do
      :ok ->
        Logger.info("Running job for #{repo} on branch #{branch}")
        clone_inside_tmp(repo, branch)
        dir = Path.join("tmp", hash_string(repo))
        result = System.cmd("bash", ["-c", "cd #{dir} && #{command}"])
        log_file = Path.join("tmp", "#{hash_string(repo)}.log")
        handle_result(result, repo, branch, log_file)
        File.rm_rf(dir)
      {:error, reason} ->
        Logger.error("Failed to create directory: #{reason}")
    end
  end

  defp clone_inside_tmp(repo, branch) do
    dir = Path.join("tmp", hash_string(repo))
    System.cmd("git", ["clone", repo, dir])
    System.cmd("git", ["-C", dir, "checkout", branch])
  end

  defp handle_result({out, 0}, repo, branch, log_file) do
    File.write!(log_file, out)
    Logger.info("Job for #{repo} on branch #{branch} finished successfully")
  end

  defp handle_result({reason, exit_n}, repo, branch, log_file) do
    File.write!(log_file, reason)
    Logger.error("Job for #{repo} on branch #{branch} failed: #{exit_n}\n See the logs for more details")
  end

  defp hash_string(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
  end
end
