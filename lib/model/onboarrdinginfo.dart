class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
    imageUrl: 'assets/introimg1.png',
    title: 'Ride Request',
    description: 'Request a ride and get picked up by a nearby driver',
  ),
  Slide(
    imageUrl: 'assets/introimg2.png',
    title: 'Ride Tracking',
    description: 'Track your driver location from your place ',
  ),
  Slide(
    imageUrl: 'assets/introimg3.png',
    title: 'Easy Payment',
    description: 'No more worry for payments',
  ),
];