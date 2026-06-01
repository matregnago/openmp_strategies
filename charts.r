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


long_df <- summary_df |>
  pivot_longer(
    cols = c(speedup, eff),
    names_to = "metric",
    values_to = "value"
  ) |>
  mutate(metric = factor(metric,
    levels = c("speedup", "eff"),
    labels = c("Speedup", "Eficiência Paralela (%)")
  ))

ggplot(long_df, aes(x = omp_num_threads, y = value, color = algorithm)) +
  geom_point() +
  geom_line() +
  facet_wrap(~metric, scales = "free_y") +
  labs(
    x = "Numero de Threads",
    y = NULL,
    title = "Speedup e Eficiência Paralela pelo número de threads",
    color = "Algoritmos"
  ) +
  theme_bw()

ggsave("plots/speedup_eff.pdf", width = 10, height = 4)


df <- read_csv("results/phase2.csv")


summary_df <- df |>
  group_by(algorithm, omp_schedule, chunk) |>
  summarise(
    mean_time = mean(time),
    sd = sd(time)
  )
ggplot(summary_df, aes(fill = omp_schedule, y = mean_time, x = factor(chunk))) +
  geom_bar(position = "dodge", stat = "identity") +
  geom_errorbar(aes(ymin = mean_time - sd, ymax = mean_time + sd),
    width = .5,
    position = position_dodge(.9)
  ) +
  facet_wrap(~algorithm) +
  labs(
    title = "Escalonadores",
    fill = "OMP Schedule"
  ) +
  theme_bw()


ggsave("plots/schedule.pdf", width = 6, height = 4)

df <- read_csv("results/phase3.csv")

summary_df <- df |>
  group_by(algorithm, omp_proc_bind, omp_places) |>
  summarise(
    mean_time = mean(time)
  )

ggplot(summary_df, aes(x = omp_places, y = omp_proc_bind, fill = mean_time)) +
  facet_wrap(~algorithm) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(mean_time, 2)), color = "black", size = 4) +
  scale_fill_viridis_c() +
  theme_minimal()
ggsave("plots/bind_and_places.pdf", width = 6, height = 4)


df <- read_csv("results/phase4.csv")


summary_df <- df |>
  group_by(algorithm, first_touch, omp_num_threads) |>
  summarise(
    mean_time = mean(time),
    sd = sd(time)
  )

ggplot(summary_df, aes(
  fill = factor(first_touch), y = mean_time,
  x = factor(omp_num_threads)
)) +
  geom_bar(position = "dodge", stat = "identity") +
  geom_errorbar(aes(ymin = mean_time - sd, ymax = mean_time + sd),
    width = .5,
    position = position_dodge(.9)
  ) +
  labs(
    title = "Stencil2d",
    fill = "First touch"
  ) +
  theme_bw()


ggsave("plots/first_touch.pdf", width = 6, height = 4)
