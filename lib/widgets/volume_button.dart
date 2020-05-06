import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:volume/volume.dart';

class VolumeButton extends StatefulWidget {
  VolumeButton({Key key}) : super(key: key);

  _VolumeButtonState createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<VolumeButton> {
  int maxVolume = 0;
  int currentVol = 0;
  int lastVol = 0;
  Timer volumeListener;

  @override
  void initState() {
    initAudioStreamType();
    SchedulerBinding.instance.addPostFrameCallback((_) => afterWidgetBuild());
    super.initState();
  }

  Future<void> initAudioStreamType() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  void afterWidgetBuild() async {
    maxVolume = await Volume.getMaxVol;
    getCurrentVolume();
    listenForVolumeChanges();
  }

  void getCurrentVolume() async {
    Future.microtask(() {
      Future.delayed(Duration(milliseconds: 250), () async {
        currentVol = await Volume.getVol;
        if (currentVol != lastVol) {
          setState(() {
            lastVol = currentVol;
          });
        }
      });
    });
  }

  void listenForVolumeChanges() {
    volumeListener = Timer.periodic(Duration(milliseconds: 1800), (_) {
      getCurrentVolume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(currentVol > 0 ? Icons.volume_up : Icons.volume_off,
          color: Colors.white),
      iconSize: 34.0,
      onPressed: () {
        setState(() {
          int volume = currentVol == 0 ? maxVolume : 0;
          Volume.setVol(volume, showVolumeUI: ShowVolumeUI.HIDE);
          currentVol = volume;
        });
      },
    );
  }

  @override
  void dispose() {
    if (volumeListener != null) {
      volumeListener.cancel();
    }
    super.dispose();
  }
}
