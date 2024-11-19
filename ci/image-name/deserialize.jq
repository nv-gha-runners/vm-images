def pick_from_list($values; $required_field):
    .[0] as $value |
    if $values | any(. == $value) then
        {"value": $value, "rest": .[1:]}
    elif $required_field != "" then
        "Error: \($required_field) field is required\n" | halt_error
    else
        {"value": null, "rest": .}
    end;

def deserialize_image_name($matrix):
    split("-") |
    pick_from_list($matrix.OS; "OS") | .value as $os | .rest |
    pick_from_list(["cpu", "gpu"]; "variant") | .value as $variant | .rest |
    pick_from_list($matrix.DRIVER_VERSION; "") | .value as $driver_version | .rest |
    pick_from_list($matrix.DRIVER_FLAVOR; "") | .value as $driver_flavor | .rest |
    pick_from_list($matrix.ARCH; "arch") | .value as $arch | .rest |
    (if any then join("-") else null end) as $branch_name |
    {
        "os": $os,
        "variant": $variant,
        "driver_version": $driver_version,
        "driver_flavor": $driver_flavor,
        "arch": $arch,
        "branch_name": $branch_name
    };

def deserialize_image_name:
    . as $input | env.MATRIX | fromjson as $matrix | $input | deserialize_image_name($matrix);
