# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use constant THIS_CLASS => 'Proc::Daemontools';
use Test::More tests => 4;
BEGIN { use_ok(THIS_CLASS) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

$SVC = "/usr/local/bin/svc";

# Searching for the svscan process
$ps = `ps -C svscan -o args= 2>&1`;
$status = $?;
is ($status, 0,	"the svscan process is running");

if ( $status != 0 ) {
    if ($ps) {
	print "ERROR: execution of 'ps -C svscan -o args= 2>&1' failed:\n", 
	      $ps, 
	      "To continue with the tests I need to run this command.\n";
    } else {
	print "ERROR: the svscan process is not running on your machine. ",
	      "I´ll assume you don´t have the daemontools package installed.\n";
    }
} else {
    $SKIP_REASON = "WARNING: the svc file cannot be found on its default location " .
	  "\'$SVC\'. Skipping the remaining tests.";
    SKIP: {
	skip ($SKIP_REASON, 2) if (! -e $SVC);
	$SERVICE_DIR = (split(/\s{1,}/, $ps))[1];
	eval {
	    if (-e $SERVICE_DIR) { 
		$svc = new Proc::Daemontools (SERVICE_DIR => $SERVICE_DIR);
	    } else {
		$svc = new Proc::Daemontools;
	    }
	};
	if ($@) {
	    print "ERROR: the following error ocurred when trying to create a ",
		  THIS_CLASS, " object:\n", $@;
	}
	ok( defined $svc,		'a new ' . THIS_CLASS . " object was created" );
	ok( $svc->isa(THIS_CLASS),	"testing it´s classname" );
	if ( opendir (DIR, $SERVICE_DIR) ) {
	    print "Here goes some information about your daemons:\n";
	    while ($daemon = readdir(DIR)) {
		next if ($daemon =~ /^\.[.]?/ ); # skips '.' and '..' directories
		eval {
		    if ($svc->is_up($daemon)) {
			print "\t$daemon is up.\n";
		    } else {
			print "\t$daemon is down.\n";
		    }
		};
	    }
	    close (DIR);
	}
    }
}
