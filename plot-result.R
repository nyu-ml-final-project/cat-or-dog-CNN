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
compare.cpu.gpu <- function(){
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.gpu <- read.running.result("results/11_28_second_try_gpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.gpu, "val_acc",   y="Indexes",     Index = "Accuracy" , Processor = "GPU"),
    fetch.one.col(reading.gpu, "val_loss",   y="Indexes", Index = "Loss" , Processor = "GPU"),
    fetch.one.col(reading.cpu, "val_acc",  y="Indexes",   Index = "Accuracy" , Processor = "CPU"),
    fetch.one.col(reading.cpu, "val_loss",  y="Indexes", Index = "Loss" , Processor = "CPU")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Indexes, col=Processor)) +
  #ggplot2::ggplot(readings, ggplot2::aes(Epoch , Indexes, linetype=Processor)) +
    ggplot2::geom_line()+
    #ggplot2::scale_color_manual(name="Processor",
    #                            values=c("CPU"="#00B7F4","GPU"="#F989A1"))+
    #ggplot2::scale_linetype_manual(name="Dataset",
    #                               values=c(
    #                                 "Testing"= "solid", 
    #                                 "Training" = "twodash"
    #                               )
    #)
    ggplot2::facet_grid( Index ~ . ,scales = "free_y")
}
compare.acc.loss <- function(){
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.cpu, "acc",   y="Indexes",     Index = "Accuracy" , Dataset = "Training"),
    fetch.one.col(reading.cpu, "val_acc",   y="Indexes", Index = "Accuracy" , Dataset = "Testing"),
    fetch.one.col(reading.cpu, "loss",  y="Indexes",   Index = "Loss" , Dataset = "Training"),
    fetch.one.col(reading.cpu, "val_loss",  y="Indexes", Index = "Loss" , Dataset = "Testing")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Indexes, col=Dataset, linetype=Dataset)) +
  #ggplot2::ggplot(readings, ggplot2::aes(Epoch , Indexes, linetype=Dataset)) +
    ggplot2::geom_line()+
    ggplot2::scale_linetype_manual(name="Dataset",
                                   values=c("Training"= "twodash", "Testing" = "solid")
    )+
    ggplot2::facet_grid( Index ~ . ,scales = "free_y")
}
compare.cpu.gpu.running.time <- function(){
  reading.cpu <- read.running.result("results/11_26_first_try_cpu.txt")
  reading.gpu <- read.running.result("results/11_28_second_try_gpu.txt")
  
  readings.duration <- rbind(
    form.duration(reading.cpu, "duration", Processor = "CPU"),
    form.duration(reading.gpu, "duration", Processor = "GPU")
  )
  ggplot2::ggplot(readings.duration,
                  #ggplot2::aes(Processor , Duration, col.sep=Processor))+
                  ggplot2::aes(Processor , Duration, col=Processor))+
    ggplot2::geom_boxplot(size=0.25)+
    ggplot2::coord_flip()
  
  #print(mean(reading.cpu$duration))
  #print(mean(reading.gpu$duration))
}
compare.layers <- function(){
  reading.3 <- read.running.result("results/conv3-7/11_28_3_conv.txt")
  reading.4 <- read.running.result("results/conv3-7/12_11_4_conv.txt")
  reading.5 <- read.running.result("results/conv3-7/12_11_5_conv.txt")
  reading.6 <- read.running.result("results/conv3-7/12_11_6_conv.txt")
  reading.7 <- read.running.result("results/conv3-7/12_11_7_conv.txt")
  readings <- data.frame(
    reading.3$val_acc,
    reading.4$val_acc,
    reading.5$val_acc,
    reading.6$val_acc,
    reading.7$val_acc
  )
  colnames(readings) <- 3:7
  
  mean.top <- function(x, numbers = 5){
    mean(sort(x, decreasing = TRUE)[1:numbers])
  }
  Top.10 <- data.frame(apply(readings, 2 , mean.top, numbers = 10))
  Top.5 <- data.frame(apply(readings, 2 , mean.top))
  Top.1 <- data.frame(apply(readings, 2 , mean.top, numbers = 1))
  colnames(Top.10) <- "Accuracy"
  colnames(Top.5) <- "Accuracy"
  colnames(Top.1) <- "Accuracy"
  Top.10$Layer <- 3:7
  Top.5$Layer <- 3:7
  Top.1$Layer <- 3:7
  Top.10$Top <- 10
  Top.5$Top <- 5
  Top.1$Top <- 1
  
  Tops <- rbind(
    Top.10,
    Top.5,
    Top.1
  )
  Tops$Top <- as.factor(Tops$Top)
  ggplot2::ggplot(Tops, ggplot2::aes(Layer , Accuracy, color = Top, linetype = Top )) +
  #ggplot2::ggplot(Tops, ggplot2::aes(Layer , Accuracy, linetype = Top)) +
    ggplot2::geom_line()+
    ggplot2::scale_colour_manual(name="Mean Top #",
                                 values=c("5"  = "#00B7F4", "1"  = 2,"10" = 3))+
    ggplot2::scale_linetype_manual(name="Mean Top #",
                                   values=c("5"  = 1, "1"  = 2,"10" = 2))
  #  ggplot2::scale_linetype_manual(name="Mean Top #",
  #                                 values=c("5"  = 1, "1"  = 2,"10" = 3))
}
compare.layers.dumb <- function(){
  reading.3 <- read.running.result("results/conv3-7/11_28_3_conv.txt")
  reading.4 <- read.running.result("results/conv3-7/12_11_4_conv.txt")
  reading.5 <- read.running.result("results/conv3-7/12_11_5_conv.txt")
  reading.6 <- read.running.result("results/conv3-7/12_11_6_conv.txt")
  reading.7 <- read.running.result("results/conv3-7/12_11_7_conv.txt")
  
  readings <- rbind(
    fetch.one.col(reading.3, "val_acc",   y="Value", Layers = 3, Index="Accuracy"),
    fetch.one.col(reading.3, "val_loss",  y="Value", Layers = 3, Index="Loss"),
    fetch.one.col(reading.4, "val_loss",  y="Value", Layers = 4, Index="Loss"),
    fetch.one.col(reading.4, "val_acc",   y="Value", Layers = 4, Index="Accuracy"),
    fetch.one.col(reading.5, "val_loss",  y="Value", Layers = 5, Index="Loss"),
    fetch.one.col(reading.5, "val_acc",   y="Value", Layers = 5, Index="Accuracy"),
    fetch.one.col(reading.6, "val_loss",  y="Value", Layers = 6, Index="Loss"),
    fetch.one.col(reading.6, "val_acc",   y="Value", Layers = 6, Index="Accuracy"),
    fetch.one.col(reading.7, "val_acc",   y="Value", Layers = 7, Index="Accuracy"),
    fetch.one.col(reading.7, "val_loss",  y="Value", Layers = 7, Index="Loss")
  )
  readings$Layer <- as.factor(readings$Layers)
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Value, sep.line=Layer, col = Layers)) +
    ggplot2::geom_line()+
    ggplot2::scale_colour_gradient("Layers")+
    ggplot2::facet_grid( Index ~ .)
}

compare.number.of.epoch <- function(){
  #reading.normal <- read.running.result("results/11_28_second_try_gpu.txt")
  reading.vgg    <- read.running.result("results/12_09_3_conv_with_epoch_80.txt")
  
  readings <- rbind(
    fetch.one.col(reading.vgg, "val_loss",  y="Indexes", Model = "Extended Epoch", Index="Loss"),
    #fetch.one.col(reading.normal, "val_loss",  y="Indexes", Model = "Baseline", Index="Loss"),
    
    #fetch.one.col(reading.normal, "val_acc",  y="Indexes", Model = "Baseline", Index="Accuracy"),
    fetch.one.col(reading.vgg, "val_acc",  y="Indexes", Model = "Extended Epoch", Index="Accuracy")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Indexes)) +
  #ggplot2::ggplot(readings, ggplot2::aes(Epoch , Indexes, linetype=Model)) +
    ggplot2::geom_line()+
    #ggplot2::scale_color_manual(name="Model",
    #                            values=c("Extended Epoch"="#00B7F4","VGG"="#F989A1"))
    ggplot2::facet_grid( Index ~ .,scales = "free_y")
}
compare.vgg <- function(){
  reading.normal <- read.running.result("results/11_28_second_try_gpu.txt")
  reading.vgg    <- read.running.result("results/12_09_VGG16_gpu.txt")
  
  readings <- rbind(
    fetch.one.col(reading.vgg, "val_acc",  y="Value", Model = "VGG 16", Index="Accuracy"),
    fetch.one.col(reading.vgg, "val_loss",  y="Value", Model = "VGG 16", Index="Loss"),
    fetch.one.col(reading.normal, "val_loss",  y="Value", Model = "Baseline", Index="Loss"),
    fetch.one.col(reading.normal, "val_acc",  y="Value", Model = "Baseline", Index="Accuracy")
  )
  ggplot2::ggplot(readings, ggplot2::aes(Epoch , Value, col=Model, linetype=Model)) +
  #ggplot2::ggplot(readings, ggplot2::aes(Epoch , Value, linetype=Model)) +
    ggplot2::geom_line()+
    ggplot2::scale_color_manual(name="Model",
                                values=c("Baseline"="#00B7F4","VGG 16"="#F989A1"))+
    ggplot2::facet_grid( Index ~ . ,scales = "free_y")
}