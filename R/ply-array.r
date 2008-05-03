# To arrays  ----------------------------------------------------------------
# aa = iapply
# al -> ll -> la = iapply
# ad -> dl -> la = iapply
# la, da = ?  (but should hopefully match with aggregate)

laply <-  function(data, fun = NULL, ..., .try = FALSE, .quiet = FALSE, .explode = FALSE, .progress = NULL) {
  f <- robustify(fun, .try = .try, .quiet = .quiet, .explode = .explode)
    
  data <- as.list(data)
  res <- llply(data, f, ..., .progress = .progress)
  
  atomic <- sapply(res, is.atomic)
  if (any(!atomic)) stop("Results must be atomic")
  
  dlength <- unique(llply(res, dims))
  if (length(dlength) != 1) stop("Results must have same number of dimensions.")
  
  dims <- unique(do.call("rbind", llply(res, vdim)))
  if (nrow(dims) != 1) stop("Results must have the same dimensions.")
  
  reduce(abind(res, along = 0, force.array = TRUE))
}

daply <- function(data, vars, fun = NULL, ..., .try = FALSE, .quiet = FALSE, .explode = FALSE, .progress = NULL) {
  data <- as.data.frame(data)
  pieces <- splitter_d(data, vars)
  
  laply(pieces, fun, .try = .try, .quiet = .quiet, .explode = .explode, .progress = .progress)
}

aaply <- function(data, margins, fun = NULL, ..., .try = FALSE, .quiet = FALSE, .explode = FALSE, .progress = NULL) {
  pieces <- splitter_a(data, margins)
  
  laply(pieces, fun, .try = .try, .quiet = .quiet, .explode = .explode, .progress = .progress)
}