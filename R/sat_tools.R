code_yn <- function(x) { 
  x <- as.character(x)
  x [x == "1"] <- "Y"
  x [x == "0"] <- "N"
  return(x)
}

trim_num <- function(x, floor, ceiling){
  x[x < floor] <- floor
  x[x > ceiling] <- ceiling
  return(x)
}

scale_score_to_sat <- function(x, subject = c("read", "math", "total")) {
  samp_score_w <- rnorm(10000, mean = 533, sd = 100)
  samp_score_w <- trim_num(samp_score_w, 200, 800)
  samp_score_w <- round(samp_score_w, digits = 0)
  
  samp_score_m <- rnorm(10000, mean = 527, sd = 107)
  samp_score_m <- trim_num(samp_score_m, 200, 800)
  samp_score_m <- round(samp_score_m, digits = 0)
  
  samp_score_t <- rnorm(10000, mean = 1060, sd = 195)
  samp_score_t <- trim_num(samp_score_t, 400, 1600)
  samp_score_t <- round(samp_score_t, digits = 0)
  
  if (subject == "read") {
    rx <- equate::freqtab(samp_score_w)
  } else if (subject == "math") {
    rx <- equate::freqtab(samp_score_m)
  } else if (subject == "total") {
    rx <- equate::freqtab(samp_score_t)
  }
  
  ry <- equate::freqtab(round(x, digits = 0))
  ## Equate the new score with the simulated SAT score
  zzz <- equate::equate(ry, rx, type = "equipercentile", boot = TRUE, reps = 5)
  new_score <- equate::equate(x, y = zzz)
  new_score <- round(new_score, digits = 0)
  return(new_score)
}




compute_subscores <- function(x, scale = c(15L, 40L, 8L)) { 
  examp_score_40 <- round(rnorm(10000, 20, 5.25), 0)
  examp_score_40 <- trim_num(examp_score_40, floor = 10, ceiling = 40)
  examp_score_15 <- round(rnorm(10000, 8, 2.25), 0)
  examp_score_15 <- trim_num(examp_score_15, floor = 1, ceiling = 15)
  
  examp_score_8 <- rpois(10000, 5)
  examp_score_8 <- trim_num(examp_score_15, floor = 0, ceiling = 8)
  examp_score_8[examp_score_8 == 1] <- sample(c(0, 2), 
                                              length(examp_score_8[examp_score_8 == 1]), 
                                              replace = TRUE)
  
  ftab_obs <- equate::freqtab(x)
  
  if(scale == 40) {
    ftab_40 <- equate::freqtab(examp_score_40)
    eq_40 <- equate::equate(ftab_obs, ftab_40, type = "equipercentile", 
                            boot = TRUE, reps = 5)
    out <- equate::equate(sapply(x, fuzz_score, fuzz = 100), y = eq_40)
    out <- trim_num(out, 10, 40)
  } else if (scale == 15) {
    ftab_15 <- equate::freqtab(examp_score_15)
    eq_15 <- equate::equate(ftab_obs, ftab_15, type = "equipercentile", 
                            boot = TRUE, reps = 5)
    out <- equate::equate(sapply(x, fuzz_score, fuzz = 100), y = eq_15)
    out <- trim_num(out, 1, 15)
  } else if (scale == 8) {
    ftab_8 <- equate::freqtab(examp_score_8)
    eq_8 <- equate::equate(ftab_obs, ftab_8, type = "equipercentile", 
                           boot = TRUE, reps = 5)
    out <- equate::equate(sapply(x, fuzz_score, fuzz = 100), y = eq_8)
    out <- trim_num(out, 0, 8)
  }
  
  out <- round(out, digits = 0)
  return(out)
}

fuzz_score <- function(x, fuzz) {
  samp_seq <- seq(x - fuzz, x + fuzz, by = 1)
  x <- sample(samp_seq, 1)
  return(x)
}
