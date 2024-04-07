defmodule CarpaTest do
  use ExUnit.Case
  doctest Carpa

  test "register repo" do
    Carpa.start_link()
    Carpa.reg_repo("./.git", "master", "mix test")
    assert Carpa.get_job_command("./.git", "master") == "mix test"
  end

  defmodule CheckRepoTest do
    use ExUnit.Case

    alias CheckRepo, as: Repo

    describe "prepare_file_name/2" do
      test "returns a string with the hashed repo and branch name" do
        assert Repo.prepare_file_name("repo", "branch") =~ ".repos/last_commit_"
      end
    end

    describe "get_current_commit/2" do
      test "returns the current commit hash" do
        assert Repo.get_current_commit("./.git", "master") =~ ~r/^[0-9a-f]{40}$/
      end
    end

    describe "handle_file_read/1" do
      test "returns the content when the read is successful" do
        assert Repo.handle_file_read({:ok, "content"}) == "content"
      end

      test "returns an empty string when the read fails" do
        assert Repo.handle_file_read({:error, :enoent}) == ""
      end
    end

    describe "hash_string/1" do
      test "returns a SHA256 hash of the string" do
        assert Repo.hash_string("string") =~ ~r/^[0-9a-f]{64}$/
      end
    end
  end
end
