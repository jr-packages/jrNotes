#' Set Standard options
#'
#' Set consistent options for notes / check pandoc version
#' @param digits 3
#' @param dplyr.print_min 4
#' @param dplyr.print_max 4
#' @param htmltools.dir.version FALSE
#' @param makefile TRUE
#' @export
set_options = function(digits = 3,
                       dplyr.print_min = 4,
                       dplyr.print_max = 4,
                       htmltools.dir.version = FALSE,
                       makefile = TRUE
) {

  if (makefile) {
    if (file.exists("check")) {
      x = file.info("check")$mtime
      if (Sys.time() - x > 5) {
        stop("You must run using a Makefile")
      }
    } else{
      stop("You must run using a Makefile")
    }
  }

  options(digits = digits,
          dplyr.print_min = dplyr.print_max,
          dplyr.print_max = dplyr.print_min,
          htmltools.dir.version = htmltools.dir.version
  )
}


#' Set consistent knitr options
#'
#' Set consistent knitr options
#' @param tidy FALSE
#' @param echo TRUE
#' @param highlight TRUE
#' @param comment #>
#' @param collapse TRUE
#' @param cache TRUE
#' @param fig.align center
#' @param fig.width 4
#' @param fig.height 4
#' @export
#' @import knitr
set_knitr_options = function(tidy = FALSE,
                             echo = TRUE,
                             highlight = TRUE,
                             comment = "#>",
                             collapse = TRUE,
                             cache = TRUE,
                             fig.align = "center",
                             fig.width = 4,
                             fig.height = 4
) {
  knitr::opts_chunk$set(
    tidy =tidy,
    echo=echo,
    highlight = highlight,
    comment = comment,
    collapse = collapse,
    cache = cache,
    fig.align=fig.align,
    fig.width = fig.width,
    fig.height = fig.height)
}

