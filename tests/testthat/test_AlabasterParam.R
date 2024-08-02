test_that("AlabasterParam works", {
    res <- AlabasterParam()
    expect_s4_class(res, "AlabasterParam")
    expect_true(length(res@path) == 1L)

    res <- AlabasterParam("test")
    expect_equal(res@path, "test")

    expect_error(AlabasterParam(c("a", "b")), "length 1")
})
