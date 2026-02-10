
# ==============================================================================
#                        2. RANDOM FOREST--------------------------------------
# ==============================================================================


library(randomForest)
library(ISLR2)
library(tree)

# ============================================================
#  CALIBRACIÓN DE HIPERPARÁMETROS Secuencial : mtry, ntree y nodesize
# ============================================================
set.seed(1234)

K <- 5
n <- nrow(df)

idx <- sample(1:n, n, replace=FALSE)
folds <- split(idx, cut(seq_along(idx), K, labels=FALSE))

# Hiperparámetros a evaluar
mtry_grid <- c(1,2,3,4,5,6,7,8,9,10,11,12,13)
resultados_rf2 <- data.frame(mtry=mtry_grid, AUC=NA, SD = NA)

# ============================================================
#1) CALIBRACIÓN DE MTRY. GRIDSEARCH FIJANDO NTREE = 500 Y NODESIZE = 1
# ============================================================

for(m in seq_along(mtry_grid)){ #Bucle para cada valor de mtry
  
  mtry_val <- mtry_grid[m] #El valor actual de mtry
  auc_vals_rf2 <- numeric(K) #Objeto para guardar resultados
  
  cat("\n=========== Tunear mtry =", mtry_val, "===========\n")
  
  for(i in 1:K){ #Bucle para los folds
    
    cat(" Fold", i, "\n")
    
    test_idx_rf2  <- folds[[i]] #Selecciona el fold actual para test
    train_idx_rf2 <- setdiff(1:n, test_idx_rf2) #Usa el resto de folds para train
    
    train_rf2 <- df[train_idx_rf2, ]
    test_rf2  <- df[test_idx_rf2, ]
    
    # ------------------------------
    # Construccion del modelo RF
    # ------------------------------
    set.seed(9000 + i)   # Ya que el modelo usa bootstrap se usa una semilla que varie por iteración para que el resultado del CV sea reproducible
    rf_model2 <- randomForest(
      Depression ~ .,
      data       = train_rf2,
      ntree      = 500, #Valor fijado
      mtry       = mtry_val,
      importance = FALSE,
      localImp   = FALSE,
      proximity  = FALSE,
      keep.forest = TRUE, 
      keep.inbag = FALSE,
      nodesize = 2 #Fijado
    )
    
    # Probabilidades para AUC
    prob_rf2 <- predict(rf_model2, newdata=test_rf2, type="prob")[,2]
    
    # Cálculo AUC
    roc_rf2  <- roc(test_rf2$Depression, prob_rf2, levels=c("0","1"), direction="<")
    auc_vals_rf2[i] <- auc(roc_rf2)
  }
  
  resultados_rf2$AUC[m] <- mean(auc_vals_rf2)
  resultados_rf2$SD[m] <- sd(auc_vals_rf2)
  rm(rf_model2)
}

cat("\n===== RESULTADOS RANDOM FOREST =====\n")
print(resultados_rf2)

CV_RF_x_MTRY <- resultados_rf2 #El mejor AUC es con Mtry = 2


# ============================================================
#2) CALIBRACIÓN DE NTREE. GRID SEARCH FIJANDO MTRY = 2 Y NODESIZE = 1
# ============================================================

ntree_grid <- c(100,200,300,400,500)
resultados_rf3 <- data.frame(ntree=ntree_grid, AUC=NA, SD = NA)

for(m in seq_along(ntree_grid)){
  
  ntree_val <- ntree_grid[m]
  auc_vals_rf2 <- numeric(K)
  
  cat("\n=========== Tunear ntree =", ntree_val, "===========\n")
  
  for(i in 1:K){
    
    cat(" Fold", i, "\n")
    
    test_idx_rf2  <- folds[[i]]
    train_idx_rf2 <- setdiff(1:n, test_idx_rf2)
    
    train_rf2 <- df[train_idx_rf2, ]
    test_rf2  <- df[test_idx_rf2, ]
    
    # ------------------------------
    # MODELO RANDOM FOREST OPTIMIZADO
    # ------------------------------
    set.seed(9500 + i)   # ← semilla por fold para reproducibilidad
    rf_model2 <- randomForest(
      Depression ~ .,
      data       = train_rf2,
      ntree      = ntree_val,   # hiperparámetro a tunear
      mtry       = 2,           # ya tuneado
      importance = FALSE,
      localImp   = FALSE,
      proximity  = FALSE,
      keep.forest = TRUE,
      keep.inbag = FALSE,
      nodesize = 2 #Fijado
    )
    
    # Probabilidades para AUC
    prob_rf2 <- predict(rf_model2, newdata=test_rf2, type="prob")[,2]
    
    # Cálculo AUC
    roc_rf2  <- roc(test_rf2$Depression, prob_rf2, levels=c("0","1"), direction="<")
    auc_vals_rf2[i] <- auc(roc_rf2)
  }
  
  resultados_rf3$AUC[m] <- mean(auc_vals_rf2)
  resultados_rf3$SD[m] <- sd(auc_vals_rf2)
  rm(rf_model2)
}

print(resultados_rf3)
CV_RF_x_NTREE <- resultados_rf3

#Mejor hiperparámetro es 500.

# ============================================================
#3) CALIBRACIÓN DE NODESIZE. GRID SEARCH SECUENCIAL, FIJANDO MTRY = 2 Y NTREE = 500
# ============================================================

# Calibración 1:
node_grid <- seq(from = 1, to = floor(nrow(df_train)*4/5), by = 1200) # Para bajar costo computacional primero se vera en rangos de 1200
resultados_rf4 <- data.frame(node=node_grid, AUC=NA, SD = NA)
for(m in seq_along(node_grid)){
  
  node_val <- node_grid[m]
  auc_vals_rf2 <- numeric(K)   # guarda AUC de cada fold
  
  cat("\n=========== Tunear nodesize =", node_val, "===========\n")
  
  for(i in 1:K){
    
    cat(" Fold", i, "\n")
    
    test_idx_rf2  <- folds[[i]]
    train_idx_rf2 <- setdiff(1:n, test_idx_rf2)
    
    train_rf2 <- df[train_idx_rf2, ]
    test_rf2  <- df[test_idx_rf2, ]
    
    # ------------------------------
    # MODELO RANDOM FOREST OPTIMIZADO
    # ------------------------------
    set.seed(2500 + i)   # ← semilla por fold para reproducibilidad
    rf_model2 <- randomForest(
      Depression ~ .,
      data       = train_rf2,
      ntree      = 500,             # hiperparametro tuneado
      mtry       = 2,        # Hiperparámetro ya tuneado
      importance = F,
      localImp   = F,
      proximity  = F,
      keep.forest = T, 
      keep.inbag = F,  
      nodesize = node_val #Hiperparámetro a tunear
    )
    
    # Probabilidades para AUC
    prob_rf2 <- predict(rf_model2, newdata=test_rf2, type="prob")[,2]
    
    # Cálculo AUC robusto
    roc_rf2  <- roc(test_rf2$Depression, prob_rf2, levels=c("0","1"), direction="<")
    auc_vals_rf2[i] <- auc(roc_rf2)
  }
  
  resultados_rf4$AUC[m] <- mean(auc_vals_rf2)
  resultados_rf4$SD[m] <- sd(auc_vals_rf2)
  rm(rf_model2)
}
CV_RF_x_NODE1200 <- resultados_rf4 #El mejor rango está entre 1 y 1201

# Calibración 2:
node_grid <- seq(from = 1, to = 1201, by = 70)
resultados_rf4 <- data.frame(node=node_grid, AUC=NA, SD = NA)
for(m in seq_along(node_grid)){
  
  node_val <- node_grid[m]
  auc_vals_rf2 <- numeric(K)   # guarda AUC de cada fold
  
  cat("\n=========== Tunear nodesize =", node_val, "===========\n")
  
  for(i in 1:K){
    
    cat(" Fold", i, "\n")
    
    test_idx_rf2  <- folds[[i]]
    train_idx_rf2 <- setdiff(1:n, test_idx_rf2)
    
    train_rf2 <- df[train_idx_rf2, ]
    test_rf2  <- df[test_idx_rf2, ]
    
    # ------------------------------
    # MODELO RANDOM FOREST OPTIMIZADO
    # ------------------------------
    rf_model2 <- randomForest(
      Depression ~ .,
      data       = train_rf2,
      ntree      = 500,             # hiperparametro tuneado
      mtry       = 2,        # Hiperparámetro ya tuneado
      importance = F,
      localImp   = F,
      proximity  = F,
      keep.forest = T, 
      keep.inbag = F,  
      nodesize = node_val #Hiperparámetro a tunear
    )
    
    # Probabilidades para AUC
    prob_rf2 <- predict(rf_model2, newdata=test_rf2, type="prob")[,2]
    
    # Cálculo AUC robusto
    roc_rf2  <- roc(test_rf2$Depression, prob_rf2, levels=c("0","1"), direction="<")
    auc_vals_rf2[i] <- auc(roc_rf2)
  }
  
  resultados_rf4$AUC[m] <- mean(auc_vals_rf2)
  resultados_rf4$SD[m] <- sd(auc_vals_rf2)
  rm(rf_model2)
}
CV_RF_x_NODE70 <- resultados_rf4 #El mejor AUC esta en 71. Se evaluará todos los valores dentro de una
#desviación estandar

# Calibración 3:
node_grid <- seq(from = 1, to = 281, by = 10)
resultados_rf4 <- data.frame(node=node_grid, AUC=NA, SD = NA)
for(m in seq_along(node_grid)){
  
  node_val <- node_grid[m]
  auc_vals_rf2 <- numeric(K)   # guarda AUC de cada fold
  
  cat("\n=========== Tunear nodesize =", node_val, "===========\n")
  
  for(i in 1:K){
    
    cat(" Fold", i, "\n")
    
    test_idx_rf2  <- folds[[i]]
    train_idx_rf2 <- setdiff(1:n, test_idx_rf2)
    
    train_rf2 <- df[train_idx_rf2, ]
    test_rf2  <- df[test_idx_rf2, ]
    
    # ------------------------------
    # MODELO RANDOM FOREST OPTIMIZADO
    # ------------------------------
    rf_model2 <- randomForest(
      Depression ~ .,
      data       = train_rf2,
      ntree      = 500,             # hiperparametro tuneado
      mtry       = 2,        # Hiperparámetro ya tuneado
      importance = F,
      localImp   = F,
      proximity  = F,
      keep.forest = T, 
      keep.inbag = F,  
      nodesize = node_val #Hiperparámetro a tunear
    )
    
    # Probabilidades para AUC
    prob_rf2 <- predict(rf_model2, newdata=test_rf2, type="prob")[,2]
    
    # Cálculo AUC robusto
    roc_rf2  <- roc(test_rf2$Depression, prob_rf2, levels=c("0","1"), direction="<")
    auc_vals_rf2[i] <- auc(roc_rf2)
  }
  
  resultados_rf4$AUC[m] <- mean(auc_vals_rf2)
  resultados_rf4$SD[m] <- sd(auc_vals_rf2)
  rm(rf_model2)
}
CV_RF_x_NODE_FINAL <- resultados_rf4 #El mejor numero de nodes es 
#EL MEJOR AUC:
AUC_CV_RAND.F <- CV_RF_x_NODE_FINAL[5,2] # Mtry = 2, Ntree = 500, Nodesize = 41

#GUARDAR RESULTADOS:
saveRDS(CV_RF_x_MTRY, "CV_RF_x_MTRY.RDS")
saveRDS(CV_RF_x_NTREE, "CV_RF_x_NTREE.RDS")
saveRDS(CV_RF_x_NODE_FINAL, "CV_RF_x_NODE_FINAL.RDS")
saveRDS(CV_RF_x_NODE1200, "CV_RF_x_NODE1200.RDS")
saveRDS(CV_RF_x_NODE70, "CV_RF_x_NODE70.RDS")
saveRDS(AUC_CV_RAND.F, "AUC_CV_RAND.F.RDS")