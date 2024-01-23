@time using DelimitedFiles
using BenchmarkTools
data = readdlm("data/example_spectrum.txt")
x = data[:, 1]
y = data[:, 2]


@btime raw = findpeaks($y);
@btime d2 = findpeaks_allen($y, $x);

d_peaks = filter_peaks(raw,
  A_min=50, minpeakheight=500, minpeakdistance=20)

# filter_peaks(df_peaks::DataFrame;
#   minpeakheight=-Inf, minpeakdistance::Int=1,
#   A_max=0, A_min=0

begin
  using Plots
  gr(framestyle=:box)

  # plot(x, y)
  plot(y)
  scatter!(d_peaks.pos_peak, d_peaks.val_peak,
    markersize=3,
    markerstrokewidth=1,
    markerstrokecolor=:white,
    label="Peak",
    markercolor=:red,
    markershape=:circle)

  spans = [d_peaks.pos_beg d_peaks.pos_end]
  val_spans = (spans')[:]
  vspan!(val_spans; alpha=0.2, label="Seasons", color=:red)
end
