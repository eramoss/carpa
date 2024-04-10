# Carpa

**A CI multi server inspired in 500lines or less**

## Use

``` shell
mix run --no-halt
```

The main application will start and listening on port 4000 /reg_repo.
To register a repo you can just send a request with url params:

```
  repo: the url to .git directory, e.g https://github.com/eramoss/carpa.git
  branch: the branch that you want to test
  tool: the tool that you are using to test, e.g [mix, cmake, rust (cargo), python (unittest discover), ...] 
```
You can see all the tools on `carpa.ex`

Example:

``` shell
curl -X POST -d "repo=https://github.com/eramoss/dsun.git&branch=master&tool=cmake" "http://localhost:4000/reg_repo"
```
