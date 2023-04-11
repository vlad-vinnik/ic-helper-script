# ic-helper-script

IC Helper Script scans for Git repositories at a given path and performs various operations on them.

## Usage

`.\ic-helper.ps1 <command> <path> [-force]`

## Commands

- `clean`: Execute `git clean -xfd` on all repositories. When `-force` option is specified, do this without prompting for user confirmation.
- `pull`: Execute `git pull` on all repositories. When `-force` option is specified, do force pulling.
- `fetch`: Execute `git fetch` on all repositories.
- `help` or `/?`: Print help information and exit.

## Functional Overview

The script consists of six functions:

1. `Find-GitRepositories` function searches for Git repositories in a given directory (and its subdirectories) and invokes the appropriate function according to the command specified by the user.
2. `Test-GitRepositoryClean` function checks if a given Git repository is clean by performing a dry run of `git clean -xfd` command. When the repository is not clean, the function prompts the user to execute the command. If `-force` parameter is specified, the function executes the command without prompting the user.
3. `Invoke-GitFetch` function executes `git fetch` on a given Git repository. It has one parameter: `$directory` (the path to the Git repository).
4. `Invoke-GitPull` function executes `git pull` on a given Git repository, with an optional `--force` flag. It has two parameters: `$directory` (the path to the Git repository) and `$force` (a switch parameter indicating whether to use the `--force` flag with `git pull`).
5. `Get-CommandStatus` function checks the exit status of `git clean`, `git fetch` and `git pull`, and provides the appropriate output to the user.
6. `Show-Help` function shows help information for the user.

## Author

Vlad Vinnik [vladislav.vinnik@wolterskluwer.com](<mailto:vladislav.vinnik@wolterskluwer.com](mailto:)>)
