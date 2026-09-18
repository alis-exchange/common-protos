#!/usr/bin/env bash
# Reports where the vendored upstream protos have drifted from their sources.
#
# Only package directories that already exist here are compared: a file is
# "added upstream" only when it appears in one of those directories, and
# upstream packages this repo does not vendor are ignored.
#
# Files are classified by their compiled descriptors, so comment, copyright and
# formatting changes are listed as text only instead of counting as drift.
#
# Usage:  .github/scripts/upstream-drift.sh [report.md]
# Exit:   0 no drift, 1 drift found, 2 the check itself failed.
# Needs:  bash 4+, git, buf, jq.
set -euo pipefail
export LC_ALL=C

# local prefix | GitHub repo | branch | directory in that repo mapped onto the prefix
SOURCES=(
  "google|googleapis/googleapis|master|google"
  "lf/a2a/v1|a2aproject/A2A|main|specification"
)

# Descriptor fields ignored when comparing, as "file|field path"; "*" matches
# every file.
IGNORED=(
  # A no-op since protobuf 3.14, and upstream is deleting it file by file.
  "*|options.ccEnableArenas"
  # Deliberate local edit: points go_package at the published a2a-go module (c0fcdc4).
  "lf/a2a/v1/a2a.proto|options.goPackage"
)

trap 'echo "upstream-drift: failed at line $LINENO" >&2; exit 2' ERR

root=$(git rev-parse --show-toplevel)
report=${1:-/dev/stdout}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/local" "$work/upstream" "$work/src"

# Copies the .proto files under $2/$1 into $3/$4, keeping the layout.
copy_protos() {
  local from=$1 base=$2 dest=$3 to=$4
  mkdir -p "$dest/$to"
  (cd "$base/$from" && find . -name '*.proto' -print0 | tar --null -cf - -T -) | tar -xf - -C "$dest/$to"
}

sources_md=""
declare -A source_sha=()
for source in "${SOURCES[@]}"; do
  IFS='|' read -r prefix repo branch updir <<<"$source"
  checkout="$work/src/${repo//\//_}"

  # A shallow, blobless, sparse clone downloads only the repo's .proto files.
  if [[ ! -d $checkout ]]; then
    git clone --quiet --depth 1 --filter=blob:none --no-checkout --branch "$branch" \
      "https://github.com/$repo.git" "$checkout"
    git -C "$checkout" sparse-checkout set --no-cone '/**/*.proto'
    git -C "$checkout" checkout --quiet
  fi
  sha=$(git -C "$checkout" rev-parse --short=12 HEAD)
  source_sha[$prefix]=$sha
  sources_md+="- \`$prefix/\` ← [$repo@$sha](https://github.com/$repo/tree/$sha/$updir)"$'\n'

  copy_protos "$prefix" "$root" "$work/local" "$prefix"
  # The whole mapped directory is copied, not only the packages compared, so
  # upstream files compile against upstream imports (lf/ imports google/).
  copy_protos "$updir" "$checkout" "$work/upstream" "$prefix"
done

printf 'version: v2\n' >"$work/local/buf.yaml"
printf 'version: v2\n' >"$work/upstream/buf.yaml"

changed=() added=() removed=() text_only=() candidates=()
for source in "${SOURCES[@]}"; do
  IFS='|' read -r prefix _ _ _ <<<"$source"
  while read -r dir; do
    local_files=$(cd "$work/local/$dir" && ls -1 -- *.proto | sort)
    upstream_files=$(cd "$work/upstream/$dir" 2>/dev/null && ls -1 -- *.proto 2>/dev/null | sort || true)
    while read -r f; do [[ -z $f ]] || added+=("$dir/$f"); done \
      < <(comm -13 <(echo "$local_files") <(echo "$upstream_files"))
    while read -r f; do [[ -z $f ]] || removed+=("$dir/$f"); done \
      < <(comm -23 <(echo "$local_files") <(echo "$upstream_files"))
    while read -r f; do
      [[ -z $f ]] && continue
      cmp -s "$work/local/$dir/$f" "$work/upstream/$dir/$f" || candidates+=("$dir/$f")
    done < <(comm -12 <(echo "$local_files") <(echo "$upstream_files"))
  done < <(cd "$work/local" && find "$prefix" -name '*.proto' -exec dirname {} \; | sort -u)
done

# Summarizes how each file's upstream descriptor differs from the local one:
# options, imports, and which messages, enums, services and extensions were
# added (+), removed (−) or changed (~). An empty summary means no difference.
read -r -d '' SUMMARIZE <<'JQ' || true
def byname: (. // []) | map({key: .name, value: .}) | from_entries;
def snake: gsub("(?<c>[A-Z])"; "_" + (.c | ascii_downcase));
def show: if . == null then "unset" else tojson end;
def delta(l; u; inner):
  (l | byname) as $l | (u | byname) as $u
  | [(($u | keys) - ($l | keys))[] | "+\(.)"]
    + [(($l | keys) - ($u | keys))[] | "−\(.)"]
    + [($l | keys)[] as $k | select($u[$k] != null and $l[$k] != $u[$k])
        | ([delta($l[$k] | inner; $u[$k] | inner; empty)] | add // []) as $d
        | "~\($k)" + (if ($d | length) > 0 then " (\($d | join(", ")))" else "" end)];
def section(title; items): if (items | length) > 0 then "\(title) \(items | join(", "))" else empty end;
def normalize($ov): .name as $n
  | reduce ($ov[] | select(.file == "*" or .file == $n) | .path) as $p (.; delpaths([$p]))
  | del(.bufExtension);
($l[0].file | map(normalize($ov)) | byname) as $L
| ($u[0].file | map(normalize($ov)) | byname) as $U
| $L | keys[] as $n | $L[$n] as $a | $U[$n] as $b
| [
    section("options:"; [(($a.options // {}) + ($b.options // {}) | keys[]) as $k
      | select($a.options[$k] != $b.options[$k])
      | "`\($k | snake)` \($a.options[$k] | show) → \($b.options[$k] | show)"]),
    section("imports:"; [(($b.dependency // []) - ($a.dependency // []))[] | "+`\(.)`"]
      + [(($a.dependency // []) - ($b.dependency // []))[] | "−`\(.)`"]),
    section("messages:"; delta($a.messageType; $b.messageType; .field)),
    section("enums:"; delta($a.enumType; $b.enumType; .value)),
    section("services:"; delta($a.service; $b.service; .method)),
    section("extensions:"; delta($a.extension; $b.extension; empty)),
    ([($a + $b | keys[]) as $k
      | select(["name", "options", "dependency", "messageType", "enumType", "service", "extension"] | index($k) | not)
      | select($a[$k] != $b[$k]) | "`\($k | snake)` changed"] | if length > 0 then join(", ") else empty end)
  ] as $parts
| "\($n)\t\($parts | join("; "))"
JQ

declare -A summary=()
if ((${#candidates[@]})); then
  ignored_json=$(printf '%s\n' "${IGNORED[@]}" | jq -R 'split("|") | {file: .[0], path: (.[1] | split("."))}' | jq -s .)
  paths=()
  for f in "${candidates[@]}"; do paths+=(--path "$f"); done

  # Source info is dropped so comments and positions do not affect the result.
  for side in local upstream; do
    (cd "$work/$side" && buf build --exclude-source-info --exclude-imports "${paths[@]}" -o "$work/$side.json")
  done

  # Written to a file first: a failure inside a process substitution would go
  # unnoticed and read as "no drift".
  jq -rn --argjson ov "$ignored_json" --slurpfile l "$work/local.json" --slurpfile u "$work/upstream.json" \
    "$SUMMARIZE" >"$work/summary.tsv"
  while IFS=$'\t' read -r name text; do
    if [[ -z $text ]]; then text_only+=("$name"); else changed+=("$name"); summary[$name]=$text; fi
  done <"$work/summary.tsv"
fi

# Prints the GitHub URL of a local file's upstream counterpart.
upstream_url() {
  local file=$1 source prefix repo updir
  for source in "${SOURCES[@]}"; do
    IFS='|' read -r prefix repo _ updir <<<"$source"
    if [[ $file == "$prefix"/* ]]; then
      echo "https://github.com/$repo/blob/${source_sha[$prefix]}/$updir/${file#"$prefix"/}"
      return
    fi
  done
}

list_md() {
  local f
  for f in "$@"; do printf -- '- [`%s`](%s)\n' "$f" "$(upstream_url "$f")"; done
}

{
  echo "## Upstream proto drift"
  echo
  echo "Compared against:"
  echo
  printf '%s' "$sources_md"
  echo
  echo "**${#changed[@]} changed · ${#added[@]} added upstream · ${#removed[@]} removed upstream** · ${#text_only[@]} text only (not counted)"

  if ((${#changed[@]})); then
    echo
    echo "### Definitions changed"
    echo
    echo "Local → upstream. \`+\` added, \`−\` removed, \`~\` changed."
    echo
    for f in "${changed[@]}"; do
      printf -- '- [`%s`](%s): %s\n' "$f" "$(upstream_url "$f")" "${summary[$f]}"
    done
  fi
  if ((${#added[@]})); then
    echo
    echo "### Added upstream"
    echo
    echo "New files in packages vendored here."
    echo
    list_md "${added[@]}"
  fi
  if ((${#removed[@]})); then
    echo
    echo "### Removed upstream"
    echo
    for f in "${removed[@]}"; do printf -- '- `%s`\n' "$f"; done
  fi
  if ((${#text_only[@]})); then
    echo
    echo "### Text only"
    echo
    echo "Only comments, formatting or ignored fields differ. Not counted as drift."
    echo
    echo "<details><summary>${#text_only[@]} files</summary>"
    echo
    list_md "${text_only[@]}"
    echo
    echo "</details>"
  fi
  echo
  echo "Reproduce locally with \`.github/scripts/upstream-drift.sh\`."
} >"$report"

trap - ERR
((${#changed[@]} + ${#added[@]} + ${#removed[@]} == 0))
