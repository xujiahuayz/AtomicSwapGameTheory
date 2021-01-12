# success premiums
alphas = c(0.3, 0.3) # agent alice or bob

# coumpound/discount rates
rs = c(0.01, 0.01) # agent alice or bob

# drift of Wiener process
mu = 0.002
sigma = 0.1

taua = 3
taub = 4
taueps = 1

P1 = 2 #current price is given, but strike price is to be negotiated

Pstars = seq(0.196, 3, length.out = 50)

Pstar_vals = c(1.6, 2, 2.4)

# universal upper boundary of alpha
alphaupper = 1

# universal lower boundary of alpha
alphalower = 0 # -1


col_cont = 'chartreuse3'

# plot axis limit
axis_lim = c(1e-10, 3.5)

col_success = c('darkturquoise', 'dodgerblue4', 'firebrick3')

lwd_success = 5


datanumber = 14
PstarAls = seq(1.05, 3, length.out = datanumber)

Qs = c(0.01, 0.1)

