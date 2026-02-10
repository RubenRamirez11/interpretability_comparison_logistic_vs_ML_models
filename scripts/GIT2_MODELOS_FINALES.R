# AJUSTE DE MODELO FINAL R.F.-----------------------
m_rf_final <- randomForest(
  Depression ~ .,
  data       = df,
  ntree      = 500,         
  mtry       = 2,        
  importance = F,
  localImp   = F,
  proximity  = F,
  keep.forest = T, 
  keep.inbag = F,  
  nodesize = 41 
)
prob_rf_final <- predict(m_rf_final, type="prob")[,2]

# Cálculo AUC robusto
roc_rf  <- roc(df$Depression, prob_rf_final, levels=c("0","1"), direction="<")
auc_rf <- auc(roc_rf)


#Importancia de variables mediante permutación:
auc_original <- auc_rf

perm_importance <- numeric(ncol(df) - 1)
names(perm_importance) <- names(df)[names(df) != "Depression"]

for(var in names(perm_importance)){
  
  df_perm <- df
  
  # Permutar variable completa
  df_perm[[var]] <- sample(df_perm[[var]])
  
  pred_perm <- predict(m_rf_final, newdata = df_perm, type = "prob")[,2]
  
  roc_perm <- roc(df_perm$Depression, pred_perm, levels=c("0","1"), direction="<")
  auc_perm <- auc(roc_perm)
  
  perm_importance[var] <- auc_original - auc_perm
}

sort(perm_importance, decreasing = TRUE)


#Grafico de Importancia de variables por AUC:http://127.0.0.1:31323/graphics/plot_zoom_png?width=1692&height=919

imp_rf <- data.frame(
  Variable = names(perm_importance),
  DeltaAUC = as.numeric(perm_importance)
)

imp_plot <- imp_rf %>%
  arrange(desc(DeltaAUC)) %>%
  head(20)   # top 20

ggplot(imp_plot, aes(x=reorder(Variable, DeltaAUC), y=DeltaAUC)) +
  geom_col() +
  coord_flip() +
  labs(
    title = " Aporte de Vars.(ΔAUC) ",
    x = "Variable",
    y = "Disminución en AUC"
  ) +
  theme_minimal()



# AJUSTE DE MODELO FINAL LOGÍSTICO -------------------
df[,c(4,6,12)] <- lapply(lapply(df[, c(4,6,12)], as.character ), as.factor) 
df[,c(7,8)] <- lapply(lapply(df[, c(7,8)], as.character), as.factor) 
m_logit_final <- glm(Depression~., family=binomial(link = "logit"), data = df)
prob_logit_final <- predict(m_logit_final, type="response")
roc_logit  <- roc(df$Depression, prob_logit_final, levels=c("0","1"), direction="<")
roc_logit$auc

summary(m_logit_final)

