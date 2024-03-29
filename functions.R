## basic functions ----
# Utility function
util = function(Value,
                Time,
                Suc,
                alpha = 0,
                r = 0) {
  (1 + alpha * Suc) * Value / exp(r * Time)
}

# Brownian motion PDF
gbmpdf = function(x, Price, Time) {
  exp(-(2 * log(x / Price) - (2 * mu - sigma ^ 2) * Time) ^ 2 / (8 * sigma ^
                                                                   2 * Time)) / (sqrt(2 * pi * Time) * x * sigma)
}

# Brownian motion CDF
gbmcdf = function(x, Price, Time) {
  erfc(# complementary error function erfc
    (log(Price / x) + (mu - sigma ^ 2 / 2) * Time) / (sqrt(2 * Time) * sigma)) /
    2
}


# Brownian motion Expectation
gbmexp = function(Price, Time) {
  Price * exp(mu * Time)
}

## util3 ----
## unitily of Alice at t_3 if continue, Alice gets 1 at t_3+taub if P_3 > P_3 lowerbound
util3_A_cont = function(pt3v, alphaA = alphas[1]) {
  Time = taub
  v = gbmexp(pt3v, Time)
  util(v, Time, 1, alphaA, rs[1])
}

util3_B_cont = function(Pstar, alphaB = alphas[2]) {
  util(Pstar, taueps + taua, 1, alphaB, rs[2])
}

## utility of Alice at t_3 if withdraw, Alice gets P0 at t_3+2taua+taueps
util3_A_stop = function(Pstar) {
  util(Pstar, taueps + 2 * taua, 0, r = rs[1])
}

util3_B_stop = function(pt3v) {
  Time = 2 * taub
  v = gbmexp(pt3v, Time)
  util(v, Time, 0, r = rs[2])
}

# price lower bound for Alice to continue at t3
P3_lower = function(Pstar, alphaA = alphas[1]) {
  Pstar * exp((rs[1] - mu) * taub - rs[1] * (taueps + 2 * taua)) / (1 + alphaA)
}

## util2 ----
## expected utility of Alice at t_2 if Bob continues
util2_A_cont = function(pt2, Pstar, alphaA = alphas[1]) {
  pt3threshv = P3_lower(Pstar, alphaA)
  Time = taub # time until next step
  
  temp = function(pt3) {
    gbmpdf(pt3, pt2, Time) * util3_A_cont(pt3, alphaA)
  }
  util3_A = integrate(Vectorize(temp), pt3threshv, Inf, abs.tol = 0)$value +
    gbmcdf(pt3threshv, pt2, Time) * util3_A_stop(Pstar)
  
  util3_A / exp(rs[1] * Time)
}


# expected utility for Bob if continue
util2_B_cont = function(pt2, Pstar, alphaB = alphas[2]) {
  pt3threshv = P3_lower(Pstar, alphaA = alphas[1])
  Time = taub # time until next step
  temp = function(pt3) {
    gbmpdf(pt3, pt2, Time) * util3_B_stop(pt3)
  }
  util3_B = (1 - gbmcdf(pt3threshv, pt2, Time)) * util3_B_cont(Pstar, alphaB) +
    integrate(Vectorize(temp), 0, pt3threshv)$value
  util3_B / exp(rs[2] * Time)
}


util2_A_stop = function(Pstar) {
  util(Pstar, taub + taueps + 2 * taua, 0, r = rs[1])
}

util2_B_stop = function(pt2v) {
  pt2v
}


# if not vectorize: evaluation of function gave a result of wrong length
P2_thresh = function(Pstar, alphaB  = alphas[2]) {
  temp = function(x) {
    util2_B_cont(x, Pstar, alphaB) - util2_B_stop(x)
  }
  uniroot.all(
    Vectorize(temp),
    lower = 0.01,
    upper = 999,
    maxiter = 99999,
    n = 9999
  )
}

## util1 ----
## expected utility of Alice at t_1 if Bob continues
util1_A_cont = function(Pstar,
                        pt1 = P1,
                        alphaA = alphas[1],
                        alphaB = alphas[2]) {
  pt2threshv = P2_thresh(Pstar, alphaB)
  Time = taua # time until next step
  
  temp = function(pt2) {
    gbmpdf(pt2, pt1, Time) * util2_A_cont(pt2, Pstar, alphaA)
  }
  
  probBobwaive = (1 - gbmcdf(pt2threshv[2], pt1, Time) + gbmcdf(pt2threshv[1], pt1, Time))
  util2_A = integrate(Vectorize(temp), pt2threshv[1], pt2threshv[2], abs.tol = 0)$value + probBobwaive * util2_A_stop(Pstar)
  
  util2_A / exp(rs[1] * Time)
}


# expected utility for Bob if continue
util1_B_cont = function(Pstar,
                        pt1 = P1,
                        alphaB = alphas[2]) {
  pt2threshv = P2_thresh(Pstar, alphaB)
  Time = taua # time until next step
  
  temp1 = function(pt2) {
    gbmpdf(pt2, pt1, Time) * util2_B_cont(pt2, Pstar, alphaB)
  }
  
  temp2 = function(pt2) {
    gbmpdf(pt2, pt1, Time) * util2_B_stop(pt2)
  }
  
  util2_B = integrate(Vectorize(temp1), pt2threshv[1], pt2threshv[2], abs.tol = 0)$value +
    integrate(Vectorize(temp2), 0, pt2threshv[1], abs.tol = 0)$value +
    integrate(Vectorize(temp2), pt2threshv[2], Inf, abs.tol = 0)$value
  
  util2_B / exp(rs[2] * Time)
}


util1_A_stop = function(Pstar) {
  Pstar
}

util1_B_stop = function(pt1v) {
  pt1v
}

## success ----
sucrate = function(Pstar) {
  if (util1_A_cont(Pstar) > util1_A_stop(Pstar)) {
    # check feasibility
    pt3threshv = P3_lower(Pstar, alphas[1])
    
    temp = function(pt2) {
      gbmpdf(pt2, P1, taua) * (1 - gbmcdf(pt3threshv, pt2, taub))
    }
    
    pt2threshv = P2_thresh(Pstar)
    
    integrate(Vectorize(temp),
              pt2threshv[1],
              pt2threshv[2])$value
  } else{
    NA
  }
}

## uncertain exchange ----
P3_lower_unknx = function(actual_X, Pstar, alphaA = alphas[1]) {
  P3_lower(Pstar, alphaA = alphaA) / actual_X
}


util2_A_unknx = function(actual_X, pt2, Pstar, alphaA = alphas[1]) {
  Time = taub
  if (actual_X == 0) {
    util3_A = util3_A_stop(Pstar)
  } else{
    pt3threshv = P3_lower_unknx(actual_X, Pstar, alphaA)
    # time until next step
    
    temp = function(pt3) {
      gbmpdf(pt3, pt2, Time) * util3_A_cont(pt3, alphaA)
    }
    util3_A = integrate(Vectorize(temp), pt3threshv, 5 * pt2, abs.tol = 0)$value * actual_X +
      gbmcdf(pt3threshv, pt2, Time) * util3_A_stop(Pstar)
  }
  util3_A / exp(rs[1] * Time)
}

util2_B_unknx = function(actual_X,
                         pt2,
                         Pstar,
                         alphaA = alphas[1],
                         alphaB = alphas[2]) {
  if (actual_X == 0) {
    0
  } else{
    pt3threshv = P3_lower_unknx(actual_X, Pstar, alphaA)
    Time = taub # time until next step
    
    temp = function(pt3) {
      gbmpdf(pt3, pt2, Time) * util3_B_stop(pt3)
    }
    util3_B = (1 - gbmcdf(pt3threshv, pt2, Time)) * util3_B_cont(Pstar, alphaB) +
      integrate(Vectorize(temp),
                0,
                pt3threshv)$value * actual_X
    
    util3_B / exp(rs[2] * Time) - actual_X * pt2
  }
}

X_opt = function(pt2, alphaA = alphas[1], Pstar) {
  X_cand = seq(0, 3 * pt2, length.out = 250)
  util3_B_cand = Vectorize(util2_B_unknx)(X_cand, pt2, Pstar)
  X_cand[which.max(util3_B_cand)]
}

util1_A_unknx = function(Pstar,
                         pt1 = P1,
                         alphaA = alphas[1],
                         alphaB = alphas[2]) {
  Time = taua # time until next step
  
  temp = function(pt2) {
    gbmpdf(pt2, pt1, Time) * util2_A_unknx(X_opt(pt2, alphaA, Pstar), pt2, Pstar, alphaA)
  }
  
  
  util2_A = integrate(Vectorize(temp),
                      0,
                      5 * pt1,
                      subdivisions = 2000)$value
  
  util2_A / exp(rs[1] * Time) - Pstar
}


## uncertain ex suc ----
sucrate_unknx = function(Pstar,
                         alphaA = alphas[1],
                         alphaB = alphas[2]) {
  temp = function(pt2) {
    xopt = X_opt(pt2, alphaA, Pstar)
    if (xopt == 0) {
      0
    } else{
      gbmpdf(pt2, P1, taua) * (1 - gbmcdf(P3_lower_unknx(xopt, Pstar, alphaA), pt2, taub))
      
    }
  }
  integrate(Vectorize(temp), 0.001, 30,
            subdivisions = 2000)
}



## uncertain ----
## expected utility for Bob if continue, uncertain about alpha^A, but alpha^A lower bound is known
util2_B_cont_unc = function(pt2, Pstar, alphalower, alphaB) {
  Time = taub # time until next step
  foo = function(alphaA) {
    pt3threshv = P3_lower(Pstar, alphaA)
    temp = function(pt3) {
      gbmpdf(pt3, pt2, Time) * util3_B_stop(pt3)
    }
    util3_B = (1 - gbmcdf(pt3threshv, pt2, Time)) * util3_B_cont(Pstar, alphaB) +
      integrate(Vectorize(temp),
                0,
                pt3threshv)$value
    util3_B
  }
  
  integrate(Vectorize(foo), alphalower, 1, abs.tol = 0)$value / ((1 - alphalower) *
                                                                   exp(rs[2] * Time))
}


# if not vectorize: evaluation of function gave a result of wrong length
P2_thresh_unc = function(Pstar, alphalower, alphaB  = alphas[2]) {
  temp = function(x) {
    util2_B_cont_unc(x,
                     Pstar = Pstar,
                     alphalower = alphalower,
                     alphaB = alphaB) - util2_B_stop(x)
  }
  uniroot.all(
    Vectorize(temp),
    lower = 0.01,
    upper = 999,
    maxiter = 99999,
    n = 9999
  )
}


util1_A_cont_unc = function(Pstar,
                            pt1 = P1,
                            alphalower,
                            alphaA = alphas[1]) {
  Time = taua # time until next step
  
  foo = function(alphaB) {
    pt2threshv = P2_thresh_unc(Pstar, alphalower, alphaB)
    
    temp = function(pt2) {
      gbmpdf(pt2, pt1, Time) * util2_A_cont(pt2, Pstar, alphaA)
    }
    
    if (length(pt2threshv) == 0) {
      # alphaB too small, Bob will never swap anyway.
      util2_A_stop(Pstar)
    } else{
      probBobwaive = (1 - gbmcdf(pt2threshv[2], pt1, Time) + gbmcdf(pt2threshv[1], pt1, Time))
      
      util2_A = integrate(Vectorize(temp),
                          pt2threshv[1],
                          pt2threshv[2])$value + probBobwaive * util2_A_stop(Pstar)
      
      util2_A
    }
  }
  
  integrate(Vectorize(foo),
            0,
            1)$value / ((1 - 0) * exp(rs[1] * Time))
}


alphal = function(Pstar) {
  temp = function(alphalower) {
    util1_A_cont_unc(Pstar, alphalower = alphalower, alphaA = alphalower) - util1_A_stop(Pstar)
  }
  uniroot(Vectorize(temp), c(0.0001, 0.9))
}



sucrate_unc = function(Pstar,
                       alphaA = alphas[1],
                       alphaB = alphas[2],
                       alpha_lower = NULL) {
  if (is.null(alpha_lower)) {
    alpha_lower = alphal(Pstar)
  }
  pt3threshv = P3_lower(Pstar, alphaA)
  int_pt2 = function(pt2) {
    gbmpdf(pt2, P1, taua) * (1 - gbmcdf(pt3threshv, pt2, taub))
  }
  pt2threshv = P2_thresh_unc(Pstar, alphalower, alphaB)
  integrate(Vectorize(int_pt2),
            pt2threshv[1],
            pt2threshv[2])$value
}


## collateral ----

P3_lower_col = function(Pstar, alphaA = alphas[1], colla) {
  exp((rs[1] - mu) * taub) / (1 + alphaA) * max(Pstar /  exp(rs[1] * (taueps +
                                                                        2 * taua)) - colla / exp(rs[1] * (taueps + taua)), 0)
}



## util2 ----
## expected utility of Alice at t_2 if Bob continues
util2_A_cont_col = function(pt2, Pstar, alphaA = alphas[1], colla) {
  pt3threshv = P3_lower_col(Pstar, alphaA, colla)
  Time = taub # time until next step
  
  temp = function(pt3) {
    gbmpdf(pt3, pt2, Time) * (util3_A_cont(pt3, alphaA) + colla / exp(rs[1] * (taueps + taua)))
  }
  util3_A = integrate(Vectorize(temp),
                      pt3threshv,
                      Inf)$value +
    gbmcdf(pt3threshv, pt2, Time) * util3_A_stop(Pstar)
  
  util3_A / exp(rs[1] * Time)
}


# expected utility for Bob if continue
util2_B_cont_col = function(pt2, Pstar, alphaB = alphas[2], colla) {
  pt3threshv = P3_lower(Pstar, alphaA = alphas[1])
  Time = taub # time until next step
  
  temp = function(pt3) {
    gbmpdf(pt3, pt2, Time) * (util3_B_stop(pt3) + colla / exp(rs[2] * (taueps + taua)))
  }
  util3_B = (1 - gbmcdf(pt3threshv, pt2, Time)) * util3_B_cont(Pstar, alphaB) +
    integrate(Vectorize(temp),
              0,
              pt3threshv)$value + colla / exp(rs[2] * taua)
  
  util3_B / exp(rs[2] * Time)
}

P2thresh_col = function(Pstar, alphaB = alphas[2], colla) {
  temp = function(x) {
    util2_B_cont_col(x, Pstar, alphaB = alphaB, colla = colla) - util2_B_stop(x)
  }
  uniroot.all(
    Vectorize(temp),
    lower = 0.001,
    upper = 999,
    maxiter = 99999,
    n = 9999
  )
}


util1_A_cont_col = function(Pstar,
                            pt1 = P1,
                            alphaA = alphas[1],
                            alphaB = alphas[2],
                            colla) {
  pt2threshv = P2thresh_col(Pstar, alphaB = alphaB, colla = colla)
  Time = taua # time until next step
  temp = function(pt2) {
    gbmpdf(pt2, pt1, Time) * util2_A_cont_col(pt2, Pstar, alphaA, colla)
  }
  
  if (length(pt2threshv) != 2) {
    pt2threshv = union(1e-4, pt2threshv)
  }
  
  
  utilt2_A_cont_v  = 0
  probBobcont = 0
  
  # integrate over all sets that make U_continue > U_waive
  for (bound_ind in seq(1, length(pt2threshv), by = 2)) {
    # Alice's utility at t3 if Bob continues, gives terribly wrong answer if omitting abs.tol
    utilt2_A_cont_v = utilt2_A_cont_v + integrate(Vectorize(temp), pt2threshv[bound_ind], pt2threshv[bound_ind +
                                                                                                       1], abs.tol = 0)$value
    probBobcont = probBobcont + (gbmcdf(pt2threshv[bound_ind + 1], pt1, Time) - gbmcdf(pt2threshv[bound_ind], pt1, Time))
  }
  
  probBobwaive = 1 - probBobcont
  
  util2_A = utilt2_A_cont_v + probBobwaive * (util2_A_stop(Pstar) + 2 *
                                                colla / exp(rs[1] * (taub + taua)))
  
  util2_A / exp(rs[1] * Time)
}


# expected utility for Bob if continue
util1_B_cont_col = function(Pstar,
                            pt1 = P1,
                            alphaB = alphas[2],
                            colla) {
  temp = function(pt2) {
    gbmpdf(pt2, pt1, taua) * pmax(util2_B_cont_col(pt2, Pstar, alphaB, colla), pt2)
  }
  integrate(Vectorize(temp), 0, Inf, abs.tol = 0)$value
}



sucrate = function(Pstar,
                   alphaA = alphas[1],
                   alphaB = alphas[2],
                   colla) {
  pt2threshv = P2thresh_col(Pstar, alphaB = alphaB, colla = colla)
  pt3threshv = P3_lower_col(Pstar, alphaA = alphaA, colla = colla)
  
  temp = function(pt2) {
    gbmpdf(pt2, P1, taua) * (1 - gbmcdf(pt3threshv, pt2, taub))
  }
  
  if (length(pt2threshv) != 2) {
    pt2threshv = union(1e-4, pt2threshv)
  }
  
  probcont = 0
  
  # integrate over all sets that make U_continue > U_waive
  for (bound_ind in seq(1, length(pt2threshv), by = 2)) {
    # Alice's utility at t3 if Bob continues, gives terribly wrong answer if omitting abs.tol
    probcont = probcont + integrate(Vectorize(temp), pt2threshv[bound_ind], pt2threshv[bound_ind +
                                                                                         1], abs.tol = 0)$value
  }
  
  probcont
  
}






# sucrate_unc = function(Pstar, alpha_lower = NULL){
#   if(is.null(alpha_lower)){
#     alpha_lower = alphal(Pstar)
#   }
#
#   int_alphaB = function(alphaB){
#   int_alphaA = function(alphaA){
#     pt3threshv = P3_lower(Pstar, alphaA)
#     int_pt2 = function(pt2){
#       gbmpdf(pt2, P1, taua) * (1-gbmcdf(pt3threshv, pt2, taub))
#     }
#     pt2threshv = P2_thresh(Pstar, alphaB)
#     integrate(Vectorize(int_pt2), pt2threshv[1], pt2threshv[2]
#               # , abs.tol = 0
#               )$value
#   }
#   integrate(Vectorize(int_alphaA), alpha_lower+0.001, 1)$value
#   }
#   integrate(Vectorize(int_alphaB), 0, 1)$value/(1-alpha_lower)
# }
