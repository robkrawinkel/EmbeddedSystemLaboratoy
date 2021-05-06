force reset 1
run 1 ms
force reset 0

force CLOCK_50 0, 1 10 ns -repeat 20 ns

force PWM_frequency 20000
force PWM_dutycycle0 50
force PWM_dutycycle1 10
run 500 us
