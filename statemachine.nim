import std/options
import std/tables
import pretty

type 
  Transition[S] = object
    source: S
    eventType: string
    target: S
    action: Action[S]

  Output = object of RootObj
    msg: string
  Action[S] = proc(ctx: Context[S]): Option[Output]

  StateMachine[S: enum] = object
    events: seq[string]
    transitionMap: TransitionMap[S]

  TransitionKey[S] = object
    state: S
    eventType: string

  TransitionMap[S] = Table[ TransitionKey[S], Transition[S]]


  Context[S] = object of RootObj
    currentState: S

 
proc `$`(tr: Transition): string =
  return $tr.source & " -> " & $tr.target



func newStateMachine[S:enum](events: seq[string], transitions: seq[Transition]): StateMachine[S] =
  result.events = events

  # map the FSM's state and the incoming event to a transition that we need to apply
  var 
    trmap : TransitionMap[S]
    key : TransitionKey[S]

  for tr in transitions:
    key.state = tr.source
    key.eventType = tr.eventType
    trmap[key] = tr

  result.transitionMap = trmap

proc receive[S](sm: StateMachine[S], ctx: var Context[S], event: object) : Option[Output] = 
  print "------------------"
  print "<<< ", ctx
  print "<<< ", event
  let transitionKey = TransitionKey[S](state: ctx.currentState, eventType: $typeof(event))
  
  try:
    let transition = sm.transitionMap[transitionKey]
    print ">>> ", transition

    let output = transition.action(ctx)
    ctx.currentState = transition.target
    return output
  except KeyError:
    echo ">>> no transition exists"

# ============================================================
#   Create test StateMachine instance and execute some 
#   transitions
# ============================================================


type 
  # Context
  SmtpCtx[S] = object of Context[S]
    rawLine: string

  # States
  State = enum
    Idle, Connected, ReceivedMail

  # Events
  ConnectEvent = object 
    clientAddress: string

  MailCmd = object 
    fromArg: string

  QuitCmd = object 


var
  defaultAction : Action[State] = proc(ctx:Context[State]) : Option[Output]  =
    echo "hello"

let 
  eventTypes = @[$ConnectEvent, $MailCmd, $QuitCmd]

  # Transitions
  transitions = @[
    # Client Connect
    Transition[State](source: State.Idle, eventType: $ConnectEvent, target: State.Connected, action: defaultAction),
    # MAIL FROM
    Transition[State](source: State.Connected, eventType: $MailCmd, target: State.ReceivedMail, action: defaultAction),

    # QUIT
    Transition[State](source: State.Connected, eventType: $QuitCmd, target: State.Idle, action: defaultAction),
    Transition[State](source: State.ReceivedMail, eventType: $QuitCmd, target: State.Idle, action: defaultAction),
  ]
 
  
var
  fsm = newStateMachine[State](eventTypes, transitions)
  ctx = SmtpCtx[State](currentState: State.Idle)

print "\nStarted State Machine\n"

discard fsm.receive(ctx, MailCmd())
discard fsm.receive(ctx, ConnectEvent())
discard fsm.receive(ctx, QuitCmd())


