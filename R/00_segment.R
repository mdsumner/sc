#' Given a `PATH`` model decompose to 1-dimensional primitives (or 0-dimensional). 
#' 
#' @param x input object
#' @param ... arguments passed to methods
#' @importFrom dplyr %>% inner_join mutate 
#' @name sc_segment
#' @export
sc_segment <- function(x, ...) UseMethod("sc_segment")
#' @name sc_segment
#' @export
sc_segment.default <- function(x, ...) {
  x <- PATH(x)
  sc_segment(x, ...)
}
#' @name sc_segment
#' @export
sc_segment.PATH <- function(x, ...) {
  sc_segment_base(x[["path_link_vertex"]]) 
}


path_to_segment0 <- function(x) faster_as_tibble(list(.vertex0 = utils::head(x, -1L), 
                                                      .vertex1 = utils::tail(x, -1)))

sc_segment_base <- function(path_link_vertex) {
  ## how many vertices on each path?
  frle <- rle(path_link_vertex[["path_"]])
  ## push into segments 
  segtab <- path_to_segment0(path_link_vertex[["vertex_"]])
  if (length(frle$values) > 1L) {
    ## this fails if there's only one path in the whole set
    ## fixes https://github.com/hypertidy/silicate/issues/40
    segtab <- segtab[-head(cumsum(frle$lengths), -1L), ]
  }
  segtab[["path_"]] <- rep(frle$values, frle$lengths - 1)
  segtab[["segment_"]] <- sc_uid(nrow(segtab))
  edge <- paste(pmin(segtab[[".vertex0"]], segtab[[".vertex1"]]), pmax(segtab[[".vertex0"]], segtab[[".vertex1"]]), sep = "_")
  f <- factor(edge)
  segtab[["edge_"]] <- sc_uid(nlevels(f))[f]
  segtab
}