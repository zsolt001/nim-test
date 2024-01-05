switch("outdir", "./build")
task run, "builds and runs a debug vesion":
  switch("run")
  setCommand "c"
