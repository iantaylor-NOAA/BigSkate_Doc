png(file.path(catch.dir, '../BigSkate_Doc/Figures/growth_curve_comparison.png'),
    res=300, units='in', width=8, height=5, pointsize=10)

par(mfrow=c(1,3), mar=c(0,0,0,1), oma=c(4,4,1,2), las=1)

# make empty plot for Growth Pattern 1 (to ensure consistent dimensions)
plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i')
mtext(side=1, line=2.5, outer=TRUE, text="Age (yr)")
mtext(side=2, line=2.5, outer=TRUE, text="Length (cm)", las=0)
# add growth curves
SSplotBiology(bs72, subplot=1, add=TRUE, legendloc=FALSE)
# add legend, grid, and outer box
axis(1)
grid()
legend('topleft', title="Growth cessation model", legend=NA, bty="n", text.font=2, cex=2)
box()

# make empty plot for Growth Pattern 2 (to ensure consistent dimensions)
plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i', axes=FALSE)
# add growth curves 
SSplotBiology(bs72bio3, subplot=1, add=TRUE, legendloc=FALSE)
# add legend, grid, and outer box
axis(1)
grid()
legend('topleft', title="von Bertalanffy growth", legend=NA, bty="n", text.font=2, cex=2)
box()

# make empty plot for Growth Pattern 3 (to ensure consistent dimensions)
plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i', axes=FALSE)
# add growth curves 
SSplotBiology(bs72bio4, subplot=1, add=TRUE, legendloc='topright')
# add legend, grid, and outer box
axis(1)
grid()
legend('topleft', title="Richards growth", legend=NA, bty="n", text.font=2, cex=2)
box()
axis(4)

dev.off()
