package Mesos::XUnit::Dispatcher::POE;
use Try::Tiny;
use Test::Class::Moose;
with 'Mesos::XUnit::Role::Dispatcher';

sub load_poe {
        require POE::Kernel;
        POE::Kernel->import({loop => 'Select'});
        require POE;
        POE->import;
        POE::Kernel->run;
}

sub test_startup {
    my ($self) = @_;
    try {
        $self->load_poe;
        require POE::Future;
        require Mesos::Dispatcher::POE;
    } catch {
        $self->test_skip('Could not require Mesos::Dispatcher::POE');
    };
}

sub new_future { POE::Future->new }

sub new_delay {
    my ($self, $after, $cb) = @_;
    require POE::Future;
    return POE::Future->new_delay($after)
                      ->on_done($cb);
}

sub new_dispatcher {
    my ($self, @args) = @_;
    return Mesos::Dispatcher::POE->new(@args);
}

1;
