WEB=/Volumes/fsv.kochi-tech.ac.jp/public_html/kut-local/modelcheck

sat-tutorial.html: sat-tutorial.md style.css
	pandoc -c style.css -s $< -o $@

putweb:
	cp sat-tutorial.md   $(WEB)/sat-tutorial.md.txt
	cp sat-tutorial.html $(WEB)/
	cp style.css         $(WEB)/
	cp sudoku-z3.smt     $(WEB)/sudoku-z3.smt.txt
