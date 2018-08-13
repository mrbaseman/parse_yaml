#!/bin/bash

function parse_yaml {
   local prefix=$2
   local separator=${3:-_}
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=${fs:-$(echo @|tr @ '\034')}
   cat $1 | \
   awk -F$fs "{if(match(\$0,/$s\|$s/)){
           sub(/$s\|$s/,\"\");
           str=\$0; gsub(/^$s/,\"\", str);
	   indent=index(\$0,str);
	   indentstr=substr(\$0, 0, indent-1) \"  \";
	   obuf=\$0;
	   getline;
	   while(index(\$0,indentstr)){
	      obuf=obuf substr(\$0, length(indentstr)+1) \"\\\\n\";
              getline;
	   }
	   sub(/\\\\n\$/,\"\",obuf);
	   print obuf;
       }
   print}" | \
   sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1  - \4|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1  - \3|;" \
        -e ":2;s|^\($s\)-$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1- [\2]\n\1  - \3|;t2" \
        -e "s|^\($s\)-$s\[$s\(.*\)$s\]|\1-\n\1  - \2|;p" | \
   sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1  \3: \4|;t1" \
        -e "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1  \2|;" \
        -e ":2;s|^\($s\)\($w\)$s:$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1\2: {\3}\n\1  \4: \5|;t2" \
        -e "s|^\($s\)\($w\)$s:$s{$s\(.*\)$s}|\1\2:\n\1  \3|;p" | \
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p;t" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p;t" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|" \
        -e "s|$s\$||p" | \
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
      if(length($2)== 0){  vname[indent]= ++idx[indent] };
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) { vn=(vn)(vname[i])("'$separator'")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, vname[indent], $3);
      }
   }'
}
