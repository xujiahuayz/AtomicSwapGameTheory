library(magrittr)
library(data.table)
library(dplyr)
# library(readr)
# library(mvtnorm)
library(VGAM)
library(rootSolve)


filerootpath = '/home/jxu/AtomicSwapGameTheory/'

getwd()

source(paste0(filerootpath,'functions.R'))

source(paste0(filerootpath,'DefaultValues.R'))

util1_A_unknx_v = Vectorize(util1_A_unknx)(Pstars)

save(util1_A_unknx_v,
     file = paste0(filerootpath,'data/util1_A_unknx_v.rda'))
