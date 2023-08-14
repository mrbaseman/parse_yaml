# parse_yaml
a simple yaml parser implemented in bash

`parse_yaml` provides a bash function that allows parsing simple YAML files. 
The output is shell code that defines shell variables which contain the parsed values.
`bash` doesn't support multidimensional arrays. Therefore a separate variable is created for each value, and the name of the variable consists of the names of all levels in the yaml file, glued together with a separator character which defaults to `_`.

## Usage
first source the script that defines `parse_yaml`
```
source parse_yaml.sh
```
then, you can parse yaml files and assign shell variables
```
eval $(parse_yaml sample.yml)
```
or postprocess the output by other shell scripts or tools that take their input from stdin
```
parse_yaml sample.yml | some_script
```
also, you can load defaults from one yaml file and overwrite the values with the ones of a specific file
```
eval $(parse_yaml defaults.yml)
eval $(parse_yaml sample.yml)
```
a prefix can be supplied as second argument. This prefix may also be an empty string, which allows you to supply a third argument which changes the separator string (e.g. from underscore to dash):
```
eval $(parse_yaml sample.yml "" "-")
```

## A simple example input file:
```
---
global:
  input:
    - "main.c"
    - "main.h"
  flags: [ "-O3", "-fpic" ]
  sample_input:
    -  { property1: value1, property2: value2 }
    -  { property1: "value 3", property2: 'value 4' }
  licence: |
    this is published under
    open source license
    in the hope that it would 
    be useful
...
```
and here the parsed output:
```
global_input_1="main.c"
global_input_2="main.h"
global_flags_1="-O3"
global_flags_2="-fpic"
global_sample_input_1_property1="value1"
global_sample_input_1_property2="value2"
global_sample_input_2_property1="value 3"
global_sample_input_2_property2="value 4"
global_licence="this is published under\nopen source license\nin the hope that it would \nbe useful\n"
__=" global"
global_=" global_input global_flags global_sample_input global_licence"
global_flags_=" global_flags_1 global_flags_2"
global_input_=" global_input_1 global_input_2"
global_sample_input_=" global_sample_input_1 global_sample_input_2"
global_sample_input_1_=" global_sample_input_1_property1 global_sample_input_1_property2"
global_sample_input_2_=" global_sample_input_2_property1 global_sample_input_2_property2"
```
Apart from the values themselves, there are also lists of the variable names that live below each level (for instance `$global_flags_` contains two variable names, `global_flags_1` and `global_flags_2`. These names can be used to iterate over all members of `$global_flags`:
```
for f in $global_flags_ ; do eval echo \$f \$${f} ; done
```
produces the following output
```
global_flags_1 -O3
global_flags_2 -fpic
```

For more examples see the sample.yml file included in the src directory.

## Using `get_yaml_value` Function

You can use the `get_yaml_value` function to retrieve a specific value from the YAML file. Here's an example of how to use it:

First, source the `parse_yaml.sh` script:

```bash
source parse_yaml.sh
```

Then, parse the YAML file and store the result in a variable:

```bash
yaml1=$(Yaml sample.yml)
```

Define the key you want to retrieve, using dots to separate the levels:

```bash
key=".global.next.unquoted"
```

Use the `get_yaml_value` function to get the value for the specified key:

```bash
value=$(get_yaml_value "$yaml1" $key)
```

Finally, you can print the value:

```bash
echo "Value of $key: $value"
```

## Features
The following yaml features are currently supported:

* comments (`# comment`)
* dictionaries, mappings or collections (`key: value`) with indentation to denote the level
* short notation of ditctionaries (` dict: { key: value, ... }`)
* lists or sequences (`- entry`) with indentation to denote the level
* short notation of lists (`list: [ value, ... ]`)
* unordered lists or sometimes called sets (`? entry`)
* values may be single words (i.e. containing only alphanumeric characters)
* values (strings) can be enclosed in single or double quotes
* multiline values (`multiline: | ...`) where the following lines are indented one level deeper than the key
* wrapped content (`wrapped: > ...`)  where line breaks are converted to spaces and empty lines to newlines
* plain and quoted multiline flow scalars are supported ( `key: ...` where `...` is a quoted or unquoted string that may span multiple lines).
* anchors (`&anchor`) and references to them (`*anchor`) are supported, to some extend even in a nested way


## Known limitations

* special characters are interpreted by the bash. Backticks `\`...\`` and expressions starting with `$` which trigger command substitution or parameter expansion may cause unwanted effects - use with caution!
* directives and document boundaries (`---`, `...`) are simply ignored
* the parsed data is put into shell variables and thus multidimensional arrays can not be used. For each value on each level a separate shell variable is defined.
* comments may not be correctly filtered out if quotes are used on the same line inside and outside of the comment
* yaml tags (`!tag`) and types (`!!type`), especially `!!binary` are not supported.
* complex mapping keys (e.g. sequences as an index of a mapping) are not supported
* unordered lists are converted to ordered lists for simplicity
* strings enclosed in quotes should work, but when double- and single quotes are nested in a too complex manner, the regex used for parsing might not correctly capture the value
* multiple quotes inside a string are not correctly "unfolded". Two subsequent single quotes in a string enclosed by single quotes should become one single quote. There might also be problems with quotes masked by backslash in a quoted string.
* plain and quoted multi-line flow scalars produce output for each line to be appended
* anchors are not fully dereferenced twice, i.e. when an anchor is defined and it contains references to other anchors, those are dereferenced when the anchor is processed. If those anchors are re-defined later on, and the main anchor that contains the references on the re-defined anchors, is later dereferenced, it still contains the outdated values.
* if a quoted string starts with a `'*'` character and an anchor exists which is denoted by the following characters in the string, this is currently treated as a dereference, even if the string is enclosed in single quotes

## credits: 
this work is based on Stefan Farestam's [answer on stackoverflow](https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script)
