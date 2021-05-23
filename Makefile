# Signifies our desired python version
# Makefile macros (or variables) are defined a little bit differently than traditional bash, keep in mind that in the Makefile there's top-level Makefile-only syntax, and everything else is bash script syntax.
PYTHON = python3

script = $(CURDIR)/duptime
service = $(CURDIR)/duptime.service
log = $(CURDIR)/logs.txt
collector = $(CURDIR)/duptime-collector

SCRIPTDEST = /usr/bin
SERVICEDEST = /etc/systemd/system
LOGDEST = /var/log/duptime
COLLECTORDEST = /usr/local/bin

# .PHONY defines parts of the makefile that are not dependant on any specific file
# This is most often used to store functions
.PHONY = help setup test run clean

# Defining an array variable
FILES = input output

# Defines the default target that `make` will to try to make, or in the case of a phony target, execute the specified commands
# This target is executed whenever we just type `make`
.DEFAULT_GOAL = help

# The @ makes sure that the command itself isn't echoed in the terminal
help:
	@echo "---------------HELP-----------------"
	@echo "To install the project type make install"
	@echo "To remove the project type make remove"
	@echo "To test the project type make test"
	@echo "To run the project type make run"
	@echo "------------------------------------"

# This generates the desired project file structure
# A very important thing to note is that macros (or makefile variables) are referenced in the target's code with a single dollar sign ${}, but all script variables are referenced with two dollar signs $${}
install: $(service) $(script) $(log) $(collector)
	mkdir -p $(LOGDEST)
	install -m 777 $(service) $(SERVICEDEST)
	install -m 777 $(log) $(LOGDEST)
	install -m 777 $(collector) $(COLLECTORDEST)
	install -m 777 $(script) $(SCRIPTDEST)
	systemctl daemon-reload
	systemctl start duptime.service
	systemctl enable duptime.service
# The ${} notation is specific to the make syntax and is very similar to bash's $() 
# This function uses pytest to test our source files
test:
	${PYTHON} -m pytest
	
run:
	${PYTHON} our_app.py
remove:
	@echo "Removing ...."
	rm /usr/local/bin/duptime-collector
	rm /etc/systemd/system/duptime.service
	rm /usr/bin/duptime
	rm -rf /var/log/duptime
	systemctl stop duptime.service
	systemctl disable duptime.service
	systemctl daemon-reload
	@echo "Done"


# In this context, the *.project pattern means "anything that has the .project extension"
clean:
	rm -r /usr/bin/duptime
	rm -r /etc/systemd/system/duptime.service
	rm -r /var/log/duptime/logs.txt
	rm -r /usr/local/bin/duptime-collector

