
if (!requireNamespace("BiocManager"))
    install.packages("BiocManager")
BiocManager::install(ask=FALSE)
BiocManager::install(c("ALDEx2","gplots","ggplot2","rjsonapi","data.table"), ask=FALSE)
