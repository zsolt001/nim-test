import std/options
import std/tables
import std/hashes
import pretty

type 
  StateMachine = object
    states: seq[State]
    events: seq[Event]
    transitionMap: TransitionMap

  State = object of RootObj
    name: string

  Event = object of RootObj
    name: string
  
  TransitionKey = object
    currentState: State
    receivedEvent: Event

  TransitionMap = Table[ TransitionKey, Transition]

  Context = object of RootObj
    currentState: State

  Output = object of RootObj
    msg: string
  
  Transition = tuple[source: State, event: Event, target: State, action: Action]
  Action = proc(ctx: Context): Option[Output]


proc `$`(st: State): string =
  return "State: " & st.name

proc `$`(ev: Event): string =
  return "Event: " & ev.name

proc `$`(tr: Transition): string =
  return $tr.source & " -> " & $tr.target

# proc hash(k : TransitionKey) : Hash =
#   result = string(k.currentState).hash !& string(k.receivedEvent).hash
#   result = !$result


func newStateMachine(states: seq[State], events: seq[Event], transitions: seq[Transition]): StateMachine =
  result.states = states
  result.events = events

  # map the FSM's state and the incoming event to a transition that we need to apply
  var trmap : TransitionMap

  for tr in transitions:
    var key : TransitionKey
    key.currentState = tr.source
    key.receivedEvent = tr.event
    trmap[key] = tr

  result.transitionMap = trmap

proc receive(sm: StateMachine, ctx: var Context, event: Event) : Option[Output] = 
  print "------------------"
  echo "<<< ", ctx
  echo "<<< ", event
  let transitionKey = TransitionKey(currentState: ctx.currentState, receivedEvent: event)
  
  try:
    let transition = sm.transitionMap[transitionKey]
    echo ">>> ", transition

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
  SmtpCtx = object of Context
    rawLine: string

let 
  # States
  IdleState = State(name: "idle")
  ConnectedState = State(name: "connected")
  ReceivedMailState= State(name: "receivedMail")
  states = @[IdleState, ConnectedState, ReceivedMailState]

  # Events
  ConnectEvent = Event(name: "CONNECT")
  MailCmd = Event(name: "MAIL")
  QuitCmd =  Event(name: "QUIT")
  events = @[ConnectEvent, MailCmd, QuitCmd]

  # Actions
  defaultAction : Action = proc(ctx: Context) : Option[Output] =
    echo ">>> executing default action in state: ", ctx.currentState
  
  # Transitions
  transitions:seq[Transition] = @[
    # Client Connect
    (IdleState, ConnectEvent, ConnectedState, defaultAction),
    # MAIL FROM
    (ConnectedState, MailCmd, ReceivedMailState, defaultAction),
    # QUIT
    (ConnectedState, QuitCmd, IdleState, defaultAction),
    (ReceivedMailState, QuitCmd, IdleState, defaultAction),
  ]
 
  
var
  fsm = newStateMachine(states, events, transitions)
  ctx = SmtpCtx(currentState: IdleState)

print "\nStarted State Machine\n"

discard fsm.receive(ctx, MailCmd)
discard fsm.receive(ctx, ConnectEvent)
discard fsm.receive(ctx, QuitCmd)


