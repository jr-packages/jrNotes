#' Detect the repo's language
#'
#' Get the language for the R repo
#' @export
get_repo_language = function() {
  config = gert::git_config()
  origin_url = config[config$name == "remote.origin.url", ]$value
  if (str_detect(origin_url, "python")) {
    language = "python"
  } else {
    language = "r"
  }
  return(language)
}
