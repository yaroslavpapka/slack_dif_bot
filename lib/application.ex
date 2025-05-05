defmodule SlackBot.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Finch, name: SlackFinch},
      SlackBot.Scheduler
    ]

    opts = [strategy: :one_for_one, name: SlackBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
