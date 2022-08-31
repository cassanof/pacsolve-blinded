library(tidyverse)
library(ggplot2)
library(kimisc)



data_dir <- "../permanently_saved_results/federico-vuln-exp"
vuln <- read_csv(str_c(data_dir, "/aug_27_gather.csv"),
        col_types ="ccfddfc")
results_tex <- str_c(data_dir, "/results.tex")
plots_dir <- str_c(data_dir, "/plots")
write("% These are results from the R Notebook.", results_tex, append=FALSE)
dir.create(plots_dir, showWarnings = FALSE)
vuln <- vuln %>% select(-NDeps,-Status,-Time)




mytheme <- function() {
  return(theme_bw() +
           theme(
             # NOTE: UNCOMMENT WHEN RENDING PLOTS FOR THE PAPER
             # (can't get the CM fonts to work in artifact VM...)
             text = element_text(family = "Times", size=10),
              panel.grid.major = element_blank(),
             # panel.grid.minor = element_blank(),
             # panel.grid.major = element_line(colour="gray", size=0.1),
             # panel.grid.minor =
             #  element_line(colour="gray", size=0.1, linetype='dotted'),
             axis.ticks = element_line(size=0.05),
             axis.ticks.length=unit("-0.05", "in"),
             axis.text.y = element_text(margin = margin(r = 5)),
             axis.text.x = element_text(hjust=1),
             legend.key = element_rect(colour=NA),
             legend.spacing = unit(0.001, "in"),
             legend.key.size = unit(0.2, "in"),
             legend.title = element_blank(),
             legend.position = c(0.75, .7),
             legend.background = element_blank()))
}

mysave <- function(filename) {
  path <- str_c(plots_dir, "/", filename)
  ggsave(path, width=4, height=3, units=c("in"))
  # embed_font(path)
}


# What does it mean when status is "missing" - and should we only include those that have no missing?
# There are 225/1000 project-versions that have non-NA results: what is missing there?
vulnByProject <- vuln %>%
    # replace_na(list(CVE=-1)) %>%
    pivot_wider(names_from=solver, values_from=CVE, names_prefix="CVE.") #%>%
    # group_by(name,commit) %>%
    # summarise(across(starts_with("CVE."), ~sum(.x,na.rm=TRUE))) %>% ungroup()
head(vulnByProject)
nrow(vulnByProject

breaks <- c(0, 1, 10, 25, 50, 100, 1000)
bucketedVuln <- vulnByProject %>%
    filter(`CVE.audit fix` >= 0 & `CVE.audit fix force`>=0 & `CVE.maxnpm_cve_oldness`>=0) %>%
    mutate(across(starts_with('CVE'), ~cut_format(.x, breaks=breaks))) %>% # Bucket all CVE columns
    mutate_if(is.factor, as.character) %>%  # Default is these are factors, make them char so easier to handle
    mutate(across(starts_with('CVE'), ~replace(.,is.na(.), '0'))) %>% # If it was NA, it was because it was outside of the range, aka == 0
    group_by(`CVE.audit fix`,`CVE.maxnpm_cve_oldness`) %>% summarise(count=n()) %>%
    # Sum the count for CVE audit fix and add a row for that called 'total'
    bind_rows(group_by(.,`CVE.audit fix`) %>%
        summarise(count=sum(count)) %>%
        mutate(`CVE.maxnpm_cve_oldness`='Total')) %>%
    bind_rows(group_by(.,`CVE.maxnpm_cve_oldness`) %>%
        summarise(count=sum(count)) %>%
        mutate(`CVE.audit fix`='Total'))

# Create a matrix where the columns are for audit fix, rows are for MaxNPM
bucketedVuln %>%
    pivot_wider(names_from=`CVE.audit fix`, values_from=count) %>%
    relocate(`0`, .before=`(   1,   10]`) %>%
    mutate_if(is.numeric,~replace(.,is.na(.), 0)) %>%
    arrange(CVE.maxnpm_cve_oldness) #%>%
        # kable("html", booktabs=TRUE, linesep="", digits=0, escape=FALSE, format.args = list(big.mark = ",",
        #   scientific = FALSE)) %>% as.character() %>% display_html()

vulnByProject %>% filter(name == 'spreadable')

change_cat <- function(x) {
    ifelse(is.na(x), NA, ifelse(x == 0, "same", ifelse(x > 0, "better", "worse")))
}



CVEDiff <- vulnByProject %>%
    mutate(CVEDiff=`CVE.audit fix` - `CVE.maxnpm_cve_oldness`, CVEPIPDiff=`CVE.audit fix` - `CVE.maxnpm_cve_oldness_pip_else_npm`) %>%
    mutate(CVEDiff=round(CVEDiff, 6)) %>%
    mutate(CVEPIPDiff=round(CVEPIPDiff, 6)) %>%
    mutate(CVEChangeCat=change_cat(CVEDiff)) %>%
    mutate(CVEPIPChangeCat=change_cat(CVEPIPDiff))

head(CVEDiff)



CVEDiff %>% 
  ggplot(aes(`CVE.maxnpm_cve_oldness` - `CVE.audit fix`  )) +
  stat_ecdf() +
  ylab("Percentange of packages") +
  xlab("Difference in CVE badness between NPM and MaxNPM") +
  mytheme()
mysave("cve-diff-ecdf.pdf")



CombinedData <- CVEDiff %>% 
    filter(!is.na(CVEDiff))# %>%
    # filter(CVEDiff >= -50 & CVEDiff <= 300)

same_rows <- CombinedData %>% filter(CVEChangeCat != 'better')
better_rows <- CombinedData %>% filter(CVEChangeCat == 'better')
# worse_rows <- CombinedData %>% filter(CVEChangeCat == 'worse')

colors <- c("Same or Worse" = "gray", "Better" = "#00BA38")
ggplot(CombinedData, aes(x= CVEDiff)) + mytheme() + geom_histogram(data = same_rows, aes(fill = "Same or Worse"), alpha = 1, bins=50) + geom_histogram(data = better_rows, aes(fill = "Better"), alpha=1, bins=50) + scale_fill_manual(values=colors) + xlab('CVE improvement with MaxNPM') + ylab('Count')

mysave('cve-diff-hist.pdf')

total_count <- nrow(CVEDiff)
all_ok_count <- nrow(CVEDiff %>% filter(!is.na(CVEDiff)))
maxnpm_better_count <- nrow(CVEDiff %>% filter(CVEDiff > 0))
maxnpm_same_count <- nrow(CVEDiff %>% filter(CVEDiff == 0))
maxnpm_worse_count <- nrow(CVEDiff %>% filter(CVEDiff < 0))
cve_diff_mean <- mean(CVEDiff$CVEDiff, na.rm=T)
all_ok_perc <- all_ok_count / total_count
maxnpm_better_total_perc <- maxnpm_better_count / total_count
maxnpm_better_ok_perc <- maxnpm_better_count / all_ok_count

write(
  str_c("\\newcommand{\\dataCveExpTotalCount}{", 
        total_count,
        "}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpSuccessCount}{", 
        all_ok_count,
        "}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpMaxNpmBetterCount}{", 
        maxnpm_better_count,
        "}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpMaxNpmSameCount}{", 
        maxnpm_same_count,
        "}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpMaxNpmWorseCount}{", 
        maxnpm_worse_count,
        "}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpMeanCveDiff}{", 
        round(cve_diff_mean, 2),
        "}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpSuccessPerc}{", 
        round(100 * all_ok_perc),
        "\\%}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpMaxNpmBetterTotalPerc}{", 
        round(100 * maxnpm_better_total_perc),
        "\\%}\n"),
  results_tex, append=TRUE)
write(
  str_c("\\newcommand{\\dataCveExpMaxNpmBetterSuccessPerc}{", 
        round(100 * maxnpm_better_ok_perc),
        "\\%}\n"),
  results_tex, append=TRUE)

CVEDiff %>% filter(CVEDiff < 0)

CVEDiff %>% filter(CVEDiff > 0) %>% arrange(CVEDiff)
