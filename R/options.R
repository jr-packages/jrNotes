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

#' @export
#' @import knitr
set_knitr_options = function( tidy = FALSE,
                              echo=FALSE,
                              highlight = TRUE,
                              comment = "#>",
                              collapse = TRUE,
                              cache = TRUE,
                              fig.align = "center"
                              ) {

  knitr::opts_chunk$set(
    tidy =tidy,
    echo=echo,
    highlight = highlight,
    comment = comment,
    collapse = collapse,
    cache = cache,
    fig.align=fig.align)
}

