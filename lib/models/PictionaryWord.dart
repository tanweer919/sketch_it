class PictionaryWord {
  int level;
  String word;
  PictionaryWord({this.level, this.word});

  PictionaryWord.fromJson(Map<String, dynamic> parsedJson)
    : this.level = parsedJson["level"],
      this.word = parsedJson["word"];
}