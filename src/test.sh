source parse_yaml.sh

yaml1=$(Yaml sample.yml)

key=".global.next.unquoted"

value=$(get_yaml_value "$yaml1" $key)

echo "Value of $key: $value"
