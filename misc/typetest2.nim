type
  State = object
  Baba[S] = ref object
  Instance[S] = ref object
    ctx: Baba[S]

# Define the `newInstance` procedure
proc newInstance[S](ctx: Baba[S]): Instance[S] =
  new(result)
  result.ctx = ctx

var
  b = new Baba[State]  # Create a new `Baba[State]`
  myinst = newInstance(ctx: b)  # Use `newInstance` to create an `Instance[State]`

# Print the `Baba[State]` instance `b`
echo b
