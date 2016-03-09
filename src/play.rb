require 'csv'

# config
# file
csv_file = "c:/Projects/habrasound/data/2010-05.csv"
# pitch
low_note = note :c3
high_note = note :g9
notes_range = high_note - low_note
#tempo
min_bpm = 120
bpm_divider = 3
# duration
sleep_interval = 0.75
# fx
min_amp = 0.2
max_pulse_width = 0.999
# sound
user_synths = [:bell, :pretty_bell, :dull_bell, :piano, :growl, :bnoise]
company_synths = [:fm, :tb303, :subpulse, :zawa, :mod_beep, :cnoise]

# read data
data = CSV.read(csv_file)
puts "loaded #{data.length} lines"

# params
params = {
  max_date: 0,
  max_up: 0,
  max_down: 0,
  max_views: 0,
  min_views: 0,
  max_comments: 0
}

# fill params
data.each do |row|

  date = row[0]
  if params[date] == nil
    params[date] = 1
  else
    params[date] += 1
  end

  params[:max_date] = [params[:max_date], params[date]].max
  params[:max_up] = [params[:max_up], row[2].to_i].max
  params[:max_down] = [params[:max_down], row[3].to_i].max
  params[:max_views] = [params[:max_views], row[4].to_i].max
  params[:min_views] = [params[:min_views], row[4].to_i].min
  params[:max_comments] = [params[:max_comments], row[6].to_i].max

end

# pitch calculation
pitch_scale = (params[:max_views] - params[:min_views]).to_f / notes_range
puts "pitch scale: #{pitch_scale}"

# tempo
bpm = data.length.div(bpm_divider)
if bpm < min_bpm then bpm = min_bpm end
puts "bpm: #{bpm}"
use_bpm bpm

data.each do |row|

  # read data
  date = row[0]
  company = row[1]
  up = row[2]
  down = row[3]
  views = row[4]
  stars = row[5]
  comments = row[6]

  # music params
  # start note depends on count by date
  start_note = [high_note * (params[date] / params[:max_date]), low_note].max
  # pitch and duration depends on views number
  pitch = [start_note + views.to_i.div(pitch_scale), high_note].min
  duration = views.to_f/params[:max_views] + 1
  # amp depends on comments
  amp = min_amp
  unless comments.nil?
    amp = [min_amp, comments.to_f/params[:max_comments]].max
  end
  # echo depends on stars
  echo = 1
  unless stars.nil?
    stars = stars.to_f
    echo = 1 / stars.to_f unless stars != 0
  end
  # ring_mod depends on up votes
  ring_mix = 0
  unless up.nil?
    up = up.to_f
    ring_mix = up > 0 ? up/params[:max_up] : 0
  end
  # gverb depends on down votes
  damp = 0
  unless down.nil?
    down = down.to_f
    damp = down > 0 ? down / params[:max_down] : 1
  end
  # synth depends on company
  if company != nil
    use_synth choose(company_synths).to_sym
  else
    use_synth choose(user_synths).to_sym
  end

  # play
  in_thread do
    with_fx :echo, phase: echo do
      with_fx :ring_mod, mix: ring_mix do
        with_fx :gverb, damp: damp do
          play pitch, release: duration, amp: amp
        end
      end
    end
  end

  # euclidean beat just for fun
  sample :bd_haus, amp: 0.5 if (spread 2, 3).tick
  sample :elec_triangle, amp: 0.4 if (spread 4, 7).look
  sample :elec_twip, amp: 0.4 if (spread 4, 11).look

  sleep sleep_interval

end