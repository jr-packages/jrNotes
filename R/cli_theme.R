
# See cli::builtin_theme for other options
#' @importFrom cli symbol

get_cli_theme = function() {
  theme = list(
    h1 = list(`font-weight` = "bold", `margin-top` = 1, `margin-bottom` = 0,
              fmt = function(x) cli::rule(x, line_col = "yellow")),
    h2 = list(`font-weight` = "bold",  `margin-top` = 1, `margin-bottom` = 1,
              fmt = function(x)
                paste0(symbol$line, symbol$line, " ", x, " ", symbol$line, symbol$line)),
    h3 = list(`margin-top` = 1,
              fmt = function(x) {
                crayon::cyan(paste0(symbol$line, symbol$line, " ", x, " "))
              }),
    .alert = list(before = paste0(symbol$arrow_right, " ")),
    `.alert-success` = list(before = paste0(crayon::green(symbol$tick), " "), color = "green"),
    `.alert-danger` = list(before = paste0(crayon::red(symbol$cross), " "), color = "red"),
    `.alert-warning` = list(before = paste0(crayon::yellow(symbol$warning), " ")),
    `.alert-info` = list(before = paste0(crayon::cyan(symbol$info), " "))
  )
  theme
}
