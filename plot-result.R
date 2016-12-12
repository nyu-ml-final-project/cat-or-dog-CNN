read.running.result <- function(path){
  library(gsubfn)
  lines <- readLines(path, encoding = "UTF-8")
  pat <- "(?:(?:\\d+)\\/(?:\\d+) \\[(?:=+)\\])(?: - (\\d+)s - loss: ((?:\\d|\\.)+) - acc: ((?:\\d|\\.)+) - val_loss: ((?:\\d|\\.)+) - val_acc: ((?:\\d|\\.)+))"
  table <- data.frame(strapplyc(lines, pat, simplify = "rbind"))
  colnames(table) <- c('duration', 'loss','acc', 'val_loss', 'val_acc')
  data.frame(apply(table, 2, as.numeric))
}


fetch.one.col <- function(df, col.name, y= "Loss", ...){
  new.df <- data.frame(
            as.numeric(row.names(df)),
            df[col.name],
            ...
            )
  colnames(new.df)<- c( "Epoch", y, names(list(...)))
  new.df
}

form.duration <- function(df, col.name="duration", ...){
  new.df <- data.frame(
    as.numeric(row.names(df)),
    df[col.name],
    ...
  )
  colnames(new.df)<- c("Type", "Duration", names(list(...)))
  new.df
}


compare.cpu.gpu.acc <- function(){
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.gpu <- read.running.result("results/11_28_second_try_gpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.cpu, "acc",     y= "Accuracy", Processor = "CPU" , Dataset = "Training"),
    fetch.one.col(reading.cpu, "val_acc", y= "Accuracy", Processor = "CPU" , Dataset = "Testing"),
    fetch.one.col(reading.gpu, "acc",     y= "Accuracy", Processor = "GPU" , Dataset = "Training"),
    fetch.one.col(reading.gpu, "val_acc", y= "Accuracy", Processor = "GPU" , Dataset = "Testing")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Accuracy, col=Processor, linetype=Dataset)) +
    ggplot2::geom_line()+
    ggplot2::scale_color_manual(name="Processor",
                      values=c("CPU"="#00B7F4","GPU"="#F989A1"))+
    ggplot2::scale_linetype_manual(name="Dataset",
                                   values=c(
                                     "Testing"= "solid", 
                                     "Training" = "twodash"
                                   )
    )
}
compare.cpu.gpu.loss <- function(){
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.gpu <- read.running.result("results/11_28_second_try_gpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.cpu, "loss",     y = "Loss" ,Processor = "CPU" , Dataset = "Training"),
    fetch.one.col(reading.cpu, "val_loss", y = "Loss" ,Processor = "CPU" , Dataset = "Testing"),
    fetch.one.col(reading.gpu, "loss",     y = "Loss" ,Processor = "GPU" , Dataset = "Training"),
    fetch.one.col(reading.gpu, "val_loss", y = "Loss" ,Processor = "GPU" , Dataset = "Testing")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Loss, col=Processor, linetype=Dataset)) +
    ggplot2::geom_line()+
    ggplot2::scale_color_manual(name="Processor",
                                values=c("CPU"="#00B7F4","GPU"="#F989A1"))+
    ggplot2::scale_linetype_manual(name="Dataset",
                                   values=c(
                                     "Testing"= "solid", 
                                     "Training" = "twodash"
                                   )
    )
}
compare.acc.loss <- function(){
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.cpu, "loss",  y="Value",   Index = "Loss" , Dataset = "Training"),
    fetch.one.col(reading.cpu, "val_loss",  y="Value", Index = "Loss" , Dataset = "Testing"),
    fetch.one.col(reading.gpu, "acc",   y="Value",     Index = "Accuracy" , Dataset = "Training"),
    fetch.one.col(reading.gpu, "val_acc",   y="Value", Index = "Accuracy" , Dataset = "Testing")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Value, col=Index, linetype=Dataset)) +
    ggplot2::geom_line()+
    ggplot2::scale_linetype_manual(name="Dataset",
                                   values=c(
                                     "Testing"= "solid", 
                                     "Training" = "twodash"
                                   )
    )
}
compare.cpu.gpu.running.time <- function(){
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.gpu <- read.running.result("results/11_28_second_try_gpu.txt")
  
  readings.duration <- rbind(
    form.duration(reading.cpu, "duration", Processor = "CPU"),
    form.duration(reading.gpu, "duration", Processor = "GPU")
  )
  ggplot2::ggplot(readings.duration,
                  ggplot2::aes(Processor , Duration, col=Processor))+
    ggplot2::geom_boxplot(size=0.25)+
    ggplot2::coord_flip()
  
  print(mean(reading.cpu$duration))
  print(mean(reading.gpu$duration))
}

compare.layers <- function(){
  reading.3 <- read.running.result("results/conv3-7/11_28_3_conv.txt")
  reading.4 <- read.running.result("results/conv3-7/12_11_4_conv.txt")
  reading.5 <- read.running.result("results/conv3-7/12_11_5_conv.txt")
  reading.6 <- read.running.result("results/conv3-7/12_11_6_conv.txt")
  reading.7 <- read.running.result("results/conv3-7/12_11_7_conv.txt")
  
  readings <- rbind(
    fetch.one.col(reading.3, "val_loss",  y="Value", Layers = 3, Index="Loss"),
    #fetch.one.col(reading.3, "val_acc",   y="Value", Layers = 3, Index="Accuracy"),
    fetch.one.col(reading.4, "val_loss",  y="Value", Layers = 4, Index="Loss"),
    #fetch.one.col(reading.4, "val_acc",   y="Value", Layers = 4, Index="Accuracy"),
    fetch.one.col(reading.5, "val_loss",  y="Value", Layers = 5, Index="Loss"),
    #fetch.one.col(reading.5, "val_acc",   y="Value", Layers = 5, Index="Accuracy"),
    fetch.one.col(reading.6, "val_loss",  y="Value", Layers = 6, Index="Loss"),
    #fetch.one.col(reading.6, "val_acc",   y="Value", Layers = 6, Index="Accuracy"),
    fetch.one.col(reading.7, "val_loss",  y="Value", Layers = 7, Index="Loss")
    #fetch.one.col(reading.7, "val_acc",   y="Value", Layers = 7, Index="Accuracy")
  )
  readings$Layer <- as.factor(readings$Layers)
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Value, sep.line=Layer, col = Layers)) +
    ggplot2::geom_line()+
    ggplot2::scale_colour_gradient("Layers")
}

compare.number.of.epoch <- function(){
  reading.normal <- read.running.result("results/11_28_second_try_gpu.txt")
  reading.vgg    <- read.running.result("results/12_09_3_conv_with_epoch_80.txt")
  
  readings <- rbind(
    fetch.one.col(reading.normal, "val_loss",  y="Value", Model = "Extended Epoch", Index="Loss"),
    fetch.one.col(reading.vgg, "val_loss",  y="Value", Model = "VGG", Index="Loss"),
    fetch.one.col(reading.normal, "val_acc",  y="Value", Model = "Extended Epoch", Index="Accuracy"),
    fetch.one.col(reading.vgg, "val_acc",  y="Value", Model = "VGG", Index="Accuracy")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Value, col=Model, linetype=Index)) +
    ggplot2::geom_line()+
    ggplot2::scale_color_manual(name="Model",
                                values=c("Extended Epoch"="#00B7F4","VGG"="#F989A1"))
}
compare.vgg <- function(){
  reading.normal <- read.running.result("results/11_28_second_try_gpu.txt")
  reading.vgg    <- read.running.result("results/12_09_VGG16_gpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.normal, "val_loss",  y="Value", Model = "Simple 3 Layers", Index="Loss"),
    fetch.one.col(reading.vgg, "val_loss",  y="Value", Model = "VGG 16", Index="Loss"),
    fetch.one.col(reading.normal, "val_acc",  y="Value", Model = "Simple 3 Layers", Index="Accuracy"),
    fetch.one.col(reading.vgg, "val_acc",  y="Value", Model = "VGG 16", Index="Accuracy")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Value, col=Model, linetype=Index)) +
    ggplot2::geom_line()+
    ggplot2::scale_color_manual(name="Model",
                                values=c("Simple 3 Layers"="#00B7F4","VGG 16"="#F989A1"))
}