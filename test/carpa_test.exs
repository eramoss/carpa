defmodule CarpaTest do
  use ExUnit.Case
  doctest Carpa

  test "register repo" do
    Carpa.start_link()
    Carpa.reg_repo("../.git", "master", "mix test")
    assert Carpa.get_job_command("../.git", "master") == "mix test"
  end
end
