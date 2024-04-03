# Checks the current entry to see if it matches the given exclude
def matches($entry; $exclude):
  all($exclude | to_entries | .[]; $entry[.key] == .value);

def filter_excludes($entry; $excludes):
  select(any($excludes[]; matches($entry; .)) | not);

def lists2dict($keys; $values):
  reduce range($keys | length) as $ind ({}; . + {($keys[$ind]): $values[$ind]});

def compute_runner_label($entry):
  if $entry.ENV == "aws" then
    $entry + {"RUNNER_LABEL": "ubuntu-latest"}
  elif $entry.ARCH == "amd64" then
    $entry + {"RUNNER_LABEL": "linux-amd64-cpu4-testing"}
  elif $entry.ARCH == "arm64" then
    $entry + {"RUNNER_LABEL": "linux-arm64-cpu4-testing"}
  else
    "Unable to compute runner label\n" | halt_error
  end;

def compute_matrix($matrix):
  ($matrix.exclude // []) as $excludes |
  $matrix | del(.exclude) |
  keys_unsorted as $matrix_keys |
  to_entries |
  map(.value) |
  [
    combinations |
    lists2dict($matrix_keys; .) |
    filter_excludes(.; $excludes) |
    compute_runner_label(.)
  ] |
  {include: .};
