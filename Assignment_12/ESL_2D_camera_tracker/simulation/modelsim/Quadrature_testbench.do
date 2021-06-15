force reset 1
run 1 ms
force reset 0

force CLOCK_50 0, 1 10 ns -repeat 20 ns

force signalA 0, 1 1 us -repeat 2 us
run 500 ns
force signalB 0, 1 1 us -repeat 2 us
run 500 us
force signalB 1, 0 1 us -repeat 2 us

run 500 us
