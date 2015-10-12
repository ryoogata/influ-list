require(stringr)

# ファイルの読み込み
influList <- read.table(file = "influ-list.csv", header = TRUE, stringsAsFactors =  FALSE, sep = ",", na.strings=c("","NA"))

# 不要な行 ( 1 - 3 行) の削除
influList <- influList[c(-3:-1),]

# 列名の日本語表記
# [1] "医療機関コード"   "医療機関名称"     "郵便番号"         "住所"             "電話番号"         "院内接種"        
# [7] "子供実施有無"     "対象年齢"         "出張接種"         "予防接種料金税込" "訪問対象人数" 

# 列名を指定
# 日本語表記の場合、googlemap に喰わせる時にエラーになる為、英語表記に変換
names(influList) <- c("code","name","ZIP", "address", "tel", "InsideInoculationPrice", "child", "TargetAge", "OutsideInoculation", "OutsideInoculationPrice", "VisitCount")

# 住所に改行コードが含まれる場合があるので、削除
influList$"address" <- str_replace(string = influList$"address", pattern = "\n", replacement = "")

# 住所が千葉県のみの data.frame: chibaList を作成
chibaList <- influList[grep("千葉県", influList$"address"),]

# 子供の接種を実施していない病院を排除
chibaList <- chibaList[grep("×",chibaList$"child", invert = TRUE),]

# 子供の接種年齢を数値のみで表記した列を作成
chibaList$age <- str_replace(string= chibaList$"TargetAge", pattern = "満(\\d{1,2})歳以上", replacement = "\\1")
chibaList$age <- str_replace(string= chibaList$age, pattern = "6ヵ月以上", replacement = "0.5")
chibaList$age <- str_replace(string= chibaList$age, pattern = "0ヵ月以上", replacement = "0")
chibaList$age <- as.numeric(chibaList$age)

# 4 歳以下でも接種可能な病院 data.frame: chibaListUnder4 を作成
chibaListUnder4 <- chibaList[chibaList$age <= 4,]

# 子供実施有無と出張接種の列を削除
chibaListUnder4 <- chibaListUnder4[,-c(7,9)]

# ファイルの書き出し ( 4 歳以下でも接種可能な病院 )
write.table(chibaListUnder4, file="chibaListUnder4.csv", sep=",", row.names = FALSE, fileEncoding="UTF8")

# ファイルの書き出し ( 千葉県内病院 )
write.table(chibaList, file="chibaList.csv", sep=",", row.names = FALSE, fileEncoding="UTF8")