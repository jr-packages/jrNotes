cross = cli::symbol$cross
star = cli::symbol$star

#' @importFrom cli cli_ol
open_pad = function() {
  cli::cli_ol(.auto_close = FALSE)
  cli::cli_ol(.auto_close = FALSE)
}

#' @importFrom cli cli_end
close_pad = function() {
  cli::cli_end()
  cli::cli_end()
}

#' @importFrom glue glue_col
#' @importFrom cli cli_alert_danger
msg_error = function(msg, padding = FALSE, error_origin = NULL) {
  if (padding > 0) {
    open_pad()
    on.exit(close_pad())
  }
  cli::cli_alert_danger("{msg}")
  if (!is.null(error_origin) && length(sys.calls()) > 1L) {
    error_origin = deparse(sys.calls()[[sys.nframe() - 1]])
  }
  set_error(origin = error_origin)
}

#' @importFrom glue glue_col
#' @importFrom cli cli_h3
msg_start = function(msg, padding = FALSE) {
  if (padding > 0) {
    open_pad()
    on.exit(close_pad())
  }
  cli::cli_h3("{msg}")
}

#' @importFrom cli cli_alert_warning
msg_warning = function(msg, padding = FALSE) {
  if (padding > 0) {
    open_pad()
    on.exit(close_pad())
  }
  cli::cli_alert_warning("{msg}")
}

#' @importFrom glue glue_col
#' @importFrom cli cli_alert_success
msg_success = function(msg, padding = 0) {
  if (padding > 0) {
    open_pad()
    on.exit(close_pad())
  }
  cli::cli_alert_success("{msg}")
}

#' @importFrom glue glue_col
#' @importFrom cli cli_alert_info
msg_info = function(msg, padding = 0) {
  if (padding > 0) {
    open_pad()
    on.exit(close_pad())
  }
  cli::cli_alert_info("{msg}")
}
