#!/usr/bin/zsh
# Isolated completion tests. Run from the repo root:
#   zsh test/completions.zsh

emulate -L zsh
setopt no_unset

fail() {
  print -u2 "not ok - $1"
  [[ -n ${2:-} ]] && print -u2 "    $2"
  exit 1
}

pass() {
  print "ok - $1"
}

assert_contains() {
  local needle="$1" haystack="$2" label="$3"
  [[ " $haystack " == *" $needle "* ]] || fail "$label" "expected '$needle' in: $haystack"
}

assert_missing() {
  local needle="$1" haystack="$2" label="$3"
  [[ " $haystack " != *" $needle "* ]] || fail "$label" "did not expect '$needle' in: $haystack"
}

ROOT="${0:A:h:h}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

BIN="$TMP/bin"
mkdir -p "$BIN"

write_cmd() {
  local name="$1" summary="$2" args="${3:-}"
  {
    print '#!/bin/bash'
    print "# omarchy:summary=$summary"
    [[ -n $args ]] && print "# omarchy:args=$args"
    print 'exit 0'
  } >"$BIN/$name"
  chmod +x "$BIN/$name"
}

write_cmd omarchy "Command center"
write_cmd omarchy-theme "Theme management"
write_cmd omarchy-theme-set "Apply a theme" "<name>"
write_cmd omarchy-theme-list "List available themes"
write_cmd omarchy-channel "Release channel management"
write_cmd omarchy-channel-set "Set the release channel" "<stable|rc|edge|dev>"
write_cmd omarchy-capture "Screenshots and screen recording"
write_cmd omarchy-capture-screenshot "Take a screenshot" "[smart|region|windows|fullscreen] [slurp|copy|save] [--editor=<name>]"
write_cmd omarchy-bar "Omarchy shell bar layout and settings" "use <id> | reset | defaults | position <top|bottom|left|right>"
write_cmd omarchy-hw-match "Match DMI product name" "<pattern>"

path=("$BIN" $path)

_describe() { : }
_files() { : }

_omarchy_skip_invoke=1
source "$ROOT/shell/completions/_omarchy"

complete_at() {
  words=("$@")
  CURRENT=$#words
  _omarchy_used_files=0
  _omarchy
  got="${_omarchy_matches[*]}"
}

# --- subcommands ---

complete_at omarchy ""
assert_contains theme "$got" "top-level includes theme"
assert_contains channel "$got" "top-level includes channel"
assert_contains capture "$got" "top-level includes capture"
assert_contains commands "$got" "top-level includes commands"
assert_contains bar "$got" "top-level includes bar"
pass "top-level subcommands"

complete_at omarchy th
assert_contains theme "$got" "partial current word still lists theme"
pass "partial top-level prefix"

complete_at omarchy theme ""
assert_contains set "$got" "theme set"
assert_contains list "$got" "theme list"
assert_missing commands "$got" "commands is only at the top level"
pass "theme subcommands"

# --- commands flags (dropped in 4f79a29; restored) ---

complete_at omarchy commands ""
assert_contains --all "$got" "commands --all"
assert_contains --json "$got" "commands --json"
assert_contains --markdown "$got" "commands --markdown"
assert_contains --check "$got" "commands --check"
pass "omarchy commands flags"

# --- # omarchy:args= alternatives ---

complete_at omarchy channel set ""
assert_contains stable "$got" "channel set stable"
assert_contains rc "$got" "channel set rc"
assert_contains edge "$got" "channel set edge"
assert_contains dev "$got" "channel set dev"
pass "channel set args"

complete_at omarchy capture screenshot ""
assert_contains smart "$got" "screenshot smart"
assert_contains region "$got" "screenshot region"
assert_contains windows "$got" "screenshot windows"
assert_contains fullscreen "$got" "screenshot fullscreen"
pass "screenshot first-arg alts"

complete_at omarchy capture screenshot region ""
assert_contains slurp "$got" "screenshot second-arg slurp"
assert_contains copy "$got" "screenshot second-arg copy"
assert_contains save "$got" "screenshot second-arg save"
pass "screenshot second-arg alts"

complete_at omarchy bar ""
assert_contains use "$got" "bar use"
assert_contains reset "$got" "bar reset"
assert_contains defaults "$got" "bar defaults"
assert_contains position "$got" "bar position"
pass "bar alt-list literals"

complete_at omarchy bar position ""
assert_contains top "$got" "bar position top"
assert_contains bottom "$got" "bar position bottom"
assert_contains left "$got" "bar position left"
assert_contains right "$got" "bar position right"
pass "bar position enum"

# --- file fallback for untyped placeholders ---

complete_at omarchy hw match ""
[[ -z $got ]] || fail "hw match has no enum candidates" "got: $got"
(( _omarchy_used_files == 1 )) || fail "hw match falls back to files"
pass "placeholder args fall back to files"

complete_at omarchy theme set ""
[[ -z $got ]] || fail "theme set <name> has no enum candidates" "got: $got"
(( _omarchy_used_files == 1 )) || fail "theme set falls back to files"
pass "name placeholders fall back to files"

print "all tests passed"
