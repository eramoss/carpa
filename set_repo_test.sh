mix new tester_repo

echo "defmodule TesterRepoTest do
  use ExUnit.Case
  doctest TesterRepo

  test \"sleeps for test\" do
    Process.sleep(10000)
    assert true
  end
end
" >  tester_repo/test/tester_repo_test.exs 

git -C ./tester_repo init
git -C ./tester_repo branch -m master
git -C ./tester_repo add .
git -C ./tester_repo commit -m "Initial commit"
