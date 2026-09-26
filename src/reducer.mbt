/// A checker must reserve exit code 0 for the *same* target failure.
pub(all) enum Verdict {
  Interesting
  Rejected
  Unresolved
} derive(Show, Eq)

pub struct Stats {
  mut checks : Int
  mut cache_hits : Int
  mut unresolved : Int
  mut accepted : Int
  mut exhausted : Bool
}

pub struct Result {
  value : Json
  stats : Stats
}

struct State {
  mut current : Json
  checker : (Json) -> Verdict
  cache : Map[String, Verdict]
  limit : Int
  stats : Stats
}

/// Serialized length is the optimization metric. Equal-sized candidates are skipped.
fn size(value : Json) -> Int {
  value.stringify().length()
}

fn check(state : State, candidate : Json) -> Bool {
  if size(candidate) >= size(state.current) {
    return false
  }
  let key = candidate.stringify()
  match state.cache.get(key) {
    Some(Interesting) => {
      state.stats.cache_hits += 1
      state.current = candidate
      state.stats.accepted += 1
      true
    }
    Some(_) => {
      state.stats.cache_hits += 1
      false
    }
    None => {
      if state.stats.checks >= state.limit {
        state.stats.exhausted = true
        return false
      }
      state.stats.checks += 1
      let verdict = (state.checker)(candidate)
      state.cache.set(key, verdict)
      match verdict {
        Interesting => {
          state.current = candidate
          state.stats.accepted += 1
          true
        }
        Unresolved => {
          state.stats.unresolved += 1
          false
        }
        Rejected => false
      }
    }
  }
}

/// Rebuild a value at a path. Paths are freshly enumerated after each deletion.
fn replace_at(value : Json, path : Array[Int], replacement : Json) -> Json {
  if path.length() == 0 {
    return replacement
  }
  match value {
    Array(items) => {
      let next : Array[Json] = []
      let rest : Array[Int] = []
      for i = 1; i < path.length(); i = i + 1 { rest.push(path[i]) }
      for i = 0; i < items.length(); i = i + 1 {
        if i == path[0] {
          next.push(replace_at(items[i], rest, replacement))
        } else {
          next.push(items[i])
        }
      }
      Array(next)
    }
    Object(fields) => {
      let next : Map[String, Json] = {}
      let rest : Array[Int] = []
      for j = 1; j < path.length(); j = j + 1 { rest.push(path[j]) }
      let mut i = 0
      for key, item in fields {
        if i == path[0] {
          next.set(key, replace_at(item, rest, replacement))
        } else {
          next.set(key, item)
        }
        i += 1
      }
      Object(next)
    }
    _ => value
  }
}

fn at(value : Json, path : Array[Int]) -> Json {
  let mut item = value
  for index in path {
    match item {
      Array(items) => item = items[index]
      Object(fields) => {
        let mut i = 0
        for _, child in fields {
          if i == index { item = child }
          i += 1
        }
      }
      _ => ()
    }
  }
  item
}

fn remove_chunk(value : Json, start : Int, end : Int) -> Json {
  match value {
    Array(items) => {
      let next : Array[Json] = []
      for i = 0; i < items.length(); i = i + 1 {
        if i < start || i >= end { next.push(items[i]) }
      }
      Array(next)
    }
    Object(fields) => {
      let next : Map[String, Json] = {}
      let mut i = 0
      for key, item in fields {
        if i < start || i >= end { next.set(key, item) }
        i += 1
      }
      Object(next)
    }
    _ => value
  }
}

fn children(value : Json) -> Int {
  match value {
    Array(items) => items.length()
    Object(fields) => {
      let mut count = 0
      for _, _ in fields { count += 1 }
      count
    }
    _ => 0
  }
}

/// Delta-debug direct children, then visit the remaining nested containers.
fn peel(state : State, path : Array[Int]) -> Unit {
  let mut granularity = 2
  while !state.stats.exhausted {
    let value = at(state.current, path)
    let count = children(value)
    if count == 0 { break }
    let chunk = (count + granularity - 1) / granularity
    let mut removed = false
    let mut start = 0
    while start < count && !state.stats.exhausted {
      let end = if start + chunk > count { count } else { start + chunk }
      let reduced = remove_chunk(value, start, end)
      let candidate = replace_at(state.current, path, reduced)
      if check(state, candidate) {
        removed = true
        break
      }
      start = end
    }
    if removed {
      granularity = if granularity > 2 { granularity - 1 } else { 2 }
    } else if granularity >= count {
      break
    } else {
      granularity = if granularity * 2 > count { count } else { granularity * 2 }
    }
  }
  let count = children(at(state.current, path))
  for i = 0; i < count; i = i + 1 {
    if state.stats.exhausted { break }
    let child_path : Array[Int] = []
    for index in path { child_path.push(index) }
    child_path.push(i)
    peel(state, child_path)
  }
}

/// Baseline checking and final independent verification are the CLI's responsibility.
pub fn reduce(input : Json, max_checks : Int, checker : (Json) -> Verdict) -> Result {
  let stats = Stats::{ checks: 0, cache_hits: 0, unresolved: 0, accepted: 0, exhausted: false }
  let state = State::{ current: input, checker, cache: {}, limit: max_checks, stats }
  peel(state, [])
  Result::{ value: state.current, stats }
}
