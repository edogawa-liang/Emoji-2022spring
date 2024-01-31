PATH_from= "AllData/crawler/upload/alreadyclean/" 
PATH_go= "AllData/emojiclean/"


gogoFB <- function(startID, endID){
  
  df <- data.frame(FileID=0, n=0, Note=NA) #預設
  s <- 1
  
  for (id in startID:endID) {
    #匯入檔案
    data_re <- paste("FBreply_", id, ".xlsx", sep = "")
    data_po <- paste("FBpost_", id, ".xlsx", sep = "")
    
    data_re <- read.xlsx(paste(PATH_from, data_re, sep=''), colNames = F)
    data_po <- read.xlsx(paste(PATH_from, data_po, sep=''), colNames = F)
    
    #執行reply
    clean_re <- cleanclean(id, data_re, 5)
    write.xlsx(clean_re, paste(PATH_go, id, '.xlsx', sep =''))
    
    #執行post
    clean_po<- cleanclean(1000+ id, data_po, 5)
    write.xlsx(clean_po, paste(PATH_go, 1000+id ,'.xlsx', sep =''))
    
    #寫到data.frame
    df[s, 1] <- id
    df[s, 2] <- length(row.names(clean_re)) + length(row.names(clean_po))
    if (length(row.names(clean_po)) == 0){
      df[s, 3] <- paste("File", id+1000, "has no data.")
    }
    s <- s + 1
  }
  write.xlsx(df, paste(PATH_go, startID, '_', endID, '.xlsx', sep =''))
}
gogoFB(816, 818)


gogoIG <- function(startID, endID){
  
  df <- data.frame(FileID=0, n=0, Note=NA) #預設
  s <- 1
  
  for (id in startID:endID) {
   
    #匯入檔案
    data_po <- paste("IG_", id, ".xlsx", sep = "")
    data_po <- read.xlsx(paste(PATH_from, data_po, sep=''), colNames = F)
    
    #執行post
    clean_po<- cleanclean(id, data_po, 4)
    write.xlsx(clean_po, paste(PATH_go, id, '.xlsx', sep =''))
    
    #寫到data.frame
    df[s, 1] <- id
    df[s, 2] <- length(row.names(clean_po))
    s <- s + 1
  }
  write.xlsx(df, paste(PATH_go, startID, '_', endID, '.xlsx', sep =''))
}
gogoIG(812, 815)


gogoLINE <- function(startID, endID){
  
  df <- data.frame(FileID=0, n=0, Note=NA) #預設
  s <- 1
  
  for (id in startID:endID) {

    #匯入檔案
    data_po <- paste("line", id, ".xlsx", sep = "")
    data_po <- read.xlsx(paste(PATH_from, data_po, sep=''), colNames = F)
    
    #執行post
    clean_po<- cleanclean(id, data_po, 2)
    write.xlsx(clean_po, paste(PATH_go, id, '.xlsx', sep =''))
    
    #寫到data.frame
    df[s, 1] <- id
    df[s, 2] <- length(row.names(clean_po))
    s <- s + 1
  }
  write.xlsx(df, paste(PATH_go, startID, '_', endID, '.xlsx', sep =''))
}



PATH_from= "AllData/line_crawler/"
gogoLINE(280, 283)









#--------------------------------------------------------------------
gogoFBbind <- function(startID, endID){
  
  df <- data.frame(FileID=0, n=0, Note=NA) #預設
  s <- 1
  
  for (id in startID:endID) {
    #匯入檔案
    data_re <- paste("FB_", id, ".xlsx", sep = "")
    
    data_re <- read.xlsx(paste(PATH_from, data_re, sep=''), colNames = F)
    
    #執行reply
    clean_re <- cleanclean(id, data_re, 5)
    write.xlsx(clean_re, paste(PATH_go, id, '.xlsx', sep =''))
    
    
    #寫到data.frame
    df[s, 1] <- id
    df[s, 2] <- length(row.names(clean_re))
    s <- s + 1
  }
  write.xlsx(df, paste(PATH_go, startID, '_', endID, '.xlsx', sep =''))
}
gogoFBbind(816, 818)

