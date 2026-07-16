import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

class QuestCard extends StatelessWidget {
  final String id;
  final String title;
  final String location;
  final String imageurl;
  final String gpsurl;
  final bool isCompleted;
  final bool isAudioPlaying;
  final VoidCallback onComplete;
  final VoidCallback onListen;

  const QuestCard({
    super.key,
    required this.id,
    required this.title,
    required this.location,
    required this.imageurl,
    required this.gpsurl,
    required this.isCompleted,
    required this.isAudioPlaying,
    required this.onComplete,
    required this.onListen,
  });

  void _launchGPS() async {
    final Uri url = Uri.parse(gpsurl);
    try {

      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Could not launch GPS URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imageurl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF454543),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: _launchGPS,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 19,
                            color: Color(0xFF165B2E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF165B2E),
                              decoration: TextDecoration.underline,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: onListen,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAudioPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_outline,
                                color: const Color(0xFF165B2E),
                                size: 27,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAudioPlaying ? "Pause Track" : "Listen Story",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF454543),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onComplete,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isCompleted ? const Color(0xFF165B2E) : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCompleted ? "Completed" : "Mark Done",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF454543),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Top(),
  ));
}

class Top extends StatefulWidget {
  const Top({super.key});

  @override
  State<Top> createState() => _TopState();
}

class _TopState extends State<Top> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  bool _isplaying = false;
  Set<String> _completedQuests = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isplaying = false;
        _currentlyPlayingId = null;
      });
    });
  }

  void _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList('completed_quests');
    if (savedList != null) {
      setState(() {
        _completedQuests = savedList.toSet();
      });
    }
  }

  void _toggleQuestCompletion(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_completedQuests.contains(questId)) {
        _completedQuests.remove(questId);
      } else {
        _completedQuests.add(questId);
      }
    });
    await prefs.setStringList('completed_quests', _completedQuests.toList());
  }

  void _toggleAudio(String questId, String assetPath) async {
    if (_currentlyPlayingId == questId && _isplaying) {
      await _audioPlayer.pause();
      setState(() {
        _isplaying = false;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
      setState(() {
        _currentlyPlayingId = questId;
        _isplaying = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            const SizedBox(height: 18),
            const Text(
              "Biladi",
              style: TextStyle(
                color: Color(0xFF165B2E),
                fontSize: 50,
                fontWeight: FontWeight.w600,
                height: 0.9,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
            const SizedBox(height: 2.0),
            const Text(
              "Explore Algeria",
              style: TextStyle(
                color: Color(0xFF454543),
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24.0),


            QuestCard(
              id: "casbah_algiers",
              title: "Casbah of Algiers",
              location: "Algiers",
              imageurl: "assets/images/Casbah.jpg",
              gpsurl: "https://www.google.com/maps/search/?api=1&query=36.7833,3.0603",
              isCompleted: _completedQuests.contains("casbah_algiers"),
              isAudioPlaying: _currentlyPlayingId == "casbah_algiers" && _isplaying,
              onComplete: () => _toggleQuestCompletion("casbah_algiers"),
              onListen: () => _toggleAudio("casbah_algiers", "audio/Algeirs.mp3"),
            ),
            QuestCard(id: 'tipaza_mausoleum',
                title: 'Royal Mausoleum of Mauretania',
                location: 'Tipaza',
                imageurl: "assets/images/tipaza_mausoleum.jpg",
                gpsurl: 'https://www.google.com/maps/search/?api=1&query=36.365,6.614',
                isCompleted: _completedQuests.contains("tipaza_mausoleum"),
                isAudioPlaying: _currentlyPlayingId == "tipaza_mausoleum" && _isplaying,
                onComplete: () => _toggleQuestCompletion("tipaza_mausoleum"),
                onListen: () => _toggleAudio("tipaza_mausoleum", "audio/Tipaza.mp3")),
            QuestCard(id: 'constantine_bridges',
                title: "Sidi M'Cid Bridge",
                location: 'Constantine',
                imageurl: "assets/images/Bridges.jpg",
                gpsurl: 'https://www.google.com/maps/search/?api=1&query=36.365,6.614',
                isCompleted: _completedQuests.contains("constantine_bridges"),
                isAudioPlaying: _currentlyPlayingId == "constantine_bridges" && _isplaying,
                onComplete: () => _toggleQuestCompletion("constantine_bridges"),
                onListen: () => _toggleAudio("constantine_bridges", "audio/Constantine.mp3")),
            QuestCard(id: "sankoshi_pizza",
                title: "Sankoshi Pizza Cari",
                location: "Constantine",
                imageurl: "assets/images/sankoshi.jpg",
                gpsurl: 'https://www.google.com/maps/search/?api=1&query=36.3194,5.7367',
                isCompleted: _completedQuests.contains("sankoshi_pizza"),
                isAudioPlaying: _currentlyPlayingId == "sankoshi_pizza" && _isplaying,
                onComplete: () => _toggleQuestCompletion("sankoshi_pizza"),
                onListen: () => _toggleAudio("sankoshi_pizza", "audio/Sankoshi.mp3"),),
            QuestCard(id: 'djemila_ruins',
                title: 'Djemila Roman Ruins',
                location: 'Sétif',
                imageurl: "assets/images/Djemila.jpg",
                gpsurl: 'https://www.google.com/maps/search/?api=1&query=36.3194,5.7367',
                isCompleted: _completedQuests.contains("djemila_ruins"),
                isAudioPlaying: _currentlyPlayingId == "djemila_ruins" && _isplaying,
                onComplete: () => _toggleQuestCompletion("djemila_ruins"),
                onListen: () => _toggleAudio("djemila_ruins", "audio/setif.mp3"),),
            QuestCard(id: "oran_santacruz",
                title: "Fort Santa Cruz",
                location: "Oran"
                , imageurl: "assets/images/Santa cruz.jpg",
                gpsurl: "https://www.google.com/maps/search/?api=1&query=32.490,3.673",
                isCompleted: _completedQuests.contains("oran_santacruz"),
                isAudioPlaying: _currentlyPlayingId == "oran_santacruz" && _isplaying,
                onComplete: () => _toggleQuestCompletion("oran_santacruz"),
                onListen: () => _toggleAudio("oran_santacruz", "audio/Santa Cruz Fort.mp3")
            ),
            QuestCard(id: "timgad_batna",
                title: "Timgad Ruins",
                location: "Batna",
                imageurl: "assets/images/Timgad.jpg",
                gpsurl: "https://www.google.com/maps/search/?api=1&query=35.484,6.468",
                isCompleted: _completedQuests.contains("timgad_batna"),
                isAudioPlaying: _currentlyPlayingId == "timgad_batna" && _isplaying,
                onComplete: () => _toggleQuestCompletion("timgad_batna"),
                onListen: () => _toggleAudio("timgad_batna", "audio/Timgad.mp3")),
            QuestCard(id: "tlemcen_mechouar",
                title: "El Mechouar Palace",
                location: "Tlemcen",
                imageurl: "assets/images/El_Mechouar_Palace.jpg",
                gpsurl: "https://www.google.com/maps/search/?api=1&query=34.882,-1.314",
                isCompleted: _completedQuests.contains("tlemcen_mechouar"),
                isAudioPlaying: _currentlyPlayingId == "tlemcen_mechouar" && _isplaying,
                onComplete: () => _toggleQuestCompletion("tlemcen_mechouar"),
                onListen: () => _toggleAudio("tlemcen_mechouar", "audio/Tlemcen.mp3")),
            QuestCard(id: "mzab_ghardaia",
                title: "M'zab Valley",
                location: "Ghardaïa",
                imageurl: "assets/images/m_zab_ghardaia.jpg",
                gpsurl: "https://www.google.com/maps/search/?api=1&query=32.490,3.673",
                isCompleted: _completedQuests.contains("mzab_ghardaia"),
                isAudioPlaying: _currentlyPlayingId == "mzab_ghardaia" && _isplaying,
                onComplete: () => _toggleQuestCompletion("mzab_ghardaia"),
                onListen: () => _toggleAudio("mzab_ghardaia", "audio/ghardaia.mp3")),
            QuestCard(id: 'tassili_djanet',
                title: "Tassili n'Ajjer",
                location: 'Djanet',
                imageurl: "assets/images/Tassili.jpg",
                gpsurl: 'https://www.google.com/maps/search/?api=1&query=24.553,9.484',
                isCompleted: _completedQuests.contains("tassili_djanet"),
                isAudioPlaying: _currentlyPlayingId == "tassili_djanet" && _isplaying,
                onComplete: () => _toggleQuestCompletion("tassili_djanet"),
                onListen: () => _toggleAudio("tassili_djanet", "audio/Tassili.mp3")),


            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}