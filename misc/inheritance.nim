import pretty

type
  Person = ref object of RootObj
    name: string

  Student = ref object of Person
    id: string


proc prn(p: Person) =
  echo typeof(p)
  print p

proc prn(s: Student) =
  echo typeof(s)
  print s

proc via(p: ref Person) = 
  echo "VIA"
  prn p[]

var
  p1: Person = Person(name: "Joe")
  s1 = Student(name: "Billy", id: "12")

echo p1[]
echo s1[]

prn p1
prn s1

via s1
