package Mesos::Executor;
use Mesos::Messages;
use Moo;
use namespace::autoclean;

sub registered {}
sub reregistered {}
sub disconnected {}
sub launchTask {}
sub killTask {}
sub frameworkMessage {}
sub shutdown {}
sub error {}


=head1 NAME

Mesos::Executor - base class for Mesos executors

=head1 SYNOPSIS

Mesos::Executor methods are callbacks which will are invoked by Mesos::ExecutorDriver.

  #!/usr/bin/perl
  package TestExecutor;
  use Mesos::Messages;
  use Moo;
  extends 'Mesos::Executor';

  sub launchTask {
      my ($self, $driver, $task) = @_;
      printf "Running task %s\n", $task->{task_id}{value};
      my $update = Mesos::TaskStatus->new({
          task_id => $task->{task_id},
          state   => Mesos::TaskState::TASK_RUNNING,
          data    => "data with a \0 byte",
      });
      $driver->sendStatusUpdate($update);

      print "Sending status update...\n";
      $update = Mesos::TaskStatus->new({
          task_id => $task->{task_id},
          state   => Mesos::TaskState::TASK_FINISHED,
          data    => "data with a \0 byte",
      });
      $driver->sendStatusUpdate($update);
      print "Sent status update\n";
  }

  sub frameworkMessage {
      my ($self, $driver, $message) = @_;
      $driver->sendFrameworkMessage($message);
  }

  package main;
  use Mesos::Messages;
  use Mesos::ExecutorDriver;
  print "Starting executor\n";
  my $driver = Mesos::ExecutorDriver->new(executor => TestExecutor->new);
  exit( ($driver->run == Mesos::Status::DRIVER_STOPPED) ? 0 : 1 );


=head1 DESCRIPTION

A Mesos executor is responsible for launching tasks in a framework
specific way (i.e., creating new threads, new processes, etc). One
or more executors from the same framework may run concurrently on
the same machine.

Note that we use the term "executor" fairly loosely to refer to the
code that implements the Executor interface (see below) as well as
the program that is responsible for instantiating a new
L<Mesos::ExecutorDriver>.

In fact, while a Mesos slave is responsible for (forking &) executing
the "executor", there is no reason why whatever the slave executed
might itself actually execute another program which then instantiates
and runs the L<Mesos::SchedulerDriver>. The only contract with the
slave is that the program that it invokes does not exit until the
"executor" has completed. Thus, what the slave executes may be nothing
more than a script which actually executes (or forks and waits) the
"real" executor.

=head1 METHODS

See also I<MESOS_HOME/include/mesos/executor.hpp>

=over 4

=item registered($driver, $executorInfo, $frameworkInfo, $slaveInfo)

Invoked once the executor driver has been able to successfully
connect with Mesos. In particular, a scheduler can pass some
data to it's executors through the FrameworkInfo.ExecutorInfo's
data field.

I<$driver> is the L<Mesos::ExecutorDriver> calling us

I<$executorInfo> is a Protocol Buffer Message class

I<$frameworkInfo> is ????

I<$slaveInfo> is ???

=item reregistered($driver, $slaveInfo)

Invoked when the executor re-registers with a restarted slave.

=item disconnected($driver)

Invoked when the executor becomes "disconnected" from the slave
(e.g., the slave is being restarted due to an upgrade).

=item launchTask($driver, $task)

Invoked when a task has been launched on this executor (initiated
via Scheduler::launchTasks). Note that this task can be realized
with a thread, a process, or some simple computation, however, no
other callbacks will be invoked on this executor until this
callback has returned.

=item killTask($driver, $taskId)

Invoked when a task running within this executor has been killed
(via SchedulerDriver::killTask). Note that no status update will
be sent on behalf of the executor, the executor is responsible
for creating a new TaskStatus (i.e., with TASK_KILLED) and
invoking ExecutorDriver::sendStatusUpdate.

=item frameworkMessage($driver, $message)

Invoked when a framework message has arrived for this
executor. These messages are best effort; do not expect a
framework message to be retransmitted in any reliable fashion.

=item shutdown($driver)

Invoked when the executor should terminate all of it's currently
running tasks. Note that after a Mesos has determined that an
executor has terminated any tasks that the executor did not send
terminal status updates for (e.g., TASK_KILLED, TASK_FINISHED,
TASK_FAILED, etc) a TASK_LOST status update will be created.

=item error($driver, $message)

Invoked when a fatal error has occurred with the executor and/or
executor driver. The driver will be aborted BEFORE invoking this
callback.

=back

=head1 OPERATIONAL NOTES

After creating your custom executor, you need to make it available to all slaves in the cluster.

The I<Mesos fetcher> is a recent addition that can help with this. Otherwise, perhaps use a common NFS or systems configuration tool like L<Rex>.

Once you are sure that your executors are available to the mesos-slaves, you should be able to run your scheduler, which will register with the Mesos master, and start receiving resource offers!

=head1 SEE ALSO

L<http://mesos.apache.org/documentation/latest/app-framework-development-guide/>

=cut

1;
