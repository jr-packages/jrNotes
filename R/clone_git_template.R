#' Create Notes
#'
#' @description Creates a Jumping Rivers style notes directory.
#' This assumes you have set up a private SSH key for Git.
#' @param name The title of the notes directory you want to create
#' i.e. jRintroduction_notes. This defaults to "jRexample_notes".
#' To force you to create a directory with a name other than the default,
#' the default will break the function.
#' Unless the proper notation for a jumping rivers notes directory is
#' followed the function will have a paddy! i.e. must start with a "jr" and end in "_notes".
#' @param path The path where you want to place the notes. Default is NULL, which will create
#' the notes directory inside your current working directory.
#' @param push Default \code{FALSE}. TRUE to push and create the repo.
#' @export
clone_git_template = function(name = NULL,
                                 path = NULL,
                                 push = FALSE) {
  if (is.null(path)) {
    path = getwd()
  }

  if (is.null(name)) {
    stop("Need name of new repo.", call. = FALSE)
  }
  if (substr(name, 1, 2) != "jr" ||
      substr(name, nchar(name) - 5, nchar(name)) != "_notes" ||
      toupper(substr(name, 3, 3)) != substr(name, 3, 3)) {
    stop("Notes repo name should take form of jrCoursename_notes",
         call. = FALSE)
  }

  old_wd = getwd()
  on.exit(setwd(old_wd))

  repo_name = file.path(path, name)
  system2("git", args = c("clone",
                          "--depth",
                          "1",
                          "git@gitlab.com:jumpingrivers-notes/template.git", #nolint
                          repo_name))
  setwd(repo_name)

  ### remove current README and add general notes one
  file.remove("README.md")
  title = paste0("# ", name)
  build_status = "Package build status: [![Build Status](https://api.travis-ci.org/jr-packages/jrXxxx.png?branch=master)](https://travis-ci.org/jr-packages/)" #nolint
  writeLines(c(title, build_status), "README.md")

  git_repo = paste0("git@gitlab.com:jumpingrivers-notes/course_notes/",
                    name, ".git")
  system2("git", args = c("remote", "set-url", "origin", git_repo))

  if (push) {
    system2("git", args = c("push", "-u", "origin", "master"))
  } else {
    message("Remember to run \"git push -u origin master\" if you want to later push to and create the repo.") #nolint
  }

  return(invisible(repo_name))
}
