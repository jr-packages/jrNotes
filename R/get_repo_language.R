# Detect the repo's language
#' @importFrom gert git_config
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
