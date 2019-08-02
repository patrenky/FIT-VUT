all:
	cp -r ./src/modules ./
	ln -s ./src/car.pl ./car
	ln -s ./src/server.pl ./server
	ln -s ./src/race.pl ./race
	chmod 755 ./car
	chmod 755 ./server
	chmod 755 ./race

clean:
	rm -rf ./modules
	rm -f ./car
	rm -f ./server
	rm -f ./race


test:
	make clean
	make all
	chmod 755 ./src/tests/run.pl
	./src/tests/run.pl
