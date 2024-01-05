import tables
import options

type
  Strategy*[T] = proc(t: T):Option[int] {.nimcall.}

proc fooStrategy[T](t: T): Option[int] = 
    echo "foo"
proc barStrategy[T](t: T): Option[int] = 
    echo "bar"


let
    strat1 : Strategy[int] = proc(t: int):Option[int] =
        echo "hello", t

let strategies* = toTable[string, Strategy[int]]([
    ("foo", fooStrategy[int]), ("bar", barStrategy[int])
])


discard strat1(12)

type
    Output = object of RootObj
      msg: string
    Action[S] = proc(ctx: Context[S]): Option[Output]  #{.gcsafe.}
    
    State = enum
        One, Two
        
    Context[S] = object of RootObj
      currentState: S

let withint = proc(ctx: Context[int]): Option[Output] = 
  echo "hello with an int ", ctx.currentState

discard withint(Context[int](currentState: 12))
echo typeof(withint)
var a : Action[int]
echo typeof(a)

a = withint
discard a(Context[int](currentState: 13))



# let
#   act1 : Action[int] = proc(ctx: Context[int]): int=
#     echo "hello"
#     
#   act2 : Action[State] = proc(ctx: State): int=
#     echo "hello enum ",ctx 


# discard act1(44)
# # echo Context[State](currentState: State.One)
# # discard act2(Context[State](currentState: State.One))

