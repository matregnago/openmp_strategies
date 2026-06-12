library(tidyverse)

theme_set(
  theme_bw(base_size = 13) +
    theme(
      legend.position = "bottom",
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "grey90")
    )
)

algo_labels <- c(mandelbrot = "Mandelbrot", stencil2d = "Stencil 2D")

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

thread_breaks <- sort(unique(summary_df$omp_num_threads))

ggplot(long_df, aes(x = omp_num_threads, y = value)) +
  geom_line(aes(color = algorithm)) +
  geom_point(aes(color = algorithm, shape = algorithm), size = 2.5) +
  facet_wrap(~metric, scales = "free_y") +
  scale_x_continuous(trans = "log2", breaks = thread_breaks) +
  scale_color_brewer(palette = "Set1", labels = algo_labels) +
  scale_shape_manual(values = c(16, 17), labels = algo_labels) +
  labs(
    x = "Número de threads",
    y = NULL,
    color = "Algoritmo",
    shape = "Algoritmo"
  )

ggsave("plots/speedup_eff.pdf", width = 9, height = 4)


df <- read_csv("results/phase2.csv")

summary_df <- df |>
  group_by(algorithm, omp_schedule, chunk) |>
  summarise(
    mean_time = mean(time),
    sd = sd(time)
  ) |>
  mutate(
    omp_schedule = factor(omp_schedule,
      levels = c("static", "dynamic", "guided", "auto")
    )
  )

ggplot(summary_df, aes(fill = omp_schedule, y = mean_time, x = factor(chunk))) +
  geom_col(position = "dodge", color = "black", linewidth = 0.2) +
  geom_errorbar(aes(ymin = mean_time - sd, ymax = mean_time + sd),
    width = .4, linewidth = 0.3,
    position = position_dodge(.9)
  ) +
  facet_wrap(~algorithm,
    scales = "free_y",
    labeller = labeller(algorithm = algo_labels)
  ) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    x = "Tamanho do chunk",
    y = "Tempo médio (s)",
    fill = "Política"
  )

ggsave("plots/schedule.pdf", width = 9, height = 4)


df <- read_csv("results/phase3.csv")

summary_df <- df |>
  group_by(algorithm, omp_proc_bind, omp_places) |>
  summarise(
    mean_time = mean(time)
  ) |>
  mutate(
    omp_proc_bind = factor(tolower(omp_proc_bind),
      levels = c("false", "true", "master", "close", "spread")
    )
  )

ggplot(summary_df, aes(x = omp_places, y = omp_proc_bind, fill = mean_time)) +
  facet_wrap(~algorithm, labeller = labeller(algorithm = algo_labels)) +
  geom_tile(color = "white") +
  geom_text(aes(
    label = sprintf("%.2f", mean_time),
    color = mean_time < median(summary_df$mean_time)
  ), size = 3.5, show.legend = FALSE) +
  scale_fill_viridis_c(trans = "log10", guide = "none") +
  scale_color_manual(values = c(`TRUE` = "white", `FALSE` = "black")) +
  labs(
    x = "OMP_PLACES",
    y = "OMP_PROC_BIND"
  ) +
  theme(panel.grid = element_blank())

ggsave("plots/bind_and_places.pdf", width = 8, height = 3.5)


df <- read_csv("results/phase4.csv")

summary_df <- df |>
  group_by(algorithm, first_touch, omp_num_threads) |>
  summarise(
    mean_time = mean(time),
    sd = sd(time)
  ) |>
  mutate(
    first_touch = factor(first_touch,
      levels = c(0, 1),
      labels = c("Sequencial", "Paralela (first-touch)")
    )
  )

ggplot(summary_df, aes(
  fill = first_touch, y = mean_time,
  x = factor(omp_num_threads)
)) +
  geom_col(position = "dodge", color = "black", linewidth = 0.2) +
  geom_errorbar(aes(ymin = mean_time - sd, ymax = mean_time + sd),
    width = .4, linewidth = 0.3,
    position = position_dodge(.9)
  ) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    x = "Número de threads",
    y = "Tempo médio (s)",
    fill = "Inicialização"
  )

ggsave("plots/first_touch.pdf", width = 7, height = 4)
