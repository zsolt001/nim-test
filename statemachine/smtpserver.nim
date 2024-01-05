import statemachine
import options
import pretty

type
  # Context
  ContextData = object
    mailbuffer: string
    databuffer: seq[string]

  # States
  State = enum
    Idle
    Connected
    ReceivedMail

  # Events
  ConnectEvent = object
    clientAddress: string

  MailCmd = object
    fromArg: string

  QuitCmd = object

let
  eventTypes = @[$ConnectEvent, $MailCmd, $QuitCmd]

  # Transitions
  defaultAction: Action[State, ContextData] =
    proc(ctx: Context[State, ContextData]): Option[Output] =
        print "running default action with context:"
        print ctx

  transitions =
    @[
      # Client Connect
      Transition[State, ContextData](
        source: State.Idle,
        eventType: $ConnectEvent,
        target: State.Connected,
        action: defaultAction,
      ),
      # MAIL FROM
      Transition[State, ContextData](
        source: State.Connected,
        eventType: $MailCmd,
        target: State.ReceivedMail,
        action: defaultAction,
      ),
      # QUIT
      Transition[State, ContextData](
        source: State.Connected,
        eventType: $QuitCmd,
        target: State.Idle,
        action: defaultAction,
      ),
      Transition[State, ContextData](
        source: State.ReceivedMail,
        eventType: $QuitCmd,
        target: State.Idle,
        action: defaultAction,
      )
    ]

var
  ctx2 = Context[State, ContextData](currentState: State.Idle)
  myinst = newInstance[State, ContextData](ctx2, eventTypes, transitions)

print myinst.sendevent(MailCmd())
print myinst.sendevent(ConnectEvent())
print myinst.sendevent(MailCmd())
print myinst.sendevent(QuitCmd())
