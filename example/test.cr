require "../src/tinypandas"

# crystal example/test.cr ./example/demo.xls
raise "usage:./test yy.xls\n" if ARGV.size == 0
ifile = ARGV[0]
puts "intpu file #{ifile}"
pd = Tinypandas.new
df = pd.read_table(ifile, sep: "\t") # def read_table(filepath_or_buffer : String, sep = "\t", t : Int32|Bool = 0, delimiter : String = "\n", header : HeaderType = 0, index_col : IndexColType = 0, comment : String|Regex = "#", skiprows : SkiprowsType = false, skip_blank_lines : Bool = true)
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

df2 = pd.read_table(ifile, sep: "\t", index_col: 1)
puts "df2 is #{df2}\n"
puts "df2.to_str is\n#{df2.to_str}\n\n"

df = pd.read_table("demo.vcf", sep: "\t", index_col: nil, comment: "##")
puts "df.to_str is\n#{df.to_str}\n\n"
puts "df.head(1).to_s is\n" 
puts df.head(1).to_s
puts "\n"

df = pd.load_vcf("demo.vcf")
puts "load_vcf\n"
puts "df.head(1).to_s is\n" 
puts df.head(1).to_s
puts "\n"
##


puts "Testing CSV import"
#filename = "./example/sample.csv"
filename = "sample.csv"

pd = Tinypandas.new
df = pd.load_csv(filename)
puts "df is #{df}\n"
puts "df.to_str is\n#{df.to_str}\n"
puts "df[col2][2] is #{df["col2"]["2"]}\n"

#puts "df2.to_str is\n#{df2.to_str}\n\n"
#puts "df.to_str is\n#{df.to_str}\n"



## read Array(Array()) as DataFrame
data = [[1,2,3],[4,5,6],[6,7,8]]
df = DataFrame.new(data, columns: ["c1","c2","c3"]) # read_array_by_row: true
puts "\nArray(Array()):#{data} to DataFrame:\n#{df.to_s}"


## read Hash(String, Array()) as DataFrame
data = {"c1"=>[1,2,3], "c2"=>[4,5,6], "c3"=>[6,7,8]}
df = DataFrame.new(data)
puts "\nHash(String, Array()):#{data} to DataFrame:\n#{df.to_s}"
