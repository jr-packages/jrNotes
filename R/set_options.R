# nolint start
#' Set Standard options
#'
#' Set consistent options for notes
#' @param digits 3
#' @param dplyr.print_min 4
#' @param dplyr.print_max 4
#' @param htmltools.dir.version FALSE
#' @export
set_options = function(digits = 3,
                       dplyr.print_min = 4,
                       dplyr.print_max = 4,
                       htmltools.dir.version = FALSE
) {

  options(digits = digits,
          dplyr.print_min = dplyr.print_max,
          dplyr.print_max = dplyr.print_min,
          htmltools.dir.version = htmltools.dir.version
  )
}



# nolint end
