library(ggplot2)
library(ggsci)
library(dplyr)

split_string <- function(x) {
  # 使用正则表达式提取 y 和 z
  matches <- regmatches(x, gregexpr("([^()]+)", x, perl = TRUE))[[1]]
  
  # 提取 y 和 z
  y <- matches[1]
  z <- matches[2]
  
  return(y)
}

split_string2 <- function(x) {
  # 使用正则表达式提取 y 和 z
  matches <- regmatches(x, gregexpr("([^()]+)", x, perl = TRUE))[[1]]

  # 提取 y 和 z
  y <- matches[1]
  z <- matches[2]

  return(z)
}

monlist1 = c(0,12,24,36,48,60,72,84,96,108,132)
monlist1_list = c()
for(i in monlist1){
monlist1_list = c(monlist1_list,paste0("CF",i,"W"))
}


title="MinerVa.Prime"
ybreaks = c(5,10,seq(0,100,20),200)
ylables = c(5,10,seq(0,100,20),200)

df <- read.table("input.xls", header = T, stringsAsFactors = F) %>%
    mutate(HR_tmp = HR) %>%
    mutate(Time = gsub("_MinerVa.Prime","",Factor1)) %>%
    mutate(HR = as.numeric(unlist(lapply(HR_tmp, split_string)))) %>%
    mutate(CI = unlist(lapply(HR_tmp, split_string2))) %>%
    mutate(Cohort = factor(Cohort, ordered = T, levels = c("All", "Target", "Chemo")),
           Time   = factor(Time,ordered = T, levels = monlist1_list),
           CI_low = as.numeric(gsub("[-].*", "", CI)),
           CI_high = as.numeric(gsub(".*[-]", "", CI))) %>%
    arrange(Cohort) %>% group_by(Time) %>%
    mutate(group_number = paste0(Cohort_number, collapse = " | "),
           Stage_new = paste0(Time, "\n", "(", group_number ,")"))
  df$Stage_new = factor(df$Stage_new,levels=unique(df$Stage_new))
df
df$Cohort = gsub("Target","Icotinib",df$Cohort)
df$Cohort = gsub("Chemo","Chemotherapy",df$Cohort)
df$Cohort = factor(df$Cohort,levels=c("All","Icotinib", "Chemotherapy"))
 pdf("MinerVa.Prime_log3.pdf", width = 6, height = 4, pointsize = 12)
  p <- ggplot(data = df,
              aes(x = Stage_new, y = HR,
                  ymin = CI_low, ymax = CI_high,
                  colour = Cohort, fill = Cohort))+
#                  size = Cohort_number^0.5)) +
    #geom_histogram(stat = "identity", width = 0.6,  position = position_dodge(0.7)) +
    geom_errorbar(position = position_dodge(width = 0.7), width = 0.4, color = "black", size = 0.4) +
    geom_point(position = position_dodge(width = 0.7)) +
    scale_y_continuous(trans="log2",breaks=ybreaks, labels=ylables)+
    #geom_point(position = position_dodge(width = 0.7), size = 0.5, color = "black") + 
    #scale_color_jama() +
    #facet_wrap(vars(Research_group), ncol = 4, scales = "free_x") +
    #scale_y_continuous(limits  = c(0, 100), breaks = seq(0, 100, by = 25),
    #                   labels = function(x) paste0(x, "%"), ) +
   #scale_y_continuous(limits  = c(0, 65))+
#    scale_size_continuous(limits = c(0, 15)) +
    guides(size = "none") +
    ylab("HR")  +
    xlab("Time since randomization (weeks)") +
    theme_bw() +
    theme(
panel.background = element_rect(fill = 'transparent'),
        panel.border = element_rect(fill = NA, colour = "black"),
  panel.grid.major = element_blank(),     # 去掉大网格线
    panel.grid.minor = element_blank(),     # 去掉小网格线
axis.text.x = element_text(angle = 45, hjust = 1,size=8),
strip.background = element_blank(),
          strip.text = element_text(face = "bold", size = 6),
          legend.position = "top")+ 
scale_color_manual(name='Cohort', values=c("All" = "#B24745FF","Icotinib"="#00A1D5FF", "Chemotherapy"="#6A6599FF"))
#    ggsci::scale_color_jama(alpha = 0.9)+ ggtitle(title)
#scale_color_npg()+ ggtitle(title)
  print(p)
  dev.off()

