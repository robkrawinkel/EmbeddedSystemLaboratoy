force KEY(0) 0
run 1 ms
force KEY(0) 1

force CLOCK_50 0, 1 10 ns -repeat 20 ns

force GPIO_0(20) 0, 1 1 ms -repeat 2 ms
run 500 us
force GPIO_0(22) 0, 1 1 ms -repeat 2 ms
run 10 ms

force GPIO_0(21) 0, 1 500 us -repeat 1 ms
run 250 us
force GPIO_0(23) 0, 1 500 us -repeat 1 ms
run 10 ms
