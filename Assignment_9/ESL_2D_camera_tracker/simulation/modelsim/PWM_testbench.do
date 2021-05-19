force reset 1
run 1 ms
force reset 0

force CLOCK_50 0, 1 10 ns -repeat 20 ns

force CW 1
force enable 1
force frequency 20000
force dutycycle 50
run 500 us


force CW 0
force frequency 400000
force dutycycle 10
run 500 us

force enable 0
run 100 us
