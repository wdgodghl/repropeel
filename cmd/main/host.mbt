// Node.js is used only for file and child-process access. Shrinking is MoonBit code.
extern "js" fn arg_count() -> Int =
  #|() => process.argv.length - 2

extern "js" fn arg(index : Int) -> String =
  #|(index) => process.argv[index + 2] || ""

extern "js" fn print_out(message : String) -> Unit =
  #|(message) => { process.stdout.write(message + "\n"); }

extern "js" fn print_err(message : String) -> Unit =
  #|(message) => { process.stderr.write(message + "\n"); }

extern "js" fn set_exit(code : Int) -> Unit =
  #|(code) => { process.exitCode = code; }

extern "js" fn positive_int(value : String) -> Int =
  #|(value) => { const n = Number(value); return Number.isSafeInteger(n) && n > 0 && n <= 2147483647 ? n : 0; }

extern "js" fn read_text(path : String) -> String =
  #|(path) => require("node:fs").readFileSync(path, "utf8")

extern "js" fn is_file(path : String) -> Bool =
  #|(path) => { try { return require("node:fs").statSync(path).isFile(); } catch (_) { return false; } }

extern "js" fn exists(path : String) -> Bool =
  #|(path) => require("node:fs").existsSync(path)

extern "js" fn same_path(a : String, b : String) -> Bool =
  #|(a, b) => require("node:path").resolve(a) === require("node:path").resolve(b)

extern "js" fn write_text(path : String, content : String) -> Unit =
  #|(path, content) => require("node:fs").writeFileSync(path, content, { encoding: "utf8", flag: "wx" })

extern "js" fn make_temp() -> String =
  #|() => require("node:fs").mkdtempSync(require("node:path").join(require("node:os").tmpdir(), "repropeel-"))

extern "js" fn remove_temp(dir : String) -> Unit =
  #|(dir) => require("node:fs").rmSync(dir, { recursive: true, force: true })

extern "js" fn temp_file(dir : String) -> String =
  #|(dir) => require("node:path").join(dir, "candidate.json")

extern "js" fn run_checker(exe : String, args_json : String, candidate : String, timeout_ms : Int) -> Int =
  #|(exe, args_json, candidate, timeout_ms) => {
  #|  const fs = require("node:fs");
  #|  const cp = require("node:child_process");
  #|  const args = JSON.parse(args_json).map(x => x === "{candidate}" ? candidate : x);
  #|  if (!args.includes(candidate)) return 3;
  #|  const result = cp.spawnSync(exe, args, { timeout: timeout_ms, shell: false,
  #|    stdio: "ignore", windowsHide: true });
  #|  if (result.error || result.signal) return 3;
  #|  return result.status === 0 ? 0 : result.status === 1 ? 1 : 3;
  #|}

extern "js" fn overwrite_candidate(path : String, content : String) -> Unit =
  #|(path, content) => require("node:fs").writeFileSync(path, content, "utf8")

extern "js" fn write_report(path : String, input : String, output : String, before : Int, after : Int,
                             checks : Int, hits : Int, unresolved : Int, accepted : Int,
                             exhausted : Bool, verified : Bool) -> Unit =
  #|(path, input, output, before, after, checks, hits, unresolved, accepted, exhausted, verified) => {
  #|  const report = { input, output, input_bytes: before, output_bytes: after,
  #|    candidate_checks: checks, cache_hits: hits, unresolved_checks: unresolved,
  #|    accepted_reductions: accepted, budget_exhausted: exhausted, final_verified: verified };
  #|  require("node:fs").writeFileSync(path, JSON.stringify(report, null, 2) + "\n", { flag: "wx" });
  #|}

extern "js" fn byte_length(value : String) -> Int =
  #|(value) => Buffer.byteLength(value, "utf8")
