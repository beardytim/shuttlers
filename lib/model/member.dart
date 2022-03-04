class Member implements Comparable<Member> {
  final String id;
  final String name;
  final double bank;

  const Member({
    required this.id,
    required this.name,
    required this.bank,
  });

  int compareTo(Member other) {
    int order = name.compareTo(other.name);
    return order;
  }

  //pass to this function the documentID and then make that the member ID?
  Member.fromMap(Map<String, dynamic> data, String id)
      : this(
          id: id,
          name: data['name'],
          bank: data['bank'].toDouble(),
        );
}
