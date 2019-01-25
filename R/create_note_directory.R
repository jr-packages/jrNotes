#' Create Notes
#'
#' @description Creates a Jumping Rivers style notes directory.
#' This assumes you have set up a private SSH key for Git.
#' @param name The title of the notes directory you want to create
#' i.e. jRintroduction_notes. This defaults to "jRexample_notes".
#' To force you to create a directory with a name other than the default,
#' the default will break the function.
#' Unless the proper notation for a jumping rivers notes directory is
#' followed the function will have a paddy! i.e. must start with a "jR" and end in "_notes".
#' @param path The path where you want to place the notes. Default is NULL, which will create
#' the notes directory inside your current working directory. When the path is specified,
#' it must be a full path from the home directory, so must start with a "~".
#' The function will force you to comply.
#' @param push A logical. TRUE to push and create the repo, FALSE to not. Default is FALSE.
#' @export
create_note_directory = function (name = "jRexample_notes", path = NULL, push = FALSE)
{
  if(is.null(path)){
    path = getwd()
  }  else{
    if(substr(path, 1, 1) != "~"){
      stop("Path must begin with a tilda, ~ , i.e. it must start from the home directory.")
    }
  }
  if(name == "jRexample_notes") {
    stop("Please do not use the default directory name.")
  }
  if (substr(name, 1, 2) != "jR" | substr(name, nchar(name) -
                                          5, nchar(name)) != "_notes") {
    stop("Notes repo name should take form of jRcoursename_notes", call. = FALSE)
  }

  old_wd = getwd()
  on.exit(setwd(old_wd))

  repo_name = file.path(path, name)
  system2("git", args = c("clone", "git@gitlab.com:jumpingrivers/tools/jRtemplate_notes.git",
                          repo_name))

  setwd(repo_name)

  ### remove current README and add general notes one
  file.remove("README.md")
  title = paste0("# ", name)
  build_status = "Package build status: [![Build Status](https://api.travis-ci.org/jr-packages/jrXxxx.png?branch=master)](https://travis-ci.org/jr-packages/)"
  writeLines(c(title, build_status), "README.md")

  system2("git", args = c("remote", "set-url", "origin",
                          paste0("git@gitlab.com:jumpingrivers/course_notes/",
                                 name, ".git")))

  if(push) {
    system2("git", args = c("push", "-u", "origin", "master"))
  } else {
    message("Remember to run \"git push -u origin master\" if you want to later push to and create the repo.")
  }

  return(invisible(repo_name))
}
