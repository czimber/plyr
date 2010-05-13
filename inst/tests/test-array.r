context("Arrays")

test_that("incorrect result dimensions raise errors", {
  fs <- list(
    function(x) rep(x, sample(10, 1)),
    function(x) if (x < 5) x else matrix(x, 2, 2)
  )
  
  expect_that(laply(1:10, fs[[1]]), throws_error("same dim"))
  expect_that(laply(1:10, fs[[2]]), throws_error("same number"))
})


test_that("simple operations equivalent to vectorised form", {
  expect_that(laply(1:10, mean), is_equivalent_to(1:10))
  expect_that(laply(1:10, sqrt), is_equivalent_to(sqrt(1:10)))
})

test_that("array binding is correct", {
  library(abind)
  f <- function(x) matrix(x, 2, 2)
  m2d <- lapply(1:10, f)
  m3d <- abind(m2d, along = 0)
  
  expect_that(laply(1:10, f), is_equivalent_to(m3d))

  f <- function(x) array(x, c(2, 2, 2))
  m3d <- lapply(1:10, f)
  m4d <- abind(m3d, along = 0)
  
  expect_that(laply(1:10, f), is_equivalent_to(m4d))
})

test_that("idempotent function equivalent to permutation",  {  
  x <- array(1:24, 2:4, 
    dimnames = list(LETTERS[1:2], letters[24:26], letters[1:4]))

  perms <- unique(alply(as.matrix(subset(expand.grid(x=0:3,y=0:3,z=0:3), (x+y+z)>0 & !any(duplicated(setdiff(c(x,y,z), 0))))), 1, function(x) setdiff(x, 0)))

  aperms <- llply(perms, function(perm) aperm(x, unique(c(perm, 1:3))))
  aaplys <- llply(perms, function(perm) aaply(x, perm, identity))

  for(i in seq_along(res_aperm)) {
    expect_that(dim(aaplys[[i]]), equals(dim(aperms[[i]])))
    expect_that(unname(dimnames(aaplys[[i]])), equals(dimnames(aperms[[i]])))
    expect_that(aaplys[[i]], is_equivalent_to(dimnames(aperms[[i]])))
  }

})

# Test contributed by Baptiste Auguie
test_that("single column data frames work when treated as an array", {
  foo <- function(a="a", b="b", c="c", ...){
    paste(a, b, c, sep="")
  }

  df <- data.frame(b=1:2)
  res <- adply(df, 1, splat(foo))
  
  expect_that(res$b, equals(df$b))
  expect_that(as.character(res$V1), equals(c("a1c", "a2c")))
})