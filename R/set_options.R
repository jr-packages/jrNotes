# nolint start
#' Set Standard options
#'
#' Set consistent options for notes
#' @param digits 3
#' @param dplyr.print_min 4
#' @param dplyr.print_max 4
#' @param htmltools.dir.version FALSE
#' @param width R output width default 60. Not everything obeys this, hence the
#' need for a knitr_hook
#' @export
set_options = function(digits = 3,
                       dplyr.print_min = 4,
                       dplyr.print_max = 4,
                       htmltools.dir.version = FALSE,
                       width = 60
) {

  options(digits = digits,
          dplyr.print_min = dplyr.print_max,
          dplyr.print_max = dplyr.print_min,
          htmltools.dir.version = htmltools.dir.version,
          width = width
  )
}



# nolint end
