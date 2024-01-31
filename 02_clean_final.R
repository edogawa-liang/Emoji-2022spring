#---------------目的--------------------#

# 1. 一筆資料中，好幾句各自配對不同表情符號，拆成多筆資料
## ex: 天氣真好xd你好嗎^^ : 天氣真好xd、你好嗎^^

# 2. if 同一句有多個表情符號，變成多筆資料
## ex: 天氣真好xd^^ : 天氣真好xd、 天氣真好xd^^

# 3. 只取表情符號的前一句話
## ex: 天氣真好，你好嗎xd : 你好嗎xd

# 4. if 同一句有多個相同表情符號，只留下一筆
## ex: 天氣真好xdxd : 天氣真好xd

# 5. if content欄只有表情符號，刪掉那筆資料

# 6. content欄只留下中文字

# 7. 簡體轉繁體(python opencc 套件)



#------------------------開始---------------------#
#rm(list=ls())
library(emoji)
library(openxlsx)
library(stringr)


# 斷句 function : 遇到表情符號就切斷 (不管逗號，遇到表情就切!)
cutcut<- function(use, number){
  
  emoji_loc<- emoji_locate_all(use$content[number])[[1]]
  df<- data.frame(ID= 0, content= 0, emoji= 0)
  remain= use$content[number]
  
  # 句子中只有一個表情符號:if、 多個表情符號:else
  if(nrow(emoji_loc)== 1){
    con<- substr(remain, 1, emoji_loc[1, 1]- 1)
    df1<- cbind(ID= use$ID[number], content= con, emoji= use$emoji[number][[1]][1,])
    df<- rbind(df, df1)
    
  }else{
    for(i in 1:(nrow(emoji_loc)- 1)){
      if(i== 1){
        # 第一個字抓到第一個表情符號前 (最後-1: 不包含表情符號)
        con<- substr(remain, 1, emoji_loc[i, 1]- 1)
        
        # 斷完第一個表情後，剩下的句子 (最後-1: 不包含表情符號)
        remain<- substr(remain, emoji_loc[i, 2]+ 1, emoji_loc[nrow(emoji_loc), 1]- 1)
        
      }else{
        # 因遇到表情就斷一次，要扣掉上一句含表情的句子 (最後-1: 不包含表情符號)
        con<- substr(remain, 1, emoji_loc[i, 1]- emoji_loc[i- 1, 2]- 1)
        
        # 因遇到表情就斷一次，每次斷的位置要調整 (最後-1: 不包含表情符號)
        remain<- substr(remain, emoji_loc[i, 2]- emoji_loc[i- 1, 2]+ 1, emoji_loc[nrow(emoji_loc), 1]- emoji_loc[i- 1, 2]- 1)
      }
      
      df1<- cbind(ID= use$ID[number], content= con, emoji= use$emoji[number][[1]][i,])
      df<- rbind(df, df1)
    }
    
    # 加上最後一個表情符號列
    df2<- cbind(ID= use$ID[number], content= remain, emoji= use$emoji[number][[1]][nrow(emoji_loc), ])
    df<- rbind(df, df2)
  }
  
  df<- df[-1,]
  
  # 若一句話後連續接2種以上表情，再重複1次前一句話
  repeatt<- which(df[, 2]== ',')
  for(i in repeatt){
    df[i, 2]<- df[i- 1, 2]
  }
  
  # 取出表情斷句後，句子中的最後一句話
  for(i in 1: nrow(df)){
    comma<- gregexpr(",", df[i, 2])[[1]] 
    if(length(comma)== 1){
      df[i, 2]<- substr(df[i, 2], 1, comma- 1)
    }else{
      use_comma<- tail(comma, 2)
      df[i, 2]<- substr(df[i, 2], use_comma[1]+ 1, use_comma[2]- 1)
    }
  }
  return(df)
}



# 整理funcition
cleanclean<- function(dataID, data, content_row){
  
  # 1. 設ID、欄位留下: ID、content、emoji
  obs<-  str_pad(data$X1, 4, side = "left", "0") #流水號
  ID<- paste(rep(dataID, length(obs)), obs, sep='') #ID= dataID+流水號
  use<- data.frame(ID)
  use<- cbind(use, content= data[, content_row])  # 留下content
  use$emoji <- emoji_match_all(use$content)  # 把表情符號抓出來
  
  # 2. 刪除內容是NA的列
  na<- which(is.na(use$content))    
  if(length(na)!=0){
    use<- use[-na,]
  }

  # 3~6步驟: 包在for迴圈內逐筆計算:
  final_df<- data.frame(ID= 0, content= 0, emoji= 0) # 第六步斷句使用
  for (i in 1:nrow(use)){
    
    # 3. 刪除內容沒有表情符號的列
    if(identical(use$emoji[[i]][,1], character(0))){
      next
    }
    
    # 4. 刪除內容欄只有表情符號 或 「只有第一個位置」有表情符號的句子(目的5)
    emoji_loc<- emoji_locate_all(use$content[[i]])[[1]]
    ## 大前提: 第一個位置是表情符號
    if(emoji_loc[1, 1]== 1){
      
      ## 若只有一個表情符號 (包含資料只有一個表情符號 & 只有第一個位置有表情符號的句子)
      if(nrow(emoji_loc)== 1){
        next
      }
      ## 資料不只一個表情符號，有連續表情符號的數目= 偵測到的所有表情數目
      else{
        emo<- 1
        for(j in 1:(nrow(emoji_loc)- 1)){
          emo<- append(emo, j[emoji_loc[j, 2]+ 2== emoji_loc[j+ 1, 1]]+ 1)
        }
        if(length(emo)== length(use$emoji[[i]])){
          next
        }
      }
    }
    
    # 5. if 最開頭是表情符號，把表情刪掉
    if(emoji_loc[1, 1]== 1){
      beg_emo<- 1   # 因為最開頭的一定是表情，從1開始append
      for(k in 1:(nrow(emoji_loc)- 1)){
        # if 表情符號的end位置+ 2= 下一個表情符號的start位置，即連續的表情符號  (+ 2 :中間的逗號)
        beg_emo<- append(beg_emo, k[emoji_loc[k, 2]+ 2== emoji_loc[k+ 1, 1]]+ 1)
      }
      
      # 表情符號需是連續開頭，才會刪掉
      beg_emo<- which(1:length(beg_emo)== beg_emo)
      
      # 改content欄 (把前面emoji刪掉)
      newstart<- emoji_loc[tail(beg_emo, 1), 2]+ 2  #(+ 2 :中間的逗號)
      use$content[i]<- substr(use$content[i], newstart, nchar(use$content[i]))
      
      # 改emoji欄
      use$emoji[i]<- emoji_match_all(use$content[i])
    }
    
    # 6. 斷句(目的1~3)、將結果建立新的df   (使用斷句fun: cutcut)
    result<- cutcut(use, i)
    final_df<- rbind(final_df, result)
    
  }
  final_df<- final_df[-1,]
  
  # 7. 刪除重複的資料(目的4)
  final_df<- unique(final_df)
  
  # 8. 刪除有逗號的句子(少部分表情符號被認成字元，造成後續抓句錯誤才有逗號)
  wrong<- which(str_detect(final_df$content, pattern = ",", negate = FALSE))
  if(length(wrong)!= 0){
    final_df<- final_df[-wrong,] 
  }

  # 9. 若有表情符號被當成字元的，刪掉(只留文字部分)
  pattern<- "[^\u4e00-\u9fa5]+"
  sentence<- grep(pattern, final_df$content)
  if(length(sentence)!= 0){
    final_df<- final_df[-sentence,] 
  }
  
  return(final_df)
}


#---------想一次跑全部的話接著執行大福的程式! toooooooooogether.R--------------#



#----------------------跑單筆-------------------------#

# 注意填對dataID! (post第一碼補1)

# EX: 爬蟲ID= 213、聊天紀錄ID= 214
# post: 1213xxxx (8碼）
# reply: 213xxxx (7碼）
# 聊天記錄：214xxxx (7碼）


# 資料名稱 & ID (確定post有加1喔喔喔喔!!!)
import_data= "IG_251.xlsx"
dataID= 251

# 路徑(自己設ㄅ)
PATH_from= "AllData/crawler/upload/alreadyclean/" 
PATH_go= "AllData/emojiclean/"


data <- read.xlsx(paste(PATH_from, import_data, sep=''))
content_row<- 4 #LINE:2 IG:4 FB:5

clean_data<- cleanclean(dataID, data, content_row)
write.xlsx(clean_data, paste(PATH_go, dataID, '.xlsx', sep =''))


#View(clean_data)        #斷句後表情結果
#View(data)              #原始資料
