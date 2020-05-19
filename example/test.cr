require "../src/tinypandas"

# crystal example/test.cr ./example/demo.xls
raise "usage:./test yy.xls\n" if ARGV.size == 0
ifile = ARGV[0]
puts "intpu file #{ifile}"
pd = Tinypandas.new
df = pd.read_table(ifile, sep = "\t") # def read_table(filepath_or_buffer : String, sep = "\t", t : Int32|Bool = 0, delimiter : String = "\n", header : HeaderType = 0, index_col : IndexColType = 0, comment : String|Regex = "#", skiprows : SkiprowsType = false, skip_blank_lines : Bool = true)
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


puts "Testing CSV import"
#filename = "./example/sample.csv"
filename = "sample.csv"

pd = Tinypandas.new
df = pd.load_csv(filename)
puts "df is #{df}\n"
puts "df.to_str is\n#{df.to_str}\n"
puts "df[col2][2] is #{df["col2"]["2"]}\n"
