defmodule Utils do
  require Logger

  def hash_string(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
  end
  def is_already_running_test?(repo, branch) do
    dir = Path.join("tmp", hash_string(repo))
    if File.dir?(dir) do
      Logger.info("Job for #{repo} on branch #{branch} is already running")
      true
    else
      false
    end
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
end
