##
# This script takes in population data in CSV format and turns it into
# something suitable to be put in api/app/services/pop_data.rb.

require 'csv'

@indent = 0

def write_out(line)
  puts (' ' * @indent) + line
end

def indent(indent, &block)
  @indent += indent
  yield
  @indent -= indent
end

write_out 'module Population'

data = {}

CSV.foreach(ARGV[0]) do |row|
  next if row[0] == 'Name'

  # format:
  # 0    1      2       3         4      5          6     7      8    9        10             11             12             13             14
  # Name,Domain,FormOID,DomainOID,Tscore,Population,Total,Female,Male,Age < 35,35 =< Age < 45,45 =< Age < 55,55 =< Age < 65,65 =< Age < 75,Age >= 75

  name = row[0]
  form_oid = row[2]
  t_score = row[4].to_i

  data[form_oid] ||= { name: name, data: {} }
  data[form_oid][:data][t_score] = [
    row[6].to_i, # total
    row[7].to_i, # female
    row[8].to_i, # male
    row[9].to_i, # age < 35
    row[10].to_i, # 35 <= age < 45
    row[11].to_i, # 45 <= age < 55
    row[12].to_i, # 55 <= age < 65
    row[13].to_i, # 65 <= age < 75
    row[14].to_i # age >= 75
  ]
end

indent(2) do
  write_out '# Total, Female, Male, Age < 35, 35 <= age < 45, 45 <= Age < 55, 55 <= Age < 65, 65 <= Age < 75, Age >= 75'
  write_out '@data = {'

  indent(2) do
    data.keys.sort.each_with_index do |form_oid, idx|
      d = data[form_oid]
      write_out "'#{form_oid}' => {"

      indent(2) do
        write_out ":name => '#{d[:name]}',"

        d[:data].keys.sort.each_with_index do |k, i|
          tmp = "#{k} => #{d[:data][k]}"
          tmp += ',' if i < d[:data].keys.size - 1
          write_out tmp
        end
      end

      if idx < data.keys.size - 1
        write_out '},'
      else
        write_out '}'
      end
    end
  end

  write_out '}'
end

write_out 'end'
