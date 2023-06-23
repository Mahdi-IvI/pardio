import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:pardio/config.dart';
import 'package:pardio/radio_item.dart';
import 'package:pardio/radio_model.dart';
import 'loading.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _radioPlayer = AudioPlayer();
  bool isPlaying = false;

  late Stream<List<RadioModel>> stream;

  @override
  void initState() {
    super.initState();
    stream = getAvailableRadios();
    initRadioPlayer();
  }

  Stream<List<RadioModel>> getAvailableRadios() {
    return Pardio.fireStore
        .collection(Pardio.radioCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RadioModel(
          id: doc.id,
          name: doc[Pardio.radioName],
          img: doc[Pardio.radioImage],
          url: doc[Pardio.radioUrl],
        );
      }).toList();
    });
  }

  static int _nextMediaId = 0;

  void initRadioPlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _radioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    setRadioChannel();
  }

  @override
  void dispose() {
    _radioPlayer.dispose();
    super.dispose();
  }

  final _playlist = ConcatenatingAudioSource(children: []);

  void setRadioChannel() async {
    getAvailableRadios().listen((value) {
      for (RadioModel ra in value) {
        _playlist.add(
          AudioSource.uri(
            Uri.parse(ra.url),
            tag: MediaItem(
              id: '${_nextMediaId++}',
              title: ra.name,
            ),
          ),
        );
      }
    });
    try {
      await _radioPlayer.setAudioSource(_playlist);
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
      print(stackTrace);
    }

   /* if (pageTitle != Pardio.appName) {
      _radioPlayer.stop();
    }*/

  /*  try {
      await _radioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: '${_nextMediaId++}',
            title: title,
          ),
        ),
      );
    } catch (e) {
      print("Error loading audio source: $e");
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      _radioPlayer.play();
    });*/
  }

  String pageTitle = Pardio.appName;
  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Colors.yellow,
            Colors.white,
            Colors.white,
            Colors.white,
          ],
        )),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<RadioModel>>(
                stream: stream,
                builder: (BuildContext context, radioSnapshot) {
                  if (radioSnapshot.hasError) {
                    return Center(child: Text(radioSnapshot.error.toString()));
                  }

                  if (radioSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: WhiteLoading());
                  }

                  return Column(
                    children: [
                      const SizedBox(
                        height: kToolbarHeight,
                      ),
                      Text(
                        pageTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: radioSnapshot.data!.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                _radioPlayer.seek(Duration.zero, index: index);
                                _radioPlayer.play();

                              /*  setRadioChannel(radioSnapshot.data![index].name,
                                    radioSnapshot.data![index].url);
                                setState(() {
                                  myIndex = index;
                                  pageTitle = radioSnapshot.data![index].name;
                                });*/
                              },
                              child: RadioItem(
                                model: radioSnapshot.data![index],
                                firstElement: index % 2 == 0 ? true : false,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 30),
                              child: StreamBuilder<IcyMetadata?>(
                                stream: _radioPlayer.icyMetadataStream,
                                builder: (context, snapshot) {
                                  final metadata = snapshot.data;
                                  final title = metadata?.info?.title ?? '';
                                  final url = metadata?.info?.url;
                                  return Column(
                                    children: [
                                      Text(title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _radioPlayer.hasPrevious ? _radioPlayer.seekToPrevious : null;
                                    /*if (myIndex == 0) {
                                      myIndex = radioSnapshot.data!.length - 1;
                                      setRadioChannel(
                                          radioSnapshot.data![myIndex].name,
                                          radioSnapshot.data![myIndex].url);
                                      setState(() {
                                        pageTitle =
                                            radioSnapshot.data![myIndex].name;
                                      });
                                    } else {
                                      myIndex--;
                                      setRadioChannel(
                                          radioSnapshot.data![myIndex].name,
                                          radioSnapshot.data![myIndex].url);
                                      setState(() {
                                        pageTitle =
                                            radioSnapshot.data![myIndex].name;
                                      });
                                    }*/
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: const Icon(
                                      Icons.skip_previous,
                                    ),
                                  ),
                                ),
                                StreamBuilder<PlayerState>(
                                  stream: _radioPlayer.playerStateStream,
                                  builder: (context, snapshot) {
                                    final playerState = snapshot.data;
                                    final processingState =
                                        playerState?.processingState;
                                    final playing = playerState?.playing;
                                    if (processingState ==
                                            ProcessingState.loading ||
                                        processingState ==
                                            ProcessingState.buffering) {
                                      return Container(
                                        margin: const EdgeInsets.all(8.0),
                                        width: 64.0,
                                        height: 64.0,
                                        child: const CircularProgressIndicator(
                                          color: Colors.black,
                                        ),
                                      );
                                    } else if (playing != true) {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.play_arrow_rounded,
                                          ),
                                          iconSize: 27,
                                          onPressed: () {

                                              _radioPlayer.play();

                                          },
                                        ),
                                      );
                                    } else if (processingState !=
                                        ProcessingState.completed) {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.pause,
                                          ),
                                          iconSize: 27,
                                          onPressed: () {
                                            _radioPlayer.pause();
                                          },
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.replay,
                                          ),
                                          iconSize: 27,
                                          onPressed: () {
                                            _radioPlayer.seek(Duration.zero,index:0);
                                          },
                                        ),
                                      );
                                    }
                                  },
                                ),
                                InkWell(
                                  onTap: () {
                                    _radioPlayer.hasNext ? _radioPlayer.seekToNext : null;
                                    /*if (myIndex ==
                                        radioSnapshot.data!.length - 1) {
                                      myIndex = 0;
                                      setRadioChannel(
                                          radioSnapshot.data![myIndex].name,
                                          radioSnapshot.data![myIndex].url);
                                      setState(() {
                                        pageTitle =
                                            radioSnapshot.data![myIndex].name;
                                      });
                                    } else {
                                      myIndex++;
                                      setRadioChannel(
                                          radioSnapshot.data![myIndex].name,
                                          radioSnapshot.data![myIndex].url);
                                      setState(() {
                                        pageTitle =
                                            radioSnapshot.data![myIndex].name;
                                      });
                                    }*/
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: const Icon(
                                      Icons.skip_next,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
