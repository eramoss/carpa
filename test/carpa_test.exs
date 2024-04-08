defmodule CarpaTest do
  use ExUnit.Case
  doctest Carpa

  describe "should run 2 commits of the same repo in parallel" do
    # Clean .repos/commit
    commit_file = Utils.prepare_file_name("./tester_repo/.git", "master")
    File.rm(commit_file)


    Carpa.start_link()
    Carpa.reg_repo("./tester_repo/.git", "master", "mix")
    # The worker needs 20 seconds to run this job
    CheckRepo.check("./tester_repo/.git", "master")
    Process.sleep(3000)
    File.write!("./tester_repo/test_helper.txt", "test helper")
    System.cmd("git", ["-C", "./tester_repo","add", "test_helper.txt"])
    System.cmd("git", ["-C", "./tester_repo","commit", "-m", "test_helper.txt"])

    # Run the job while the worker is busy with the last one
    CheckRepo.check("./tester_repo/.git", "master")


    # Clean test and wait workers
    Process.sleep(20000)
    File.rm(commit_file)
    File.rm("./tester_repo/test_helper.txt")
    System.cmd("git", ["-C", "./tester_repo","reset", "HEAD~"])
    System.cmd("git", ["-C", "./tester_repo" , "restore", "."])
    File.rmdir("tmp")
  end
end
