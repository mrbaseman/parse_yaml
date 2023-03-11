#!/bin/bash

#######################################
# Housekeeping
#######################################

# echo an error message before exiting
trap 'if [[ $failure == true ]]; then exit 1; fi' EXIT

#############################
# Helper functions
#############################

function test_variable {
    if [[ -n ${!1} ]]; then
        if [[ -n $2 ]]; then
            if [[ "${!1}" == "$2" ]]; then
                echo -n .
                return 0;
            else
                echo -e "\nIncorrect value for '$1':\n\tExpected: '$2'\n\tReceived: '${!1}'"
                failure=true
                return 1;
            fi
        else
            echo -n .
            return 0;
        fi
    else
        echo "Could not find variable: '$1'"
        failure=true
        return 1;
    fi
}

#############################
# Test Prep
#############################

failure=false

# Get the function
source ../src/parse_yaml.sh

#############################
# Tests
#############################

# ---------------------------
# Test global scalars
# ---------------------------
eval $(parse_yaml fixtures/global_scalars.yml)
test_variable __ " global_quoted_string global_unquoted_string global_unquoted_multistring"
test_variable global_quoted_string "This is a string"
test_variable global_unquoted_string "1.0"
test_variable global_unquoted_multistring "Look Ma, no quotes!"

# ---------------------------
# Test global dictionaries
# ---------------------------
eval $(parse_yaml fixtures/global_dicts.yml)
test_variable __ " global_dictionary global_dictionary_short"

test_variable global_dictionary_ " global_dictionary_item1 global_dictionary_item2 global_dictionary_item3"
test_variable global_dictionary_item1 "Naruto"
test_variable global_dictionary_item2 "Luffy"
test_variable global_dictionary_item3 "Vash the Stampede"

test_variable global_dictionary_short_ " global_dictionary_short_first global_dictionary_short_second"
test_variable global_dictionary_short_first "Lupin III"
test_variable global_dictionary_short_second "Dai"

# ---------------------------
# Test global lists
# ---------------------------
eval $(parse_yaml fixtures/global_lists.yml)
test_variable __ " global_list global_list_short"

test_variable global_list_ " global_list_1 global_list_2 global_list_3"
test_variable global_list_1 "Ichigo"
test_variable global_list_2 "Bankai"
test_variable global_list_3 "Getsuga Tensho"

test_variable global_list_short_ " global_list_short_1 global_list_short_2 global_list_short_3"
test_variable global_list_short_1 "Uchiha Sasuke"
test_variable global_list_short_2 "Kekkei Genkai"
test_variable global_list_short_3 "Sharingan"

# ---------------------------
# Test nested dictionaries
# ---------------------------
eval $(parse_yaml fixtures/nested_dicts.yml)
test_variable __ " global"

test_variable global_ " global_nested_dict global_nested_short"
test_variable global_nested_dict_ " global_nested_dict_next_level"
test_variable global_nested_dict_next_level "Plus Ultra"
test_variable global_nested_short_ " global_nested_short_next_level"
test_variable global_nested_short_next_level "Super Saiyan"

# ---------------------------
# Test nested lists
# ---------------------------
eval $(parse_yaml fixtures/nested_lists.yml)
test_variable __ " global"

test_variable global_ " global_1 global_2"
test_variable global_1_ " global_1_1 global_1_2 global_1_3"
test_variable global_1_1 "one"
test_variable global_1_2 "two"
test_variable global_1_3 "3"
test_variable global_2_ " global_2_1 global_2_2 global_2_3"
test_variable global_2_1 "four"
test_variable global_2_2 "5"
test_variable global_2_3 "six"

# ---------------------------
# Test lists in dictionaries
# ---------------------------
eval $(parse_yaml fixtures/lists_in_dicts.yml)
test_variable __ " dictionary_with_lists"

test_variable dictionary_with_lists_ " dictionary_with_lists_watchlist dictionary_with_lists_watched_list"
test_variable dictionary_with_lists_watchlist_ " dictionary_with_lists_watchlist_1 dictionary_with_lists_watchlist_2 dictionary_with_lists_watchlist_3"
test_variable dictionary_with_lists_watchlist_1 "Eden's Zero"
test_variable dictionary_with_lists_watchlist_2 "Fairy Tail"
test_variable dictionary_with_lists_watchlist_3 "Black Clover"
test_variable dictionary_with_lists_watched_list_ " dictionary_with_lists_watched_list_1 dictionary_with_lists_watched_list_2 dictionary_with_lists_watched_list_3"
test_variable dictionary_with_lists_watched_list_1 "Dragonball Z"
test_variable dictionary_with_lists_watched_list_2 "Hunter x Hunter"
test_variable dictionary_with_lists_watched_list_3 "Naruto"

# ---------------------------
# Test dictionaries in lists
# ---------------------------
eval $(parse_yaml fixtures/dicts_in_lists.yml)
test_variable __ " list_of_dictionaries"

test_variable list_of_dictionaries__ " list_of_dictionaries__1 list_of_dictionaries__2"
test_variable list_of_dictionaries__1_ " list_of_dictionaries__1_item_number list_of_dictionaries__1_first_value list_of_dictionaries__1_second_value"
test_variable list_of_dictionaries__1_item_number "1" 
test_variable list_of_dictionaries__1_first_value "value1"
test_variable list_of_dictionaries__1_second_value "value2"
test_variable list_of_dictionaries__2_ " list_of_dictionaries__2_item_number list_of_dictionaries__2_first_value list_of_dictionaries__2_second_value"
test_variable list_of_dictionaries__2_item_number "2"
test_variable list_of_dictionaries__2_first_value "value1"
test_variable list_of_dictionaries__2_second_value "value 2"

# ---------------------------
# Test unordered sets
# ---------------------------
eval $(parse_yaml fixtures/unordered_sets.yml)
test_variable __ " unordered_set"

test_variable unordered_set_ " unordered_set_1 unordered_set_2 unordered_set_3"
test_variable unordered_set_1 "A"
test_variable unordered_set_2 "B"
test_variable unordered_set_3 "C"

# ---------------------------
# Test anchors
# ---------------------------
eval $(parse_yaml fixtures/anchors.yml)
test_variable __ " global"

test_variable global_ " global_anchor_example global_backref global_short_notation global_first_list global_short_list global_list_of_lists global_random_refs"

test_variable global_anchor_example "some value referenced by an anchor"
test_variable global_backref "some value referenced by an anchor"

test_variable global_short_notation_ " global_short_notation_lower global_short_notation_next"
test_variable global_short_notation_lower "indentation with short notation"
test_variable global_short_notation_next "second entry on lower level"

test_variable global_first_list_ " global_first_list_1 global_first_list_2 global_first_list_3 global_first_list_4"
test_variable global_first_list_1 "item 1"
test_variable global_first_list_2 "item 2"
test_variable global_first_list_3 "..."
test_variable global_first_list_4 "item 2"

test_variable global_short_list_  " global_short_list_1 global_short_list_2"
test_variable global_short_list_1 "first item"
test_variable global_short_list_2 "second item"

test_variable global_list_of_lists_ " global_list_of_lists_1 global_list_of_lists_2"
test_variable global_list_of_lists_1_ " global_list_of_lists_1_1 global_list_of_lists_1_2 global_list_of_lists_1_3 global_list_of_lists_1_4"
test_variable global_list_of_lists_2_ " global_list_of_lists_2_1 global_list_of_lists_2_2"

test_variable global_random_refs_ " global_random_refs_1 global_random_refs_2 global_random_refs_3"
test_variable global_random_refs_1_ " global_random_refs_1_lower global_random_refs_1_next"
test_variable global_random_refs_1_lower "indentation with short notation"
test_variable global_random_refs_1_next "second entry on lower level"
test_variable global_random_refs_2 "item 1"
test_variable global_random_refs_3 "second item"

# ---------------------------
# Test comments
# ---------------------------
eval $(parse_yaml fixtures/comments.yml)
test_variable __ " global"

test_variable global_ " global_thing_1 global_thing_2 global_next_level"
test_variable global_thing_1 "Addams Family" 
test_variable global_thing_2 "Fantastic Four" 
test_variable global_next_level_ " global_next_level_1 global_next_level_2 global_next_level_3" 
test_variable global_next_level_1 "further" 
test_variable global_next_level_2 "and further" 
test_variable global_next_level_3 "down" 

# ---------------------------
# Test long text
# ---------------------------
eval $(parse_yaml fixtures/long_text.yml)
test_variable __ " global"

test_variable global_ " global_text_with_linebreaks global_Without_linebreaks global_plain_multiline global_quoted_multiline"
test_variable global_text_with_linebreaks "this is a multiline text with linebreaks\nthat are reproduced in the value\n inside there may be indentations\nand this continues the previous block text\n"
test_variable global_Without_linebreaks "in this case the line breaks of the multiline text get replaced by space characters \nempty lines with the same indentation start a new paragraph"
test_variable global_plain_multiline "this is a plain multiline folded string value"
test_variable global_quoted_multiline "and another quoted multiline string"

# ---------------------------
# Test everything everywhere all at once
# ---------------------------

eval $(parse_yaml ../src/sample.yml)
test_variable __ " global next_part"

test_variable global_ " global_description global_version global_anchor_example global_next global_upper global_backref global_short_notation global_first_list global_unordered_set global_short_list global_list_of_dictionaries global_text_with_linebreaks global_Without_linebreaks"
test_variable global_description "this is a dictionary entry"
test_variable global_version "1.0"
test_variable global_anchor_example "some value referenced by an anchor"

test_variable global_next "this another string value"
test_variable global_next_ " global_next_lower global_next_unquoted"
test_variable global_next_lower "indentation by two characters start a new level"
test_variable global_next_unquoted "strings can also be written unquoted as plain text"

test_variable global_upper "again on upper level of the dictionary"
test_variable global_backref "some value referenced by an anchor"

test_variable global_short_notation_ " global_short_notation_lower global_short_notation_next"
test_variable global_short_notation_lower "indentation with short notation"
test_variable global_short_notation_next "second entry on lower level"

test_variable global_first_list_ " global_first_list_1 global_first_list_2 global_first_list_3 global_first_list_4"
test_variable global_first_list_1 "item 1"
test_variable global_first_list_2 "item 2"
test_variable global_first_list_3 "..."
test_variable global_first_list_4 "item 2"

test_variable global_unordered_set_ " global_unordered_set_1 global_unordered_set_2 global_unordered_set_3"
test_variable global_unordered_set_1 "A"
test_variable global_unordered_set_2 "B"
test_variable global_unordered_set_3 "C"

test_variable global_short_list_ " global_short_list_1 global_short_list_2"
test_variable global_short_list_1 "first item"
test_variable global_short_list_2 "second item"

test_variable global_list_of_dictionaries_ " global_list_of_dictionaries_1 global_list_of_dictionaries_2 global_list_of_dictionaries_3 global_list_of_dictionaries_4 global_list_of_dictionaries_5 global_list_of_dictionaries_6 global_list_of_dictionaries_7"

test_variable global_list_of_dictionaries_1_ " global_list_of_dictionaries_1_item_number global_list_of_dictionaries_1_first_value global_list_of_dictionaries_1_second_value"
test_variable global_list_of_dictionaries_1_item_number "1"
test_variable global_list_of_dictionaries_1_first_value "value1"
test_variable global_list_of_dictionaries_1_second_value "value2"

test_variable global_list_of_dictionaries_2_ " global_list_of_dictionaries_2_1 global_list_of_dictionaries_2_2 global_list_of_dictionaries_2_3 global_list_of_dictionaries_2_4"
test_variable global_list_of_dictionaries_2_1 "item 1"
test_variable global_list_of_dictionaries_2_2 "item 2"
test_variable global_list_of_dictionaries_2_3 "..."
test_variable global_list_of_dictionaries_2_4 "item 2"

test_variable global_list_of_dictionaries_3_ " global_list_of_dictionaries_3_1 global_list_of_dictionaries_3_2"
test_variable global_list_of_dictionaries_3_1 "first item"
test_variable global_list_of_dictionaries_3_2 "second item"

test_variable global_list_of_dictionaries_4_ " global_list_of_dictionaries_4_item_number global_list_of_dictionaries_4_first_value global_list_of_dictionaries_4_second_value"
test_variable global_list_of_dictionaries_4_item_number "two"
test_variable global_list_of_dictionaries_4_first_value "value 3"
test_variable global_list_of_dictionaries_4_second_value "value 4"

test_variable global_list_of_dictionaries_5_ " global_list_of_dictionaries_5_lower global_list_of_dictionaries_5_next"
test_variable global_list_of_dictionaries_5_lower "indentation with short notation"
test_variable global_list_of_dictionaries_5_next "second entry on lower level"
test_variable global_list_of_dictionaries_6 "value1"
test_variable global_list_of_dictionaries_7 "second item"
test_variable global_text_with_linebreaks "this is a multiline text with linebreaks\nthat are reproduced in the value\n inside there may be indentations\nand this continues the previous block text\n"
test_variable global_Without_linebreaks "in this case the line breaks of the multiline text get replaced by space characters \nempty lines with the same indentation start a new paragraph"

test_variable next_part_ " next_part_decription next_part_plain_multiline next_part_quoted_multiline next_part_list_of_dictionaries"
test_variable next_part_decription "several independent dictionaries may exist in one file"
test_variable next_part_plain_multiline "this is a plain multiline folded string value"
test_variable next_part_quoted_multiline "and another quoted multiline string"

test_variable next_part_list_of_dictionaries_ " next_part_list_of_dictionaries_1 next_part_list_of_dictionaries_2 next_part_list_of_dictionaries_3 next_part_list_of_dictionaries_4 next_part_list_of_dictionaries_5 next_part_list_of_dictionaries_6 next_part_list_of_dictionaries_7"

test_variable next_part_list_of_dictionaries_1_ " next_part_list_of_dictionaries_1_item_number next_part_list_of_dictionaries_1_first_value next_part_list_of_dictionaries_1_second_value"
test_variable next_part_list_of_dictionaries_1_item_number "1"
test_variable next_part_list_of_dictionaries_1_first_value "value1"
test_variable next_part_list_of_dictionaries_1_second_value "value2"

test_variable next_part_list_of_dictionaries_2_ " next_part_list_of_dictionaries_2_1 next_part_list_of_dictionaries_2_2 next_part_list_of_dictionaries_2_3 next_part_list_of_dictionaries_2_4"
test_variable next_part_list_of_dictionaries_2_1 "item 1"
test_variable next_part_list_of_dictionaries_2_2 "item 2"
test_variable next_part_list_of_dictionaries_2_3 "..."
test_variable next_part_list_of_dictionaries_2_4 "item 2"

test_variable next_part_list_of_dictionaries_3_ " next_part_list_of_dictionaries_3_1 next_part_list_of_dictionaries_3_2"
test_variable next_part_list_of_dictionaries_3_1 "first item"
test_variable next_part_list_of_dictionaries_3_2 "second item"

test_variable next_part_list_of_dictionaries_4_ " next_part_list_of_dictionaries_4_item_number next_part_list_of_dictionaries_4_first_value next_part_list_of_dictionaries_4_second_value"
test_variable next_part_list_of_dictionaries_4_first_value "value 3"
test_variable next_part_list_of_dictionaries_4_item_number "two"
test_variable next_part_list_of_dictionaries_4_second_value "value 4"

test_variable next_part_list_of_dictionaries_5_ " next_part_list_of_dictionaries_5_lower next_part_list_of_dictionaries_5_next"
test_variable next_part_list_of_dictionaries_5_lower "indentation with short notation"
test_variable next_part_list_of_dictionaries_5_next "second entry on lower level"

test_variable next_part_list_of_dictionaries_6 "value1"

test_variable next_part_list_of_dictionaries_7 "second item"

echo Done