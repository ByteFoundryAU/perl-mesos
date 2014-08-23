#!/usr/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Test::More;
use Net::Mesos::Test::Utils;

BEGIN {
    plan skip_all => 'require Test::LeakTrace'
        unless eval{ require Test::LeakTrace };
}
use Test::LeakTrace;

use Net::Mesos::SchedulerDriver;
no_leaks_ok {
    my $driver = Net::Mesos::SchedulerDriver->new(
        scheduler => test_scheduler,
        master    => test_master,
        framework => test_framework,
    );
} 'Net::Mesos::SchedulerDriver construction does not leak';

use Net::Mesos::Channel;
no_leaks_ok {
    my $channel = Net::Mesos::Channel->new;
} 'Net::Mesos::Channel construction does not leak';

use Net::Mesos::ProxyScheduler;
no_leaks_ok {
    my $proxy = Net::Mesos::ProxyScheduler->new;
} 'Net::Mesos::ProxyScheduler construction does not leak';

done_testing();
