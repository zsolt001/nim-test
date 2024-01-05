import synthesis

type Phase = enum
  Solid
  Liquid
  Gas
  Plasma # Plasma is almost unused

type Event = enum
  Over100
  Between0and100
  Below0
  OutOfWater

declareAutomaton(waterMachine, Phase, Event)

setPrologue(waterMachine):
  echo "Welcome to the Steamy machine version 2000!\n"
  var temp: float64
  var inputTemps: seq[float64]
  inputTemps = tempFeed

setInitialState(waterMachine, Liquid)

setTerminalState(waterMachine, Exit)

setEpilogue(waterMachine):
  echo "Now I need some coffee."


implEvent(waterMachine, OutOfWater):
  inputTemps.len == 0

implEvent(waterMachine, Between0and100):
  0 < temp and temp < 100

implEvent(waterMachine, Below0):
  temp < 0

implEvent(waterMachine, Over100):
  100 < temp

onEntry(waterMachine, [Solid, Liquid, Gas]):
  let oldTemp = temp
  temp = inputTemps.pop()
  echo "Temperature: ", temp


behavior(waterMachine):
  ini: [Solid, Liquid, Gas, Plasma]
  fin: Exit
  interrupt: OutOfWater
  transition:
    echo "Running out of steam ..."

behavior(waterMachine):
  ini: Solid
  fin: Liquid
  event: Between0and100
  transition:
    assert 0 <= temp and temp <= 100
    echo "Ice is melting into Water.\n"

behavior(waterMachine):
  ini: Liquid
  fin: Gas
  event: Over100
  transition:
    assert temp >= 100
    echo "Water is vaporizing into Vapor.\n"

behavior(waterMachine):
  ini: Solid
  fin: Gas
  event: Over100
  transition:
    assert temp >= 100
    echo "Ice is sublimating into Vapor.\n"

behavior(waterMachine):
  ini: Gas
  fin: Solid
  event: Below0
  transition:
    assert temp <= 0
    echo "Vapor is depositing into Ice.\n"

behavior(waterMachine):
  ini: Gas
  fin: Liquid
  event: Between0and100
  transition:
    assert 0 <= temp and temp <= 100
    echo "Vapor is condensing into Water.\n"

behavior(waterMachine):
  ini: Liquid
  fin: Solid
  event: Below0
  transition:
    assert temp <= 0
    echo "Water is freezing into Ice.\n"

behavior(waterMachine):
  steady: [Solid, Liquid, Gas]
  transition:
    # Note how we use the oldTemp that was declared in `onEntry`
    echo "Changing temperature from ", oldTemp, " to ", temp, " didn't change phase. How exciting!\n"

synthesize(waterMachine):
  proc observeWater(tempFeed: seq[float])

const dotRepr = toGraphviz(waterMachine)
writeFile("water_phase_transitions.dot", dotRepr)

import random, sequtils
import std/threadpool

echo "\n"
let obs1 = newSeqWith(4, rand(1.0..150.0))
echo obs1
echo "\n\n"
let obs2 = newSeqWith(4, rand(-50.0 .. -1.0))
echo obs2
echo "\n\n"
spawn observeWater(obs1)
spawn observeWater(obs2)
sync()

