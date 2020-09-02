#' @importFrom stringr str_match
git_clone = function(repo, path) {
  dir_name = str_match(repo, "/(.*)\\.git$")[1, 2] #nolint
  path = file.path(path, dir_name)

  system2("git", c("clone", repo, path))
  return(TRUE)
}

#' Download R packages from jr-packages
#'
#' A convience function for downloading all jr-packages.
#' @param path Default \code{.}
#' @importFrom stringr str_extract
#' @export
get_jr_packages = function(path = ".") {
  repos = system2("curl",
                  "https://api.github.com/orgs/jr-packages/repos?per_page=100",
                  stdout = TRUE)
  git_repos = str_extract(repos, "git@.*\\.git")
  git_repos = git_repos[!is.na(git_repos)]
  if (length(git_repos) > 99) {
    stop("This function has been designed for up to 100 packages. Fixme!")
  }

  if (!file.exists(path)) dir.create(path)
  if (length(list.files(path)) != 0) stop("Directory not empty.")

  vapply(git_repos, git_clone, path = path, FUN.VALUE = logical(1))
}
