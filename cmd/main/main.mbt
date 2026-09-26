fn usage() -> Unit {
  print_out("ReproPeel — shrink JSON while preserving a user-defined failure")
  print_out("Usage: moon run --target js cmd/main -- INPUT --out OUTPUT [--report REPORT] [--max-checks N] [--timeout-ms N] -- COMMAND ... {candidate} ...")
  print_out("Checker: 0 = target failure persists; 1 = does not; other/timeout = inconclusive.")
}

fn fail(message : String) -> Unit {
  print_err("repropeel: " + message)
  set_exit(2)
}

fn main {
  if arg_count() == 0 || arg(0) == "--help" {
    usage()
    return
  }
  let input = arg(0)
  let mut output = ""
  let mut report = ""
  let mut max_checks = 500
  let mut timeout_ms = 5000
  let mut i = 1
  while i < arg_count() && arg(i) != "--" {
    let flag = arg(i)
    if i + 1 >= arg_count() { fail("missing value for " + flag); return }
    let value = arg(i + 1)
    match flag {
      "--out" => output = value
      "--report" => report = value
      "--max-checks" => max_checks = positive_int(value)
      "--timeout-ms" => timeout_ms = positive_int(value)
      _ => { fail("unknown option " + flag); return }
    }
    i += 2
  }
  if output == "" || max_checks == 0 || timeout_ms == 0 {
    fail("--out and positive numeric limits are required")
    return
  }
  if i >= arg_count() || arg(i) != "--" || i + 1 >= arg_count() {
    fail("provide a checker command after --")
    return
  }
  let exe = arg(i + 1)
  let checker_args : Array[String] = []
  let mut has_placeholder = false
  for j = i + 2; j < arg_count(); j = j + 1 {
    let value = arg(j)
    checker_args.push(value)
    if value == "{candidate}" { has_placeholder = true }
  }
  if !has_placeholder {
    fail("checker arguments must contain {candidate}")
    return
  }
  if report == "" { report = output + ".report.json" }
  if same_path(input, output) || same_path(input, report) || same_path(output, report) {
    fail("input, output and report must use different paths")
    return
  }
  if !is_file(input) || exists(output) || exists(report) {
    fail("input must exist; output and report must not exist")
    return
  }
  let original_text = read_text(input)
  let original = @json.parse(original_text) catch {
    _ => { fail("input is not valid JSON"); return }
  }
  let temp = make_temp()
  let candidate = temp_file(temp)
  let args_json = @json.to_json(checker_args).stringify()
  overwrite_candidate(candidate, original.stringify())
  let baseline = run_checker(exe, args_json, candidate, timeout_ms)
  if baseline != 0 {
    remove_temp(temp)
    fail("baseline did not confirm the target failure (checker exit 0 required)")
    return
  }
  let result = @reducer.reduce(original, max_checks, fn(value) {
    overwrite_candidate(candidate, value.stringify())
    match run_checker(exe, args_json, candidate, timeout_ms) {
      0 => @reducer.Interesting
      1 => @reducer.Rejected
      _ => @reducer.Unresolved
    }
  })
  let final_text = result.value.stringify(indent=2) + "\n"
  overwrite_candidate(candidate, result.value.stringify())
  let verified = run_checker(exe, args_json, candidate, timeout_ms) == 0
  remove_temp(temp)
  if !verified {
    fail("final independent verification failed; no output written")
    return
  }
  write_text(output, final_text)
  write_report(report, input, output, byte_length(original_text), byte_length(final_text),
               result.stats.checks, result.stats.cache_hits, result.stats.unresolved,
               result.stats.accepted, result.stats.exhausted, true)
  print_out("Wrote " + output + " and " + report)
}
