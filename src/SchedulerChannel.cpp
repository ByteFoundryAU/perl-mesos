#include <SchedulerChannel.hpp>
#include <cstdio>
#include <unistd.h>

namespace mesos {
namespace perl {

SchedulerCommand::SchedulerCommand(const std::string& name, const CommandArgs& args)
: name_(name), args_(args)
{

}

SchedulerChannel::SchedulerChannel()
: pending_(new CommandQueue)
{
    int fds[2];
    pipe(fds);
    in_ = fdopen(fds[0], "r");
    out_ = fdopen(fds[1], "w");
    setvbuf(out_, NULL, _IONBF, 0);
}

SchedulerChannel::~SchedulerChannel()
{
    fclose(in_);
    fclose(out_);
    delete pending_;
}

void SchedulerChannel::send(const SchedulerCommand& command)
{
    pending_->push(command);
    fprintf(out_, "%s\n", command.name_.c_str());
}

const SchedulerCommand SchedulerChannel::recv()
{
    const SchedulerCommand command = pending_->front();
    pending_->pop();
    return command;
}

} // namespace perl {
} // namespace mesos {
