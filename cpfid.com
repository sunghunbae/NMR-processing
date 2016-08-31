#!/bin/csh
if (-e fid.com) then
	mv fid.com _fid.com_
	echo -n "#"	> fid.com
	echo -n "!" >> fid.com
	echo "/bin/csh" >> fid.com
	set FIDS = `ls -1 fid_*`
	foreach f ($FIDS)
		set num = `echo $f |cut -d'_' -f2`
		awk '/^[^#]/ {print $0}' _fid.com_ |	\
		sed -e "s/\.\/fid/\.\/fid_${num}/g" |  \
		sed -e "s/\.\/test\.fid/\.\/test_${num}\.fid/g" >> fid.com
	end
	rm -f _fid.com_
	chmod +x fid.com
endif
./fid.com
