all:
	cp -r ./src/modules ./
	ln -s ./src/avltree.pl ./avltree
	ln -s ./src/power.pl ./power
	ln -s ./src/reset.pl ./reset
	ln -s ./src/weakness.pl ./weakness
	chmod 755 ./avltree
	chmod 755 ./power
	chmod 755 ./reset
	chmod 755 ./weakness

clean:
	rm -rf ./modules
	rm -f ./avltree
	rm -f ./power
	rm -f ./reset
	rm -f ./weakness

test:
	make clean
	make all
	chmod 755 ./src/tests/run.pl
	./src/tests/run.pl
