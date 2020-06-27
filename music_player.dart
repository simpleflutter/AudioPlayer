import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String fileName = 'No Audio Selected';
  String currentTime = '00:00';
  String endTime = '00:00';
  double min = 0.0, max = 0.0, curentValue = 0.0;
  bool isRepeat = false;
  String filePath;

  @override
  void initState() {
    super.initState();
    
    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentTime = duration.toString().split('.')[0];
        curentValue = duration.inSeconds.toDouble();
      });
    });

    audioPlayer.onDurationChanged.listen((Duration duartion) {
      setState(() {
        endTime = duartion.toString().split('.')[0];
        max = duartion.inSeconds.toDouble();
      });
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      if (isRepeat) {
        setState(() {
          audioPlayer.seek(Duration(seconds: 0));
          audioPlayer.play(filePath, isLocal: true);
          currentTime = '00:00';
          curentValue = 0.0;
          isPlaying = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey.shade300,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                fileName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                min: min,
                max: max,
                value: curentValue,
                onChanged: (double newValue) {
                  setState(() {
                    curentValue = newValue;
                    audioPlayer.seek(
                      Duration(
                        seconds: curentValue.toInt(),
                      ),
                    );
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(currentTime),
                  Text(endTime),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.music_note),
                    onPressed: () {
                      playAudio();
                    },
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      pauseResumeAudio();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () {
                      stopAudio();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color: isRepeat ? Colors.blue : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isRepeat = !isRepeat;
                      });
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void playAudio() async {
    String selectedPath = await FilePicker.getFilePath();

    if (selectedPath != null) {
      filePath = selectedPath;

      await audioPlayer.play(filePath, isLocal: true);
      setState(() {
        fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
        isPlaying = true;
      });
    }
  }

  void stopAudio() async {
    await audioPlayer.stop();
    setState(() {
      isPlaying = false;
      currentTime = '00:00:00';
      curentValue = 0.0;
    });
  }

  void pauseResumeAudio() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }
}
