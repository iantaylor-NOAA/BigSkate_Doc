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
