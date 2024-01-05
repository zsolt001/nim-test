import pretty

type
    Ctx*[S] = object of RootObj
        currentState*: S

    Instance[S] = object
        ctx: Ctx[S]

    State = enum
        High, Low



proc sendevent[S](inst: var Instance[S])  = 
  print inst.ctx


proc newInstance[S](myctx: Ctx[S]) : Instance[S] = 
  return Instance[S](ctx: myctx)

var
    myctx = Ctx[State]()
    myinst = newInstance(myctx)

print myctx
print myinst
sendevent(myinst)
myinst.sendevent()