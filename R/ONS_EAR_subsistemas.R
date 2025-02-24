#' Dados históricos de Energia Armazenada (EAR) por subsistema segundo a ONS
#'
#' @export
#' @param ano_inicial Ano inicial do registro. Série histórica tem início no ano 2000.
#' @param ano_final Ano final do registro. Pode deixar em branco para retornar a data de registro mais recente.
#'
#' @examples
#' ONS_EAR_subsistemas(ano_inicial=2000, ano_final=format(Sys.Date(), "%Y"))


ONS_EAR_subsistemas <- function(ano_inicial=2000, ano_final=format(Sys.Date(), "%Y")){

  if(ano_inicial < 2000|
     ano_final > format(Sys.Date(), "%Y")){
    message("Escolha um ano inicial igual ou maior que 2000 e um ano final igual ou menor que ", format(Sys.Date(), "%Y"))
  }else{

  anos <- seq(ano_inicial,ano_final)

  message("Buscando dados diários de ", ano_inicial, " até ", ano_final, "...")

  historico <- list()

  for (i in anos) {
    dados_ons <- utils::read.csv(glue::glue("https://ons-dl-prod-opendata.s3.amazonaws.com/dataset/ear_subsistema_di/EAR_DIARIO_SUBSISTEMA_{i}.csv"),sep = ";")
    historico[[i]] <- dados_ons
  }

  historico_ear <- do.call(rbind, historico)

  message("Organizando os dados...")

  historico_ear_clean <- historico_ear %>%
    dplyr::mutate(subsistema = dplyr::recode(id_subsistema,
                                      N = "Norte",
                                      NE = "Nordeste",
                                      SE = "Sudeste / Centro-Oeste",
                                      S = "Sul")) %>%
    dplyr::select(-id_subsistema, -nom_subsistema) %>%
    dplyr::rename(data_medicao = ear_data,
                  ear_max_subsistema_mwmes = ear_max_subsistema) %>%
    dplyr::select(data_medicao, subsistema, ear_max_subsistema_mwmes, ear_verif_subsistema_mwmes, ear_verif_subsistema_percentual)

  historico_ear_clean$data_medicao <- as.Date(historico_ear_clean$data_medicao)

  return(historico_ear_clean)

  }
}
