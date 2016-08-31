#!/bin/bash
out="nmrproc.com"
if [ -e ${out} ]; then
	mv ${out} _${out}_
	echo \#!/bin/csh > ${out}
	echo >> ${out}
	for f in $(ls -1 test_*.fid)
	do
		num=$(basename ${f} .fid | cut -d'_' -f2)
		echo nmrPipe -in test_${num}.fid \\ >> ${out}
		sed -n '/-in/,/-out/p' _nmrproc.com_ | sed -n '/-in/!p' | sed -n '/-out/!p'  >> ${out}
		echo -ov -out test_${num}.ft2 >> ${out}
		echo >> ${out}
	done
	rm -f _nmrproc.com_
	chmod +x nmrproc.com
fi
