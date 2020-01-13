# this file shows how to set keyboard shortcuts in RStudio

install.packages('remotes')
remotes::install_github('yonicd/rsam')
library(rsam)

temp <- dplyr::as_tibble(fetch_addins())
temp$Binding

key.p <- KEYS$`left command/window key` + KEYS$shift + KEYS$p
set_shortcut(fn = 'blogdown::serve_site',shortcut = key.p)

key.l <- KEYS$`left command/window key` + KEYS$shift + KEYS$l
set_shortcut(fn = 'blogdown::new_post_addin',shortcut = key.l)
