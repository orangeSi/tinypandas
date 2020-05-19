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

## Usage

test code is in ```example/test.cr``` like this:
```crystal
require "tinypandas"

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
