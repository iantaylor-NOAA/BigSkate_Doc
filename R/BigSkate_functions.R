getbs <- function(n, plot = 0, res=200, ...){
  require(r4ss)
  # function to figure out full path associated with a given model number,
  # run SS_output and assign results to an object with a name like "bs9"
  bsdir <- 'C:/SS/skates/models/'
  mods <- dir(bsdir)
  mod <- mods[grep(pattern = paste0("bigskate(0)*", n), mods)]
  if(length(mod) > 1){
    stop("more than 1 model:\n", mod)
  }
  message("reading model from: ", mod)
  out <- SS_output(file.path(bsdir, mod))
  assign(x=paste0("bs", n), value=out, pos=1)
  if(plot[1] != 0){
    SS_plots(out, plot=plot, res=res, ...)
  }
}
