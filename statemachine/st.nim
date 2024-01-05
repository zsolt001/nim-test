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

  TransitionMap = Table[TransitionKey, Transition]

  Context = object of RootObj
    currentState: State

  Output = object of RootObj
    msg: string

  Transition = tuple[source: State, event: Event, target: State, action: Action]
  Action = proc(ctx: Context): Option[Output]



# proc hash(k : TransitionKey) : Hash =
#   result = string(k.currentState).hash !& string(k.receivedEvent).hash
#   result = !$result


func newStateMachine(states: seq[State], events: seq[Event], transitions: seq[
    Transition]): StateMachine =
  result.states = states
  result.events = events

  # map the FSM's state and the incoming event to a transition that we need to apply
  var trmap: TransitionMap

  for tr in transitions:
    var key: TransitionKey
    key.currentState = tr.source
    key.receivedEvent = tr.event
    trmap[key] = tr

  result.transitionMap = trmap

proc receive(sm: StateMachine, ctx: var Context, event: Event): Option[Output] =
  print "------------------"
  print ctx
  print event
  let transitionKey = TransitionKey(currentState: ctx.currentState,
      receivedEvent: event)

  try:
    let transition = sm.transitionMap[transitionKey]
    print ">>> ", transition

    let output = transition.action(ctx)
    ctx.currentState = transition.target
    return output
  except KeyError:
    print "no transition exist"

  print "------------------\n"



let
  IdleState = State(name: "idle")
  ConnectedState = State(name: "connected")
  ReceivedMailState = State(name: "receivedMail")
  ConnectEvent = Event(name: "CONNECT")
  MailCmd = Event(name: "MAIL")
  QuitCmd = Event(name: "QUIT")

let
  defaultAction: Action = proc(ctx: Context): Option[Output] =
    print ">>> executing default action in state: ", ctx.currentState

  transitions: seq[Transition] = @[
    ("idle".State, "CONNECT".Event, "connected".State, defaultAction),
    ("connected".State, "MAIL".Event, "receivedMail".State, defaultAction),
    ("connected".State, "QUIT".Event, "idle".State, defaultAction),
    ("receivedMail".State, "QUIT".Event, "idle".State, defaultAction),
  ]


var
  fsm = newStateMachine(states, events, transitions)
  ctx = Context(currentState: "idle".State)

print "Started State Machine"

print fsm.receive(ctx, "MAIL".Event)
print fsm.receive(ctx, "CONNECT".Event)


