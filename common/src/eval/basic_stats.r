accuracy = function(mod, X, Y){
  mean(Y == predict_model(mod, X, type="class") )
}

# Just setting as type = "class" for testing purposes.
rsqrd = function(mod, X, Y, type="class"){
  outv <- summary(mod)$r.squared
  if(is.null(outv)){
    Y_bar  = mean(Y)
    Y_pred = predict_model(mod, X, type=type)
    # via WP
    SS_tot = sum((Y      - Y_bar)^2)
    SS_reg = sum((Y_pred - Y_bar)^2)
    SS_res = sum((Y      - Y_pred)^2)
    outv = 1 - (SS_res / SS_tot)
  }
  outv
}

# Add more stats later
statistics = list(accuracy = accuracy, 
                  rsqrd=rsqrd)