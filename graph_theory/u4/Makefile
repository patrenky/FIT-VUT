all:
	cp -r ./src/modules ./
	ln -s ./src/evacuation.pl ./evacuation
	ln -s ./src/groups.pl ./groups
	ln -s ./src/parking.pl ./parking
	chmod 755 ./evacuation
	chmod 755 ./groups
	chmod 755 ./parking

clean:
	rm -rf ./modules
	rm -f ./evacuation
	rm -f ./groups
	rm -f ./parking


test:
	make clean
	make all
	chmod 755 ./src/tests/run.pl
	./src/tests/run.pl
