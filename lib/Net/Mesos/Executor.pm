package Net::Mesos::Executor;
use Moo;
use strict;
use warnings;

with 'Net::Mesos::Role::Executor';

sub registered {}
sub reregistered {}
sub disconnected {}
sub launchTask {}
sub killTask {}
sub frameworkMessage {}
sub shutdown {}
sub error {}


1;
