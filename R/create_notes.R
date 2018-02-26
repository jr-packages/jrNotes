#' Create Notes
#'
#' @description Creates a Jumping Rivers style notes directory.
#' This assumes you have set up a private SSH key for Git.
#' @param name The title of the notes directory you want to create
#' i.e. jRintroduction_notes. This defaults to "jrNotes_Example", which will break the function.
#' This is in order to stop you accidentally creating GitLab project after GitLab project!
#' Unless the proper notation for a jumping rivers notes directory is
#' followed the function will have a paddy!
#' @param path The path where you want to place the notes. Default is home.
#' This must be a full path from the home directory and end in a /.
#' However, the function will force you to do this.
#' @export
create_notes = function(name = "jrNotes_Example", path = "~/"){
  if(substr(path, nchar(path), nchar(path)) != "/" | substr(path, 1, 1) != "~"){
    stop("Path should start with ~ and end in /")
  } else if (substr(name, 1, 2) != "jR" | substr(name, nchar(name) - 5, nchar(name)) != "_notes"){
    stop("Notes repo name should take form of jRcoursename_notes")
  } else {
    oldwd = getwd()
    setwd(path)
    system2("git",
            args = c("clone", "git@gitlab.com:jumpingrivers/tools/jRtemplate_notes.git", name))
    setwd(paste0(path, name))
    system2("git",
            args = c("remote", "set-url", "origin",
                     paste0("git@gitlab.com:jumpingrivers/course_notes/", name,".git")))
    system2("git", args = c("push", "-u", "origin", "master"))
    setwd(oldwd)
  }
}
