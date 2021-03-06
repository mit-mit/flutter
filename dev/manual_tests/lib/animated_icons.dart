// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class AnimatedIconsTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Animated Icons Test',
      home: const Scaffold(
        body: IconsList(),
      ),
    );
  }
}

class IconsList extends StatelessWidget {
  const IconsList();

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: samples.map((IconSample s) => new IconSampleRow(s)).toList(),
    );
  }
}

class IconSampleRow extends StatefulWidget {
  const IconSampleRow(this.sample);

  final IconSample sample;

  @override
  State createState() => new IconSampleRowState();
}

class IconSampleRowState extends State<IconSampleRow> with SingleTickerProviderStateMixin {
  AnimationController progress;

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new InkWell(
        onTap: () { progress.forward(from: 0.0); },
        child: new AnimatedIcon(
          icon: widget.sample.icon,
          progress: progress,
          color: Colors.lightBlue,
        ),
      ),
      title: new Text(widget.sample.description),
      subtitle: new Slider(
        value: progress.value,
        onChanged: (double v) { progress.animateTo(v, duration: Duration.zero); },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    progress = new AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    progress.addListener(_handleChange);
  }

  @override
  void dispose() {
    progress.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }
}

const List<IconSample> samples = <IconSample> [
  IconSample(AnimatedIcons.arrow_menu, 'arrow_menu'),
  IconSample(AnimatedIcons.menu_arrow, 'menu_arrow'),

  IconSample(AnimatedIcons.close_menu, 'close_menu'),
  IconSample(AnimatedIcons.menu_close, 'menu_close'),

  IconSample(AnimatedIcons.home_menu, 'home_menu'),
  IconSample(AnimatedIcons.menu_home, 'menu_home'),

  IconSample(AnimatedIcons.play_pause, 'play_pause'),
  IconSample(AnimatedIcons.pause_play, 'pause_play'),

  IconSample(AnimatedIcons.list_view, 'list_view'),
  IconSample(AnimatedIcons.view_list, 'view_list'),

  IconSample(AnimatedIcons.add_event, 'add_event'),
  IconSample(AnimatedIcons.event_add, 'event_add'),

  IconSample(AnimatedIcons.ellipsis_search, 'ellipsis_search'),
  IconSample(AnimatedIcons.search_ellipsis, 'search_ellipsis'),
];

class IconSample {
  const IconSample(this.icon, this.description);
  final AnimatedIconData icon;
  final String description;
}

void main() => runApp(new AnimatedIconsTestApp());
