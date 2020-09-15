# tinypandas

TODO: Write a description here

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     tinypandas:
       github: orangeSi/tinypandas
   ```

2. Run `shards install`

## Features
```
1. support seprated by tab format or csv or vcf format file
```
## Usage

test code is in ```example/test.cr``` like this:
```crystal
require "tinypandas"

pd = Tinypandas.new

## support seprate by tab format file
df = pd.read_table(ifile, sep: "\t") # def read_table(filepath_or_buffer : String, sep = "\t", delimiter : String = "\n", header : HeaderType = 0, index_col : IndexColType = 0, comment : String|Regex = "#", skiprows : SkiprowsType = false, skip_blank_lines : Bool = true)

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


## support vcf format file
df = pd.load_vcf("demo.vcf")
puts "df.head(1).to_s is\n"
puts df.head(1).to_s
puts "\n"

## support csv format file

puts "df.head(1).t.to_s is\n"
df = pd.load_csv("sample.csv")
puts "df is #{df}\n"
puts "df.to_str is\n#{df.to_str}\n"
puts "df[col2][2] is #{df["col2"]["2"]}\n"


```
then go to example ```cd example; crystal build test.cr --release```
```
$cat demo.xls
# note
	A1	A3	A2
B1	1	3	2
B2	7	2	8
B3	4	9	5
```
then ```./test demo.xls``` or ```./test demo.xls.gz```
will get this:
```
## support seprate by tab format file
intpu file demo.xls

df is DataFrame(@dict={"A1" => Series(@dict={"B1" => 1, "B2" => 7, "B3" => 4}), "A3" => Series(@dict={"B1" => 3, "B2" => 2, "B3" => 9}), "A2" => Series(@dict={"B1" => 2, "B2" => 8, "B3" => 5})}, @index=["B1", "B2", "B3"], @columns=["A1", "A3", "A2"])

df.to_str is
	A1	A3	A2
B1	1	3	2
B2	7	2	8
B3	4	9	5

df[A2][B3] is 5
df[df[A2]>=5].to_str is
	A1	A3	A2
B2	7	2	8
B3	4	9	5

df[df[A3]==9][A2].to_str is 
B3	5

df[df[A3]>=3][A2].to_str is 
B1	2
B3	5
t = df[A2]is Series(@dict={"B1" => 2, "B2" => 8, "B3" => 5})
t>2 is Series(@dict={"B2" => 8, "B3" => 5})

df.t.to_str is
	B1	B2	B3
A1	1	7	4
A3	3	2	9
A2	2	8	5

df.t[B3][A1] is 
4

## support vcf format file
df.head(1).to_s is
	#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	HG00096	HG00097	HG00099
0	MT	10	.	T	C	100	fa	VT=S;AC=3	GT	0	0	0

## support csv format file
df is DataFrame(@dict={"date" => Series(@dict={"0" => "2020-02-01 12:00:02", "1" => "2020-02-01 12:00:07", "2" => "2020-02-01 12:00:12", "3" => "2020-02-01 12:00:17", "4" => "2020-02-01 12:00:22", "5" => "2020-02-01 12:00:27", "6" => "2020-02-01 12:00:32", "7" => "2020-02-01 12:00:37"}), "col1" => Series(@dict={"0" => 66808, "1" => 66873, "2" => 66875, "3" => 66874, "4" => 66881, "5" => 66858, "6" => 66905, "7" => 66885}), "col2" => Series(@dict={"0" => 0.68, "1" => 0.67, "2" => 0.65, "3" => 0.67, "4" => 0.67, "5" => 0.66, "6" => 0.64, "7" => 0.66}), "col3" => Series(@dict={"0" => "TRUE", "1" => "FALSE", "2" => "TRUE", "3" => "FALSE", "4" => "TRUE", "5" => "FALSE", "6" => "TRUE", "7" => "FALSE"}), "col4" => Series(@dict={"0" => "str1", "1" => "str2", "2" => "str3", "3" => "str4", "4" => "str5", "5" => "str6", "6" => "str7", "7" => "str8"})}, @index=["0", "1", "2", "3", "4", "5", "6", "7"], @columns=["date", "col1", "col2", "col3", "col4"])
df.to_str is
	date	col1	col2	col3	col4
0	2020-02-01 12:00:02	66808	0.68	TRUE	str1
1	2020-02-01 12:00:07	66873	0.67	FALSE	str2
2	2020-02-01 12:00:12	66875	0.65	TRUE	str3
3	2020-02-01 12:00:17	66874	0.67	FALSE	str4
4	2020-02-01 12:00:22	66881	0.67	TRUE	str5
5	2020-02-01 12:00:27	66858	0.66	FALSE	str6
6	2020-02-01 12:00:32	66905	0.64	TRUE	str7
7	2020-02-01 12:00:37	66885	0.66	FALSE	str8
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/orangeSi/tinypandas/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [orangeSi](https://github.com/orangeSi) - creator and maintainer
