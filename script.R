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

# 子供の接種を実施していない病院を排除
influList <- influList[grep("×",influList$"child", invert = TRUE),]

# 子供の接種年齢を数値のみで表記した列を作成
influList$age <- str_replace(string= influList$"TargetAge", pattern = "満(\\d{1,2})歳以上", replacement = "\\1")
influList$age <- str_replace(string= influList$age, pattern = "0ヵ月以上", replacement = "0")
influList$age <- str_replace(string= influList$age, pattern = "2ヵ月以上", replacement = "0.17")
influList$age <- str_replace(string= influList$age, pattern = "3ヵ月以上", replacement = "0.25")
influList$age <- str_replace(string= influList$age, pattern = "6ヵ月以上", replacement = "0.5")
influList$age <- str_replace(string= influList$age, pattern = "8ヵ月以上", replacement = "0.67")
influList$age <- str_replace(string= influList$age, pattern = "9ヵ月以上", replacement = "0.75")
influList$age <- as.numeric(influList$age)

# 子供実施有無と出張接種, 予防接種料金税込, 訪問対象人数の列を削除
influList <- influList[,-c(7,9:11)]

# 院内接種価格を数値型に変換
influList$InsideInoculationPrice <- str_replace(string = influList$InsideInoculationPrice, pattern = ",", replacement = "")
influList$InsideInoculationPrice <- as.numeric(influList$InsideInoculationPric)

# 県の列を追加
influList$prefecture <- str_extract(string = influList$address, pattern = "^.{1,3}県|^.{1,2}府|^.{2}都|^.{2}道")

# 列の並び替え
influList  <- influList[,c("code","name","ZIP","prefecture","address","tel","InsideInoculationPrice","TargetAge","age")]


### 千葉県個別の処理

# 住所が千葉県のみの data.frame: chibaList を作成
chibaList <- influList[grep("千葉県", influList$"address"),]

# 4 歳以下でも接種可能な病院 data.frame: chibaListUnder4 を作成
chibaListUnder4 <- chibaList[chibaList$age <= 4,]

# ファイルの書き出し ( 4 歳以下でも接種可能な病院 )
write.table(chibaListUnder4, file="chibaListUnder4.csv", sep=",", row.names = FALSE, fileEncoding="UTF8")

### 埼玉県個別の処理

# 住所が埼玉県のみの data.frame: chibaList を作成
saitamaList <- influList[grep("埼玉県", influList$"address"),]

# 4 歳以下でも接種可能な病院 data.frame: chibaListUnder4 を作成
saitamaListUnder4 <- saitamaList[saitamaList$age <= 4,]

# ファイルの書き出し ( 4 歳以下でも接種可能な病院 )
write.table(saitamaListUnder4, file="saitamaListUnder4.csv", sep=",", row.names = FALSE, fileEncoding="UTF8")

### 神奈川県個別の処理

# 住所が神奈川県のみの data.frame: chibaList を作成
kanagawaList <- influList[grep("神奈川県", influList$"address"),]

# 4 歳以下でも接種可能な病院 data.frame: chibaListUnder4 を作成
kanagawaListUnder4 <- kanagawaList[kanagawaList$age <= 4,]

# ファイルの書き出し ( 4 歳以下でも接種可能な病院 )
write.table(kanagawaListUnder4, file="kanagawaListUnder4.csv", sep=",", row.names = FALSE, fileEncoding="UTF8")
