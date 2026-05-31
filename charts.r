library(tidyverse)

df <- read_csv("results/phase1.csv")

summary_df <- df |>
  group_by(algorithm, omp_num_threads) |>
  summarise(
    mean_time = mean(time),
  ) |>
  group_by(algorithm) |>
  mutate(
    serial_time = mean_time[omp_num_threads == 1],
    speedup = serial_time / mean_time,
    eff = (speedup / omp_num_threads) * 100,
  )


ggplot(summary_df, aes(x = omp_num_threads, y = speedup, color = algorithm)) +
  geom_point() +
  geom_line() +
  scale_y_continuous(breaks = seq(0, 20, by = 5), limits = c(0, 20)) +
  labs(
    x = "Numero de Threads",
    y = "Speedup",
    title = "Speedup pelo número de threads",
    color = "Algoritmos"
  ) +
  theme_bw()

ggsave("plots/speedup.pdf", width = 6, height = 4)


ggplot(summary_df, aes(x = omp_num_threads, y = eff, color = algorithm)) +
  geom_point() +
  geom_line() +
  labs(
    x = "Numero de Threads",
    y = "Eficiência Paralela",
    title = "Eficiência Paralela pelo número de threads",
    color = "Algoritmos"
  ) +
  theme_bw()

ggsave("plots/eff.pdf", width = 6, height = 4)


df <- read_csv()
