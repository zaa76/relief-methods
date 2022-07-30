cd /opt
virtualenv --python=/usr/bin/python2 --prompt="(tilestache ENV)" tilestache
sed -i 's/PS1="(tilestache ENV)\${PS1-}"/PS1="\\\[\\033\[1;33m\\\](tilestache ENV)\${PS1-}"/' tilestache/bin/activate
source tilestache/bin/activate	
