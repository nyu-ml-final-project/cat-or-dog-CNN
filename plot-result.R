read.running.result <- function(path){
  library(gsubfn)
  lines <- readLines(path, encoding = "UTF-8")
  pat <- "(?:(?:\\d+)\\/(?:\\d+) \\[(?:=+)\\])(?: - (\\d+)s - loss: ((?:\\d|\\.)+) - acc: ((?:\\d|\\.)+) - val_loss: ((?:\\d|\\.)+) - val_acc: ((?:\\d|\\.)+))"
  table <- data.frame(strapplyc(lines, pat, simplify = "rbind"))
  colnames(table) <- c('duration', 'loss','acc', 'val_loss', 'val_acc')
  table
}

running.result.plot <- function(reading){
  
}

main <- function(){
  # library(ggplot2)
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.gpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.cpu$type 
  row.id <- row.names(reading.cpu)
  #p <- ggplot2::ggplot()

  #p + ggplot2::geom_line(aes(rowid , acc, color=factor(rowid)), reading.cpu)
}