import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../../providers/app_providers.dart';

import 'activities/learning_activity_panel.dart';

import 'learn/animated_learn_panel.dart';

import 'unit_quiz_panel.dart';



class UnitDetailScreen extends ConsumerStatefulWidget {

  const UnitDetailScreen({super.key, required this.unitId});



  final String unitId;



  @override

  ConsumerState<UnitDetailScreen> createState() => _UnitDetailScreenState();

}



class _UnitDetailScreenState extends ConsumerState<UnitDetailScreen>

    with SingleTickerProviderStateMixin {

  late TabController _tabs;



  @override

  void initState() {

    super.initState();

    _tabs = TabController(length: 3, vsync: this);

    _tabs.addListener(() {

      if (!_tabs.indexIsChanging) setState(() {});

    });

  }



  @override

  void dispose() {

    _tabs.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    final repo = ref.read(learningRepositoryProvider);

    final unit = repo.getUnit(widget.unitId);

    if (unit == null) {

      return Scaffold(

        appBar: AppBar(title: const Text('Unit')),

        body: const Center(child: Text('Unit not found')),

      );

    }



    final showInterviewFab = _tabs.index == 0;



    return Scaffold(

      appBar: AppBar(

        title: Text(unit.title),

        bottom: TabBar(

          controller: _tabs,

          tabs: const [

            Tab(text: 'Learn'),

            Tab(text: 'Activity'),

            Tab(text: 'Quiz'),

          ],

        ),

      ),

      body: TabBarView(

        controller: _tabs,

        children: [

          SingleChildScrollView(

            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),

            child: AnimatedLearnPanel(unitId: widget.unitId),

          ),

          LearningActivityPanel(unitId: widget.unitId),

          UnitQuizPanel(unitId: widget.unitId),

        ],

      ),

      floatingActionButton: showInterviewFab

          ? FloatingActionButton.extended(

              onPressed: () => context.push('/interview'),

              label: const Text('Practice in Interview'),

              icon: const Icon(Icons.mic),

            )

          : null,

    );

  }

}

