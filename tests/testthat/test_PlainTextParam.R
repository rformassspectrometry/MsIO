test_that("PlainTextParam works", {
    expect_equal(PlainTextParam(), new("PlainTextParam", path = tempdir()))
    expect_s4_class(PlainTextParam(), "PlainTextParam")
})

test_that(".check_directory_content works", {
    expect_error(.check_directory_content(tempdir(), "does_not_ExiSt"),
                 "not found")
})
