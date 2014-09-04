package Net::Mesos::Scheduler;
use Moo;
use strict;
use warnings;

with 'Net::Mesos::Role::Scheduler';

sub registered {}
sub reregistered {}
sub disconnected {}
sub resourceOffers {}
sub offerRescinded {}
sub statusUpdate {}
sub frameworkMessage {}
sub slaveLost {}
sub executorLost {}
sub error {}


=head1 Name

Net::Mesos::Scheduler - base class for Mesos schedulers

=head1 Methods

=over 4

=item  registered($driver, $frameworkId, $masterInfo)

=item  reregistered($driver, $masterInfo)

=item  disconnected($driver)

=item  resourceOffers($driver, $offers)

=item  offerRescinded($driver, $offerId)

=item  statusUpdate($driver, $status)

=item  frameworkMessage($driver)

=item  slaveLost($driver, $executorId, $slaveId, $message)

=item  executorLost($driver, $executorId, $slaveId, $status)

=item  error($driver, $message)

=back

=cut

1;
