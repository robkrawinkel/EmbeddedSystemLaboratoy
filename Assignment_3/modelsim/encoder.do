force KEY(0) 0
run 1 ms
force KEY(0) 1

force CLOCK_50 0, 1 10 ns -repeat 20 ns

force GPIO_0(6) 0, 1 1 ms -repeat 2 ms
run 500 us
force GPIO_0(7) 0, 1 1 ms -repeat 2 ms
run 10 ms

force GPIO_0(9) 0, 1 1 ms -repeat 2 ms
run 200 us
force GPIO_0(8) 0, 1 1 ms -repeat 2 ms
run 10 ms