
# carrega library
library(survey)
# carrega dados
library(anamco)
popul_dat <- popul
N <- nrow(popul_dat)
n1 <- 30
n2 <- 30
nh = c(n1, n2)
n <- sum(nh)
Nh <- table(popul_dat$estrat)
fh <- nh/Nh
Wh <- Nh/N
f <- n/N
popul_dat$sal <- popul_dat$sal/1000
popul_dat$rec <- popul_dat$rec/1e+06
library(sampling)
# define espaços para salvar resultados
est_aas <- c(0, 0)
est_aes <- c(0, 0)
cov_mat_aas_est <- matrix(0, 2, 2)
cov_mat_aes_est <- matrix(0, 2, 2)
set.seed(123)
# gera amostras com dois estratos de tamanho 30
for (i in 1:500) {
  s <- strata(popul_dat, "estrat", c(30, 30), method = "srswor")
  dados <- getdata(popul_dat, s)
  # média amostral de salário e de receita
  est_aas <- est_aas + c(mean(dados$sal), mean(dados$rec))
  # estimador v0
  cov_mat_aas_est <- cov_mat_aas_est + (1 - f) * cov(cbind(dados$sal, 
    dados$rec))/n
  
  # vhat_aes estimador não-viciado
  popul_plan <- svydesign(~1, strata = ~estrat, data = dados, 
    fpc = ~Prob)
  # estimador não-viciado da média de salario e receita
  sal_rec_aes_est <- svymean(~sal + rec, popul_plan)
  est_aes <- est_aes + coef(sal_rec_aes_est)
  cov_mat_aes_est <- cov_mat_aes_est + attr(sal_rec_aes_est, 
    "var")
}

# média populacional

med_pop <- round(c(mean(popul_dat$sal), mean(popul_dat$rec)),3)


# Calcula médias das estimativas na simulação

## Média das estimativas pontuais para as 500 amostras aas
mean_est_aas <- round(est_aas/500,3)
mean_est_aas

## Média das estimativas pontuais para as 500 amostras aes
mean_est_aes <- round(est_aes/500,3)
mean_est_aes

# Média das estimativas de matriz de covariância para as 500
# amostras aas
mean_cov_mat_aas_est <- round(cov_mat_aas_est/500, 3)
mean_cov_mat_aas_est

# Média das estimativas de matriz de covariância para as 500
# amostras aes
mean_cov_mat_aes_est <- round(cov_mat_aes_est/500, 3)
mean_cov_mat_aes_est


## Matriz de covariância populacional
mat_cov_pop <- by(popul_dat, popul_dat$estrat, function(t) var(cbind(t$sal, 
  t$rec)))
 


## Matriz de covariância considerando o plano amostral
## verdadeiro
mat_cov_aleat_verd <- (Wh[1]^2 * (1 - fh[1])/nh[1]) * mat_cov_pop[[1]] + 
  (Wh[2]^2 * (1 - fh[2])/nh[2]) * mat_cov_pop[[2]]
mat_cov_aleat_verd <- round(mat_cov_aleat_verd,3)


## estimativa de efeitos generalizados do plano amostral
DELTA = solve(mean_cov_mat_aas_est) %*% mean_cov_mat_aes_est
epa <-round(eigen(DELTA)$values,3)

