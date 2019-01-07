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
#' @param ... Additional arguments passed to opt_chunk
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
                             fig.height = 4,
                             ...
) {
  knitr::opts_chunk$set(
    tidy = tidy,
    echo = echo,
    highlight = highlight,
    comment = comment,
    collapse = collapse,
    cache = cache,
    fig.align = fig.align,
    fig.width = fig.width,
    fig.height = fig.height,
    ...)

  if(fs::file_exists("config.yml")) {
    con = config::get()
    if(!is.null(con$knitr)) {
      do.call(knitr::opts_chunk$set, con$knitr)
    }
  }
  check_python()
}
