#include <MesosChannel.hpp>
#include <cstdio>
#include <unistd.h>

namespace mesos {
namespace perl {

CommandArg::CommandArg(const std::string& data, const std::string& type)
: data_(data), type_(type)
{

}

MesosCommand::MesosCommand(const std::string& name, const CommandArgs& args)
: name_(name), args_(args)
{

}

MesosChannel::MesosChannel()
: pending_(new CommandQueue)
{
    int fds[2];
    pipe(fds);
    in_ = fdopen(fds[0], "r");
    out_ = fdopen(fds[1], "w");
    setvbuf(in_, NULL, _IONBF, 0);
    setvbuf(out_, NULL, _IONBF, 0);
}

MesosChannel::~MesosChannel()
{
    fclose(in_);
    fclose(out_);
    delete pending_;
}

void MesosChannel::send(const MesosCommand& command)
{
    pending_->push(command);
    fprintf(out_, "%s\n", command.name_.c_str());
}

const MesosCommand MesosChannel::recv()
{
    char str[100];
    if (fgets(str, 100, in_)) {
        const MesosCommand command = pending_->front();
        pending_->pop();
        return command;
    } else {
        return MesosCommand(std::string(), CommandArgs());
    }
}

} // namespace perl {
} // namespace mesos {
