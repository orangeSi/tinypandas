

struct Series 
	alias VTYPE = String|Float32|Int32|Int64|Float64|(Int32|Int64)|(Float32|Float64)|(Float32|String)|(Float64|Int32)|(Float32|Int32)|(Float64|String)|(Int64|String)|(Int32|String)|(Float64|Int64)|(Float32|Int64)|(Float32|Float64|Int32)|(Float32|Int32|Int64)|(Float32|Int64|String)|(Float64|Int32|String)|(Float64|Int64|String)|(Float32|Float64|Int64)|(Float32|Int32|String)|(Float32|Float64|String)|(Float64|Int32|Int64)|(Int32|Int64|String)|(Float32|Int32|Int64|String)|(Float32|Float64|Int32|Int64)|(Float64|Int32|Int64|String)|(Float32|Float64|Int64|String)|(Float32|Float64|Int32|String)|(Float32|Float64|Int32|Int64|String) # mass by Float32|Float64|Int32|Int64|String with mass.type.pl
	alias KTYPE = String
	alias KTYPE2ARRAY = Array(KTYPE)
	alias VTYPE2ARRAY = Array(Int64)|Array(Int32)|Array(Float64)|Array(Float32)|Array(String)|Array(Int64|String)|Array(Float64|Int64)|Array(Float32|Float64)|Array(Int32|Int64)|Array(Float64|String)|Array(Float32|Int32)|Array(Int32|String)|Array(Float64|Int32)|Array(Float32|String)|Array(Float32|Int64)|Array(Float64|Int64|String)|Array(Float32|Float64|Int32)|Array(Float64|Int32|String)|Array(Float32|Int64|String)|Array(Int32|Int64|String)|Array(Float32|Float64|Int64)|Array(Float64|Int32|Int64)|Array(Float32|Int32|String)|Array(Float32|Int32|Int64)|Array(Float32|Float64|String)|Array(Float64|Int32|Int64|String)|Array(Float32|Float64|Int32|Int64)|Array(Float32|Float64|Int32|String)|Array(Float32|Float64|Int64|String)|Array(Float32|Int32|Int64|String)|Array(Float32|Float64|Int32|Int64|String)
	property dict = Hash(KTYPE, VTYPE).new
	def initialize(data : VTYPE2ARRAY = [] of Int32, index : KTYPE2ARRAY = [] of String ) # index only suuport String
		if data.is_a?(Array)
			use_index : Bool
			if index.size > 0
				if index.size != data.size
					raise "error, index size and data size is not equal\n"
				end
				use_index = true
			else
				use_index = false
			end
			# copy data to arrray
			data.each_with_index do |v, i|
				dict[use_index ? index[i].to_s : i.to_s] = v
			end

		elsif data.is_a?(Hash)
			raise "warn: Series support Hash is wait to do~\n"	
		else
			raise "error: Series only support input Array or Hash yet\n"
		end
	end

	def size
		return dict.keys.size
	end
	
	def [](i : KTYPE)
		return dict[i]
	end

	def [](i : Int32|Int64)
		return dict.values[i]
	end
	

	def [](range : Range)
		result = Array(VTYPE).new
		range_index = Array(KTYPE).new 
		(range).to_a.each do |e|
			raise "error: #{e} not in Series\n" if self.size < e
			result << self[e]
			range_index << e.to_s
		end
		return Series.new(result, index: range_index)
	end
	
	def [](*arg : KTYPE|Int32|Int64)
		result = Array(VTYPE).new
		result_index = Array(KTYPE).new
		arg.each do |e|
			if e.is_a?(KTYPE)
				raise "error: #{e} not in Series\n" unless dict[e]
				result << dict[e]
				result_index << e
			else
				raise "error: #{e} not in Series\n" if self.size < e
				result << self[e]
				result_index << e.to_s
			end
		end
		return Series.new(result, index: result_index)
	end

	def [](bool : Array(Bool))
		result = Array(VTYPE).new
		#bool.each_with_index do |v, i|
		#	 result << dict[i] if v 
		#end
		result_index = Array(KTYPE).new
		dict.keys.each_with_index do |v, i|
			next unless bool[i]
			result << dict[v]
			result_index << v
		end
		return Series.new(result, index: result_index)
	end

	def >(other : Number)
		bool = [] of Bool
		dict.values.each do |e|
			if e.is_a?(Number)  && e > other
				bool << true
			else
				bool << false
			end
		end
		return self[bool]
	end

	def >=(other : Number)
		bool = [] of Bool
		dict.values.each do |e|
			if e.is_a?(Number)  && e >= other
				bool << true
			else
				bool << false
			end
		end
		return self[bool]
	end

	def <(other : Number)
		bool = [] of Bool
		dict.values.each do |e|
			if e.is_a?(Number)  && e < other
				bool << true
			else
				bool << false
			end
		end
		return self[bool]
	end
	def <=(other : Number)
		bool = [] of Bool
		dict.values.each do |e|
			if e.is_a?(Number)  && e <= other
				bool << true
			else
				bool << false
			end
		end
		return self[bool]
	end
	def ==(other : Number)
		bool = [] of Bool
		dict.values.each do |e|
			if e.is_a?(Number)  && e == other
				bool << true
			else
				bool << false
			end
		end
		return self[bool]
	end
	def ==(other : String)
		bool = [] of Bool
		dict.values.each do |e|
			if e.is_a?(String)  && e == other
				bool << true
			else
				bool << false
			end
		end
		return self[bool]
	end

	def values
		return dict.values
	end
   
	def to_a
		return dict.values
	end

	def index
		return dict.keys
	end

	def each

	end
	
	def add(value : VTYPE)
		key = self.size.to_s
		raise "error: when add(#{value}), key has exists, you can try add(key, value)\n" if dict.has_key?(key)
		dict[key] = value
	end
	def add(key : KTYPE, value :  VTYPE, overwrite = true)
		#raise "error: key #{key} has exists, use add(key, value, overwrite: true) to ignore this\n" if overwrite == false && dict.has_key?(key) 
		dict[key] = value
	end
	def to_str(sep : String = "\t")
		str = ""
		dict.keys.each do |i|
			str = "#{str}#{i}\t"
			str ="#{str}#{dict[i]}#{sep}"
			str = str.gsub(/#{sep}$/, "\n")
		end
		return str
	end

	def to_s(sep : String = "\t")
		return self.to_str(sep)
	end

end



def series_test
	t1 = Series.new([1,2,4,"c","d"])
	puts "t1 is #{t1}"
	puts "array is #{t1.to_a}"
	puts "t1[1..2] is #{t1[1..2]}"
	puts "t1[t>2] is #{t1[t1>2]}"
	puts "t1[0,2,3] is #{t1[0,2,3]}"

	t1.add 5.3
	puts "after t1.add 5.3, t is #{t1}"
	puts ""


	t = Series.new([1,2,4,"c","d"], index: ["00","11", "22", "33", "44"])
	puts "t is #{t}"
	puts "array is #{t.to_a}"
	puts "t.to_a[1..2] is #{t.to_a[1..2]}"
	puts "t[t>2] is #{t[t>2]}"
	xx = t["22","44"]
	puts "t[\"22\",\"44\"] is #{xx}"
	t.add "55", 5.6
	puts "after t < \"55\", 5,  t is #{t}"

	t2 = Series.new
	t2.add 3
	puts "t2 is #{t2}"
end
