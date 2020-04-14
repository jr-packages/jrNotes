#' Insert \code{#> } .
#'
#' Call this function as an addin to insert \code{#> } at the cursor position.
#' @importFrom rstudioapi insertText
#' @export
insert_live_comment <- function() {
  rstudioapi::insertText("#> ")
}

#' Insert banner
#'
#' Call this function as an addin to insert a banner at the cursor position.
#' @importFrom rstudioapi insertText
#' @export
insert_banner <- function() {
  rstudioapi::insertText("## ===============================================")
}


#' Inserts \code{#> }  in front of highlighted text.
#'
#' Call this function as insert \code{#> } at the start of highlighted text.
#' @importFrom rstudioapi getActiveDocumentContext insertText
#' @export
live_comment_highlight <- function() {

  # Gets The active Documeent
  ctx <- rstudioapi::getActiveDocumentContext()

  # Checks that a document is active
  if (!is.null(ctx)) {
    selection = ctx$selection
    selection_start = selection[[1]]$range$start[1]
    selection_end = selection[[1]]$range$end[1]
    pos = Map(c, selection_start:selection_end, 1)
    rstudioapi::insertText(pos, "#> ")
  }
}
