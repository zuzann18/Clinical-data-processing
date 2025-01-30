# tabela_logit <- function(model)
# {
#   OR <- exp(coefficients(summary(model))[,1])
#   CONF <- exp(confint(model))
#   P <- coefficients(summary(model))[,4]
#   tabela <- cbind(OR,CONF,P)
#   
#   tabela <- round(tabela,3)
#   
#   return(tabela)
# } dodać to potem do ogólnej


#zaokr może być np. signif,logit=T; daje oddsratio,ufn=F, gdy confidenty się wolno wczytują
tabela <- function(model,zaokr=round,logit=F,ufn=T)
{
  if("polr" %in% class(model)){
    summary_table <- coef(summary(model))
    pval <- pnorm(abs(summary_table[, "t value"]),lower.tail = FALSE)* 2
    summary_table <- cbind(summary_table, "p value" = round(pval,3))
    x <- summary_table}
  # print("weszlo")
  else{x <- summary(model)}
  #Ustawienie parametrów
  
  typ=class(model)
  
  if(("glm" %in% typ) | ("lm" %in% typ))
    typ="glm"
  if(typ=="lmerModLmerTest") typ="lmer"
  if(typ=="polr") typ="polr"
  
  id_wsp <- names(x)[grep("coefficients",names(x))]
  if(length(id_wsp)!=1)
  {
    if(id_wsp>1)
    {
      stop("W nazwach summary(modelu) jest więcej niż jedno 'coefficients'")
    }
    else if(id_wsp==0)
    {
      id_wsp <- names(x)[grep("coef",names(x))]
      if(id_wsp>1)
      {
        stop("W nazwach summary(modelu) nie ma 'coefficients' i jest więcej niż jedna nazwa zawierająca 'coef'")
      }
      else if(id_wsp<1)
      {
        stop("W nazwach summary(modelu) nie ma 'coefficients' i nie ma nazw zawierających 'coef'")
      }
      else if(id_wsp==1)
      {
        warning("W nazwach summary(modelu) nie ma 'coefficients', ale jest jedna (którą wybrano) nazwa zawierająca 'coef'")
      }
    }
  }
  
  
  # id_wsp <- ifelse(typ %in% c("glm"),12,ifelse(typ %in% c("lm"),4,ifelse(typ %in% c("lmer","glmerMod"),10,ifelse(typ %in% c("polr"),4,1)))) #1 dla "clmm"
  id_p <- ifelse(typ %in% c("lmer"),5,4) #
  change_conf <- ifelse((("lmer" %in% typ) | ("glmer" %in% typ) | ("glmerMod" %in% typ)),T,F)
  #Parametry tabeli-numeric
  # print(id_p)
  if(typ=="polr"){
    Współczynnik <- x[,1]
    `p-wartość` <- x[,4] 
  }
  else{
    Współczynnik <- x[[id_wsp]][,1]
    `p-wartość` <- x[[id_wsp]][,id_p] 
  }
  if(ufn==T)
  {CONF <- confint(model)
  if(change_conf==T)
  {
    # print("OK")
    from <- which(rownames(confint(model))=="(Intercept)")
    # print(from)
    CONF <- CONF[from:nrow(CONF),]
  }
  }
  if(logit==T)
  {
    if(ufn==T) CONF <- exp(CONF)
    Współczynnik <- exp(Współczynnik)
  }
  if(ufn==T) CONF <- zaokr(CONF,3)
  #Parametry tabeli-character
  Współczynnik <- gsub("\\.","\\.",zaokr(Współczynnik,3))
  `p-wartość` <- ifelse(`p-wartość`<0.001,"**<0.001**", ifelse(`p-wartość`<0.05, gsub("\\.","\\.",paste("**",round(`p-wartość`,3), "**")), gsub("\\.","\\.",round(`p-wartość`,3))))
  SUB <- function(x)
  {
    x <- gsub("\\.","\\.",x)
    return(x)
  }
  
  # print(apply(CONF,2,SUB))
  if(ufn==T) 
  {
    CONF <- apply(CONF,2,SUB) #czemu nie działa?
   # print(CONF)
   #  
    Coefficient<-Współczynnik
    `p-value` <- `p-wartość`
       # else CONF <- as.matrix(cbind(1:length(`p-wartość`),1:length(`p-wartość`)))
  tabela <- cbind(Coefficient,CONF,`p-value`)}
  else tabela <- cbind(Coefficient,`p-value`)
  return(tabela)
}

