# Checks the current entry to see if it matches the given exclude
def matches($entry; $exclude):
  all($exclude | to_entries | .[]; $entry[.key] == .value);

def filter_excludes($entry; $excludes):
  select(any($excludes[]; matches($entry; .)) | not);

def lists2dict($keys; $values):
  reduce range($keys | length) as $ind ({}; . + {($keys[$ind]): $values[$ind]});

def add_config($entry; $config):
  $entry + $config[$entry.ENV];

def compute_matrix($matrix; $config):
  ($matrix.exclude // []) as $excludes |
  $matrix | del(.exclude) |
  keys_unsorted as $matrix_keys |
  to_entries |
  map(.value) |
  [
    combinations |
    lists2dict($matrix_keys; .) |
    filter_excludes(.; $excludes) |
    add_config(.; $config)
  ] |
  {include: .};
