import std/options
import std/tables
import pretty
import terminal

type
  Transition*[S, D] = object
    source*: S
    eventType*: string
    target*: S
    action*: Action[S, D]

  Output* = object of RootObj
    msg*: string

  Action*[S, D] = proc(ctx: Context[S, D]): Option[Output]

  StateMachine[S: enum, D] = object
    events: seq[string]
    transitionMap: TransitionMap[S, D]

  TransitionKey[S] = object
    state: S
    eventType: string

  TransitionMap[S, D] = Table[TransitionKey[S], Transition[S, D]]

  Context*[S, D] = object
    currentState*: S
    data*: D

proc `$`(tr: Transition): string =
  return $tr.source & " ---" & tr.eventType & "---> " & $tr.target

proc newStateMachine*[S: enum, D](
    events: seq[string], transitions: seq[Transition]
): StateMachine[S, D] =
  result.events = events

  # map the FSM's state and the incoming event to a transition that we need to apply
  var
    trmap: TransitionMap[S, D]
    key: TransitionKey[S]

  for tr in transitions:
    key.state = tr.source
    key.eventType = tr.eventType
    trmap[key] = tr

  result.transitionMap = trmap

proc receive[S, D](
    sm: StateMachine[S, D], ctx: var Context, event: object
): Option[Output] =
  print "\n\n<<<<<<<<<<<"
  print ctx
  print event
  print "\n>>>>>>>>>>>"

  let
    transitionKey = TransitionKey[S](state: ctx.currentState, eventType: $typeof(event))

  try:
    let transition = sm.transitionMap[transitionKey]
    styledEcho(fgRed, $transition)
    print transition

    let output = transition.action(ctx)
    ctx.currentState = transition.target
    return output
  except KeyError:
    styledEcho(fgYellow, "no transition exists")

type
  Instance[S, D] = object
    ctx: Context[S, D]
    sm: StateMachine[S, D]

func newInstance*[S, D](
    context: Context[S, D], events: seq[string], transitions: seq[Transition]
): Instance[S, D] =
  return Instance[S, D](ctx: context, sm: newStateMachine[S, D](events, transitions))

proc sendevent*[S, D](inst: var Instance[S, D], event: object): Option[Output] =
  result = receive(inst.sm, inst.ctx, event)

# ============================================================
#   Create test StateMachine instance and execute some 
#   transitions
# ============================================================

type
  # Context
  ContextData = object

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
