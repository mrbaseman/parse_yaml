# parse_yaml
a simple yaml parser implemented in bash

`parse_yaml` provides a bash function that allows parsing simple YAML files. 
The output is shell code that defines shell variables which contain the parsed values.
`bash` doesn't support multidimensional arrays. Therefore a separate variable is created for each value, and the name of the variable consists of the names of all levels in the yaml file, glued together with `_` as a separator character.

## A simple example input file:
```
global:
  input:
    - "main.c"
    - "main.h"
  flags: [ "-O3", "-fpic" ]
  sample_input:
    -  { property1: value1, property2: value2 }
    -  { property1: "value 3", property2: 'value 4' }
```
and here the parsed output:
```
global_input_1="main.c"
global_input_2="main.h"
global_flags_1="-O3"
global_flags_2="-fpic"
global_sample_input_1_property1="value1"
global_sample_input_1_property2="value2 "
global_sample_input_2_property1="value 3"
global_sample_input_2_property2="value 4"
```
## credits: 
this work is based on Stefan Farestam's [answer on stackoverflow](https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script)
