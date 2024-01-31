library(Rtsne)
library(RColorBrewer)
library(openxlsx)

emo = read.xlsx("F:/專題/AllData/training/emoji_sampling/emo_400/3rand_emo400.xlsx")
head(emo)
# 檢查確定維度!
dim(emo)
emo<- emo[, -1]
head(emo)

# 因為有一樣的句向量，後面需要多加 check_duplicates = False
nrow(unique(emo))


#--------------------畫圖-----------------------------#
# tsne 降成2維
x11()
pp = 50
t5<- Rtsne(emo, dim= 2, perplexity= pp, verbose = T, check_duplicates = F)

col40 = c("#FFDEDE", "#FF8C8C", "#FF3B3B", "#B20000", "#800000",   
          "#FFE8BF", "#FFD382", "#FFB630", "#E09200", "#AD7100", "#805300", 
          "#FFFF26", "#DBDB00", "#A8A800", "#808000",
          "#ABFFAB", "#00FF00", "#00D100", "#008000", 
          "#BFFFFF", "#1CFFFF", "#00DBDB", "#00ADAD", "#008080", 
          "#D6D6FF", "#9999FF", "#3030FF", "#0000BD",
          "#E0B5FF", "#BD63FF", "#990DFF", '#4A0080',
          "#FFB5FF", "#FF6EFF", "#D600D6", "#800080",
          "#EDEDED", "#BFBFBF", "#8C8C8C", "#3B3B3B")

length(col40)
cc = rep(col40, each= 400)


x11()
plot(t5$Y, xlab= 'tSNE Dimension 1', ylab= 'tSNE Dimension 2',
     col = cc, main = '由 40 個 Emoji Groups 各抽取 400 個樣本')
legend('left', legend = c(1:40), col = col40, cex = 0.7, 
       pch= 16, pt.cex= 1.2)






t50<- Rtsne(emo, dim= 3, perplexity= 40, check_duplicates = F)
head(t50$Y)
write.csv(t50$Y, "AllData/training/emoji_sampling/emo400/emo400_pp40_correct.csv")



#pp 是要try的參數
try<- c(5, 15, 30, 40)

# 匯出檔案
for(i in try){
  t50<- Rtsne(emo, dim= 3, perplexity= i)
  write.csv(t50$Y, paste("AllData/training/emoji_sampling/emo600_pp", i, ".csv", sep = ''))
}


#(90*3+96*6+93+98*3+95*2+99*2+98*3)/20
