require "json"

alias puts_immediate __puts__ unless respond_to?(:puts_immediate)

json = $gtk.read_file("crimes.json")

N = 10

def benchmark
  GC.start
  start = Time.now
  yield
  (Time.now - start) * 1000
end

threshhold = N.map {
  i = 0
  n = json.size

  benchmark {
    while i < n
      json.getbyte(i)
      i += 1
    end
  }
}
puts_immediate "Threshhold Time: #{threshhold.min.to_sf}ms"

puts_immediate "Parsing `test/crimes.json` #{N} times…"

data = N.map { benchmark { Argonaut::JSON.parse(json, extensions: true) } }
mean = data.sum / data.size
var = data.map { |time| (time - mean)**2 }.sum / data.size
puts_immediate "Average Time: #{mean.to_sf}ms ± #{Math.sqrt(var).to_sf}ms"
puts_immediate "Fastest Time: #{data.min.to_sf}ms"
puts_immediate "Slowest Time: #{data.max.to_sf}ms"

$gtk.write_file("tmp/benchmark.json", <<~JSON)
  [
    {
      "name": "Time to parse crimes.json",
      "value": #{mean},
      "unit": "ms",
      "range": "± #{Math.sqrt(var).to_sf}ms"
    }
  ]
JSON
