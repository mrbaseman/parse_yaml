#!/bin/bash

function parse_yaml {
   local prefix=$2
   local separator=${3:-_}
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=${fs:-$(echo @|tr @ '\034')} i=${i:-  }
   cat $1 | \
   awk -F$fs "{multi=0; 
       if(match(\$0,/$s\|$s\$/)){multi=1; sub(/$s\|$s\$/,\"\");}
       if(match(\$0,/$s>$s\$/)){multi=2; sub(/$s>$s\$/,\"\");}
       while(multi>0){
           str=\$0; gsub(/^$s/,\"\", str);
	   indent=index(\$0,str);
	   indentstr=substr(\$0, 0, indent-1) \"$i\";
	   obuf=\$0;
	   getline;
	   while(index(\$0,indentstr)){
	       obuf=obuf substr(\$0, length(indentstr)+1);
	       if (multi==1){obuf=obuf \"\\\\n\";}
	       if (multi==2){
	           if(match(\$0,/^$s\$/))
		       obuf=obuf \"\\\\n\";
		       else obuf=obuf \" \"; 
	       }
               getline;
	   }
	   sub(/$s\$/,\"\",obuf);
	   print obuf;
	   multi=0;
           if(match(\$0,/$s\|$s\$/)){multi=1; sub(/$s\|$s\$/,\"\");}
           if(match(\$0,/$s>$s\$/)){multi=2; sub(/$s>$s\$/,\"\");}
       }
   print}" | \
   sed -ne "s|$s#[^\"']*||;s|^\([^\"'#]*\)#.*|\1|;t1;t;:1;s|^$s\$||;t2;p;:2;d" | \
   sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1$i- \4|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1$i- \3|;" \
        -e ":2;s|^\($s\)-$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1- [\2]\n\1$i- \3|;t2" \
        -e "s|^\($s\)-$s\[$s\(.*\)$s\]|\1-\n\1$i- \2|;p" | \
   sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1$i\3: \4|;t1" \
        -e "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1$i\2|;" \
        -e ":2;s|^\($s\)\($w\)$s:$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1\2: {\3}\n\1$i\4: \5|;t2" \
        -e "s|^\($s\)\($w\)$s:$s{$s\(.*\)$s}|\1\2:\n\1$i\3|;p" | \
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p;t" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p;t" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|" \
        -e "s|$s\$||p" | \
   awk -F$fs "{
      indent = length(\$1)/length(\"$i\");
      vname[indent] = \$2;
      for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
      if(length(\$2)== 0){  vname[indent]= ++idx[indent] };
      if (length(\$3) > 0) {
         vn=\"\"; for (i=0; i<indent; i++) { vn=(vn)(vname[i])(\"$separator\")}
         printf(\"%s%s%s=\\\"%s\\\"\n\", \"$prefix\",vn, vname[indent], \$3);
      }
   }"
}
