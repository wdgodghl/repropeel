test "remove irrelevant object fields" {
  let input : Json = { "noise": 1, "keep": { "bug": true, "extra": 2 } }
  let result = @src.reduce(input, 100, fn(candidate) {
    if candidate is { "keep": { "bug": True, .. }, .. } {
      Interesting
    } else {
      Rejected
    }
  })
  assert_true(result.value is { "keep": { "bug": True, .. }, .. })
  assert_true(result.value.stringify().length() < input.stringify().length())
}

test "budget stops attempts" {
  let input : Json = [1, 2, 3, 4]
  let result = @src.reduce(input, 1, fn(_) { Rejected })
  assert_true(result.stats.checks == 1)
  assert_true(result.stats.exhausted)
}

test "empty and scalar inputs remain unchanged" {
  let empty : Json = Json::empty_object()
  let scalar : Json = 7
  assert_true(@src.reduce(empty, 10, fn(_) { Interesting }).value == empty)
  assert_true(@src.reduce(scalar, 10, fn(_) { Interesting }).value == scalar)
}
