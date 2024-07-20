class MenuItem {
  final String title;
  final String imagePath;
  final String routeName;

  MenuItem(
      {required this.title, required this.imagePath, required this.routeName});
}

final List<MenuItem> menuItems = [
  MenuItem(
      title: 'I Miss You',
      imagePath: 'assets/images/imissyou.png',
      routeName: '/i_miss_you'),
  MenuItem(
      title: 'How Are You',
      imagePath: 'assets/images/howareyou.png',
      routeName: '/how_are_you'),
  MenuItem(
      title: 'I See You',
      imagePath: 'assets/images/iseeyou.png',
      routeName: '/i_see_you'),
];
