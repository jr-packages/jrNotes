#' Set nice par
#'
#' Default parameters for plotting
#' @param mar c(3,3,2,1)
#' @param mgp c(2,0.4,0)
#' @param tck -.01
#' @param cex.axis 0.9
#' @param las 1
#' @param mfrow c(1, 1)
#' @param ... Additional arguments passed to \code{par}
#' @export
set_nice_par = function(mar = c(3, 3, 2, 1),
         mgp = c(2, 0.4, 0),
         tck = -.01,
         cex.axis = 0.9, #nolint
         las = 1,
         mfrow = c(1, 1),
         ...) {
  graphics::par(mar = mar,
      mgp = mgp, tck = tck,
      cex.axis = cex.axis, las = las,
      mfrow = mfrow, ...)
}
