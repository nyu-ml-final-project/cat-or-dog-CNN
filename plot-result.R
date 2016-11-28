read.running.result <- function(path){
  library(gsubfn)
  lines <- readLines(path, encoding = "UTF-8")
  pat <- "(?:(?:\\d+)\\/(?:\\d+) \\[(?:=+)\\])(?: - (\\d+)s - loss: ((?:\\d|\\.)+) - acc: ((?:\\d|\\.)+) - val_loss: ((?:\\d|\\.)+) - val_acc: ((?:\\d|\\.)+))"
  table <- data.frame(strapplyc(lines, pat, simplify = "rbind"))
  colnames(table) <- c('duration', 'loss','acc', 'val_loss', 'val_acc')
  data.frame(apply(table, 2, as.numeric))
}

running.result.plot <- function(reading){
  
}
fetch.one.col <- function(df, col.name, Type){
  new.df <- data.frame(Type,
            as.numeric(row.names(df)),
            df[col.name])
  colnames(new.df)<- c("Type", "Epoch", "Accuracy")
  new.df
}

main <- function(){
  # library(ggplot2)
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.gpu <- read.running.result("results/11_28_second_try_gpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.cpu, "acc", "CPU - Training"),
    fetch.one.col(reading.cpu, "val_acc", "CPU - Testing"),
    fetch.one.col(reading.gpu, "acc", "GPU - Training"),
    fetch.one.col(reading.gpu, "val_acc", "GPU - Testing")
  )
  p <- ggplot2::ggplot(readings)
  p + ggplot2::geom_line(aes(Epoch , Accuracy, color=Type))
}