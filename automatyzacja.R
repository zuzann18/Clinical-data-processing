tabela_wynikowa_tylko_ogol<-function(df, # baza danych
                                     zmienne, # nazwa kolumn w bazie dla ktorych robic wyniki
                                     wyjatki, # nazwy kolumn znajduj?ce si? w 'zmienne', kt?re maj? klas? integer lub numeric, ale chcemy, ?eby traktowa? je jak factor
                                     type="short",
                                     dec = ",", #znak dziesi?tny
				zaokraglenia=2
){
  
  wyniki<-as.data.frame(NULL)

  require(psych)
  #require(plyr)
  
  for(zmienna in zmienne){
   # print(zmienna)
    id_zmienna<-match(zmienna, names(df))
    if(class(df[[id_zmienna]]) %in% c("factor", "character") || zmienna %in% wyjatki){
      df[[id_zmienna]]<-as.factor(df[[id_zmienna]])
      tabela_ogol<-as.data.frame(table(df[[id_zmienna]]))
      procent_ogol<-as.data.frame(prop.table(table(df[[id_zmienna]])))
      wynik_ogol<-data.frame(wartosc=levels(df[[id_zmienna]]), "Ogółem"=sub("\\.", dec, paste0(round(procent_ogol$Freq*100, 1), "% (N=", tabela_ogol$Freq, ")")))
 
      tabela_wynik<-wynik_ogol
      
      output<-data.frame(zmienna, tabela_wynik, stringsAsFactors=FALSE)
      rownames(output)<-NULL
      output[2:nrow(output),c("zmienna")]<-""
      
    }else if(class(df[[id_zmienna]])=="integer" || class(df[[id_zmienna]])=="numeric"){
    
      
      if(type=="long"){
        tabela_ogol<-matrix(NA, nrow=8, ncol=1)
        rozklad=describe(df[[id_zmienna]])
        tabela_ogol[1,1]<-sub("\\.", dec, rozklad$n)
        tabela_ogol[2,1]<-sub("\\.", dec, round(rozklad$mean,zaokraglenia))
        tabela_ogol[3,1]<-sub("\\.", dec, round(rozklad$sd,zaokraglenia))
        tabela_ogol[4,1]<-sub("\\.", dec, round(quantile(df[[id_zmienna]], probs = 0.25, na.rm = TRUE),zaokraglenia))
        tabela_ogol[5,1]<-sub("\\.", dec, round(rozklad$median,zaokraglenia))
        tabela_ogol[6,1]<-sub("\\.", dec, round(quantile(df[[id_zmienna]], probs = 0.75, na.rm = TRUE),zaokraglenia))
        tabela_ogol[7,1]<-sub("\\.", dec, round(rozklad$min,zaokraglenia))
        tabela_ogol[8,1]<-sub("\\.", dec, round(rozklad$max,zaokraglenia))
        rownames(tabela_ogol)<-c("N", "Średnia", "Odchylenie standardowe", "Dolny kwartyl", "Mediana", "Górny kwartyl", "Minimum", "Maksimum") 
      }else if(type=="short"){
        tabela_ogol<-matrix(NA, nrow=4, ncol=1)
        rozklad=describe(df[[id_zmienna]])
        tabela_ogol[1,1]<-sub("\\.", dec, rozklad$n)
        tabela_ogol[2,1]<-paste0(sub("\\.", dec, round(rozklad$mean,zaokraglenia)), " (", sub("\\.", dec, round(rozklad$sd,zaokraglenia)), ")")
        tabela_ogol[3,1]<-paste0(sub("\\.", dec, round(rozklad$median,zaokraglenia)), " (", sub("\\.", dec, round(quantile(df[[id_zmienna]], probs = 0.25, na.rm = TRUE),zaokraglenia)), " - ", sub("\\.", dec, round(quantile(df[[id_zmienna]], probs = 0.75, na.rm = TRUE),zaokraglenia)), ")")
        tabela_ogol[4,1]<-paste0(sub("\\.", dec, round(rozklad$min,zaokraglenia)), " - ", sub("\\.", dec, round(rozklad$max,zaokraglenia)))
        rownames(tabela_ogol)<-c("N", "Średnia (SD)", "Mediana (IQR)", "Zakres") 
      }
    
      nazwy<-c("Ogółem")
      tabela<-cbind(tabela_ogol)
      
      colnames(tabela)<-nazwy
      output<-data.frame(zmienna, rownames(tabela), tabela, stringsAsFactors=FALSE)
      rownames(output)<-NULL
      output[2:nrow(output),c("zmienna")]<-""
      
    }else{
      print(paste0(zmienna, " nie łapie się do skryptu z powodu nastepującej klasy: "))
      stop(class(df[[id_zmienna]]))
    }
    
    for(i in seq_along(output)){
      colnames(output)[i] = paste0('V', i)
    }
    wyniki<-rbind(wyniki, output)
  }
  
  nazwa_ogolem<-paste0("Ogółem (N=", nrow(df), ")")
  colnames(wyniki)<-c("Zmienna","Parametr",nazwa_ogolem)

  return(wyniki)
}
