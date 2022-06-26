sentence = "すもももももももものうち"

Benchee.run(%{
  "parse" => fn {_, mecab} ->
    YAMeCab.parse(mecab, sentence)
  end
},
  before_scenario: fn input ->
    {:ok, mecab} = YAMeCab.start_link([])
    {input, mecab}
  end,
  parallel: 4,
  time: 10,
  memory_time: 2,
  load: "./priv/save.benchee",
  save: [path: "./priv/save.benchee", tag: "fix-string"]
)
