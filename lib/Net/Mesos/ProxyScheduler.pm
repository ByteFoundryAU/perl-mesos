package Net::Mesos::ProxyScheduler;
use Moo;
use strict;
use warnings;

use Net::Mesos;

sub BUILD {
    my ($self) = @_;
    $self->xs_init;
}


1;
