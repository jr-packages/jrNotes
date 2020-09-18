info = cli::symbol$info
tick = cli::symbol$tick
cross = cli::symbol$cross
circle_filled = cli::symbol$circle_filled
star = cli::symbol$star
question = cli::symbol$fancy_question_mark

red = crayon::red
blue = crayon::blue
yellow = crayon::yellow
green = crayon::green
cyan = crayon::cyan
reset = crayon::reset

get_padding = function(padding) {
  if (padding == 0) {
    pads = ""
  } else{
    pads = paste(rep(" ", padding), collapse = "")
  }
  pads
}

globalVariables("pads")
#' @importFrom glue glue_col
msg_error = function(msg, padding = 0, stop = FALSE) {
  pads = get_padding(padding)
  if (isFALSE(stop)) {
    message(glue::glue_col("{red}{pads}{cross} {msg}{reset}"))
  } else {
    stop(glue::glue_col("{red}{pads}{cross} {msg}"), call. = FALSE)
  }
}

#' @importFrom glue glue_col
msg_start = function(msg, padding = 0) {
  pads = get_padding(padding)
  message(glue::glue_col("{blue}{pads}{circle_filled} {msg}{reset}"))
}

#' @importFrom glue glue_col
msg_ok = function(msg, padding = 0) {
  pads = get_padding(padding)
  message(glue::glue_col("{green}{pads}{tick} {msg}{reset}"))
}

#' @importFrom glue glue_col
msg_info = function(msg, padding = 0) {
  pads = get_padding(padding)
  message(glue::glue_col("{yellow}{pads}{info} {msg}{reset}"))
}
