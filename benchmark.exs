sentence = "すもももももももものうち"

Benchee.run(%{
  "parse" => fn ->
    YAMeCab.parse(sentence)
  end
},
  parallel: 4,
  time: 10,
  memory_time: 2,
  load: "./priv/save.benchee",
  save: [path: "./priv/save.benchee", tag: "port-driver-baseline"]
)
