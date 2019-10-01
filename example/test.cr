require "tinypandas"


raise "usage:./test yy.xls\n" if ARGV.size == 0
ifile = ARGV[0]
puts "intpu file #{ifile}"
pd = Tinypandas.new
df = pd.read_table(ifile)
puts "df is #{df}\n"
puts "df.to_str is\n#{df.to_str}\n"
puts "df[A2][B3] is #{df["A2"]["B3"]}\n"
puts "df[df[A2]>=5].to_str is"
puts df[df["A2"]>=5].to_str

puts "df[df[A3]==9][A2].to_str is "
puts df[df["A3"]==9]["A2"].to_str

puts "df[df[A3]>=3][A2].to_str is "
puts df[df["A3"]>=3]["A2"].to_str
t = df["A2"]
puts "t = df[A2]is #{t}"
puts "t>2 is #{t>2}"
puts "df.t.to_str is\n#{df.t.to_str}"
puts "df.t[B3][A1] is "
puts df.t["B3"]["A1"]
