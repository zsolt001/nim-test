import statemachine
import options
import pretty

type
  # Context
  SmtpCtx[S] = object of Context[S]
    rawLine: string

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
  defaultAction: Action[State] =
    proc(ctx: Context[State]): Option[Output] =
        print "running default action with context:"
        print ctx

  transitions =
    @[
      # Client Connect
      Transition[State](
        source: State.Idle,
        eventType: $ConnectEvent,
        target: State.Connected,
        action: defaultAction,
      ),
      # MAIL FROM
      Transition[State](
        source: State.Connected,
        eventType: $MailCmd,
        target: State.ReceivedMail,
        action: defaultAction,
      ),
      # QUIT
      Transition[State](
        source: State.Connected,
        eventType: $QuitCmd,
        target: State.Idle,
        action: defaultAction,
      ),
      Transition[State](
        source: State.ReceivedMail,
        eventType: $QuitCmd,
        target: State.Idle,
        action: defaultAction,
      )
    ]

var
  ctx = Context[State](currentState: State.Idle)
  smtpctx = SmtpCtx[State](currentState: State.Idle)
  myinst = newInstance[State](smtpctx, eventTypes, transitions)

print smtpctx

print myinst.sendevent(ConnectEvent())
print myinst.sendevent(MailCmd())
print myinst.sendevent(QuitCmd())
