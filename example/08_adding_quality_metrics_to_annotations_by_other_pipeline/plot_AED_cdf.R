library(RColorBrewer)
col_set <- brewer.pal(n = 7, 'Set1')

dfm <- read.table('AED_cdf.tsv', header = T)

pdf('AED_cdf.pdf')
plot(0, type='n', xlab='AED', ylab='Cumulative fraction of annotations', las=1, ylim=c(0,1), xlim=c(0,1))
for (i in 2:ncol(dfm)) {
  lines(dfm$AED, dfm[[i]], col=col_set[i-1], lwd=3)
}
legend('bottomright', colnames(dfm[,-1]), col = col_set[1:ncol(dfm[,-1])], bty='n', lwd=3)
dev.off()
