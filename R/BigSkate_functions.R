getbs <- function(n, sensname=NULL,
                  plot = 0, res=200, ...){
  require(r4ss)
  # function to figure out full path associated with a given model number,
  # run SS_output and assign results to an object with a name like "bs9"
  bsdir <- 'C:/SS/skates/models/'
  # if no sensitivity
  if(is.null(sensname)){
    mods <- dir(bsdir)
    mod <- mods[grep(pattern = paste0("^bigskate(0)*", n), mods)]
  }else{ # if a sensitivity
    sens.subdir <- paste0("sensitivity.bigskate", n)
    mods <- dir(file.path(bsdir, sens.subdir))
    mod <- file.path(sens.subdir, mods[grep(pattern = sensname, mods)])
  }
  if(length(mod) > 1){
    stop("more than 1 model:\n", mod)
  }
  
  message("reading model from: ", mod)
  out <- SS_output(file.path(bsdir, mod))
  newname <- paste0("bs", n, sensname)
  message("creating ", newname)
  assign(x=newname, value=out, pos=1)
  if(plot[1] != 0){
    SS_plots(out, plot=plot, res=res, ...)
  }
}



box95 <- function(x,dat=NULL,col='grey',lty=1,names=NULL,...)
  {
    browser()
  bx1 <- boxplot(x,plot=F, ...)
  bx1$stats[c(1,5),] <- as.matrix(as.data.frame(lapply(x,quantile,probs=c(.025,.975),na.rm=T)))
  ##bx1$stats[c(1,5),] <- lapply(x,quantile,probs=c(.025,.975))
  ## bx1$stats[c(1,5)] <- quantile(x, probs = c(.025,.975))
  bx1$out = NULL
  bx1$group = NULL
  if(!is.null(names)) {
    bx1$names <- names
  }
  pars <- list(boxfill=col,boxlty=1,...)
  if (any(c("black", "#000000") %in% col)) {
    if (!"border" %in% names(pars)) par("fg" = "gray") 
  }
  bxp(bx1,pars=pars,lty=1,border = "gray", ...)
  out <- bx1$stats[c(1,3,5),]
  rownames(out) <- c("lower95","median","upper95")
  return(out)
}
