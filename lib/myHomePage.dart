import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pardio/config.dart';
import 'package:pardio/radio_item.dart';
import 'package:pardio/radio_model.dart';
import 'package:radio_player/radio_player.dart';

import 'loading.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final RadioPlayer _radioPlayer = RadioPlayer();
  bool isPlaying = false;
  List<String>? metadata;

  late Future<List<RadioModel>> future;

  @override
  void initState() {
    super.initState();
    future = getAvailableRadios();
    initRadioPlayer();
  }



  Future<List<RadioModel>> getAvailableRadios() {
    return Pardio.fireStore
        .collection(Pardio.radioCollection)
        .get()
        .then((value) {
      return value.docs.map((doc) {
        return RadioModel(
          id: doc.id,
          name: doc[Pardio.radioName],
          img: doc[Pardio.radioImage],
          url: doc[Pardio.radioUrl],
        );
      }).toList();
    });
  }

  void initRadioPlayer() {
       _radioPlayer.setDefaultArtwork("assets/icon.png");
    _radioPlayer.stateStream.listen((value) {
      setState(() {
        isPlaying = value;
      });
    });

    _radioPlayer.metadataStream.listen((value) {
      setState(() {
        metadata = value;
        if (kDebugMode) {
          print(metadata);
        }
      });
    });
  }

   void setRadioChannel(String title, String url) {
    _radioPlayer.stop();
    _radioPlayer.setChannel(
      title: title,
      url: url,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      _radioPlayer.play();
    });
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
              child: FutureBuilder<List<RadioModel>>(
                future: future,
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
                                setRadioChannel(radioSnapshot.data![index].name,
                                    radioSnapshot.data![index].url);
                                setState(() {
                                  myIndex = index;
                                  pageTitle = radioSnapshot.data![index].name;
                                });
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
                                child: Text(
                                  metadata != null
                                      ? "${metadata![0]} - ${metadata![1]}"
                                      : "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (myIndex == 0) {
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
                                    }
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
                                InkWell(
                                  onTap: () {
                                    if (metadata == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Please choose a Radio")));
                                    } else {
                                      isPlaying
                                          ? _radioPlayer.pause()
                                          : _radioPlayer.play();
                                    }


                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Icon(
                                      isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 27,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (myIndex ==
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
                                    }
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
