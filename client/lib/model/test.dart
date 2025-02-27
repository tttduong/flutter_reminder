class Test {
  String? title;

  Test({this.title});

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      title: json['title'],
    );
  }
}
