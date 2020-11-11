Basic Smack Regression Test Suite for the Linux Kernel
======================================================
https://github.com/smack-team/smack-suite

The smack-suite project provides a self-contained regression test
suite for the Smack Linux Security Module (LSM).

## Inline Resources

The test suite's source repository is part of the smack-team project
and is located on Github at:

* https://github.com/smack-team/smack-suite

## Installation

The smack-suite requires the Smack userspace, which must be built locally.

	$ git clone https://github.com/smack-team/smack.git
	$ cd smack
	$ ./autogen.sh
	$ make
	$ sudo make install

It also requires the programs bash, make, ifconfig and socat. On a Fedora
system these can be installed with:

	$sudo dnf install bash make net-tools socat

## Execution

Note that running the test suite may result in a change to the
Smack configuration. While the test suite is designed to reset the
system to its prior state there may be cases where this is done
imperfectly. This is especially true if the execution of the test
suite is interrupted.

### Configuration

The test suite needs to know a non-root user under which some
tests will be run. The source contains an example configuration
file named config-example. Copy this file to a new file named
config and change the line beginning with "notroot=" to specify
a the user under which tests should be run.

### Building the Test Tools

While the tests are bash scripts there are a few support utilities
that are written in C. These are found in the tools directory and
must be built prior to running the tests.

	$ make -C tools

### Running the Full Test Suite

	# make test-results

### Running Test Without a Network

	# make local-results

### Running an Individual Test

	# make <test-name>

Using the Makefile to run individual tests allows for set-up to
be done correctly.
