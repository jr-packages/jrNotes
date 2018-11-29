#' #' Figure references
#' #'
#' #' Some more of Jamie's magic code for refecnes
#' #' @export
#' fig = local({
#'   i = 0
#'   ref = list()
#'   list(
#'     cap=function(refName, text) {
#'       i <<- i + 1
#'       ref[[refName]] <<- i
#'       paste(text, sep="")
#'     },
#'     ref=function(refName) {
#'       ref[[refName]]
#'     })
#' })
