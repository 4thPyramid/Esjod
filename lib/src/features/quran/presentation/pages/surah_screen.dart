import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:azkar/src/core/utils/core_theme.dart';
import 'package:azkar/src/core/utils/extentions.dart';
import 'package:azkar/src/features/quran/data/models/pin_model.dart';
import 'package:azkar/src/features/quran/presentation/widgets/audio_player.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/surah_model.dart';
import '../../domain/entities/surahs.dart';
import '../bloc/pin/bloc.dart';
import '../bloc/surah/bloc.dart';
import 'editions_list.dart';
import '../widgets/ayah_player.dart';
import '../../../../injection_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String defaultTranslationEdition = "quran-uthmani";
String defaultAudioEdition = "ar.alafasy";

class SurahScreen extends StatefulWidget {
  final ReferencesEntity ref;

  const SurahScreen({super.key, required this.ref});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  AssetsAudioPlayer? surahPlayer;
  Ayahs? selectedAyah;
  int? fontSize;
  // int page = 1;
  @override
  void initState() {
    surahPlayer = AudioP.player;
    super.initState();
  }

  String rType(String type) {
    return type == "Meccan" ? 'مكية' : "مدنية";
  }

  @override
  void dispose() {
    super.dispose();
    surahPlayer!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => sl<SurahBloc>()
        ..add((GetSurahEvent(
            number: widget.ref.number!,
            audioEdition: defaultAudioEdition,
            translationEdition: defaultTranslationEdition))),
      child: BlocBuilder<SurahBloc, SurahState>(builder: (context, surahState) {
        return StatefulBuilder(builder: (context, changeState) {
          return Scaffold(
              appBar: AppBar(
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(dSize.height * .09),
                  child: Column(
                    children: [
                      EditionsList(
                        number: widget.ref.number!,
                      ),
                      Material(
                        color: theme.colorScheme.secondary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if ((surahState is SurahLoadedState)) ...[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'الجزء ${surahState.surah.mainData!.ayahs!.first.juz}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'الصفحات ${surahState.surah.mainData!.ayahs!.first.page}-${surahState.surah.mainData!.ayahs!.last.page}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'الحزب ${surahState.surah.mainData!.ayahs!.first.hizbQuarter}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton(
                      isExpanded: false,
                      icon: const Center(),
                      value: fontSize,
                      underline: const Center(),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      dropdownColor: theme.primaryColor,
                      menuMaxHeight: dSize.height * .6,
                      hint: Text(
                        'حجم الخط',
                        style: theme.textTheme.titleMedium!
                            .copyWith(color: whiteColor),
                      ),
                      items: List.generate(
                          26,
                          (index) => DropdownMenuItem(
                              value: index + 25,
                              child: Text(
                                (index + 25).toString(),
                                style: theme.textTheme.titleLarge!
                                    .copyWith(color: whiteColor),
                              ))),
                      onChanged: (value) =>
                          changeState(() => fontSize = value!),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                      child: BlocProvider<PinBloc>(
                          create: (context) =>
                              sl<PinBloc>()..add(GetPinEvent()),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Header(
                                name: widget.ref.name!,
                              ),
                              5.ph,

                              ///
                              if (surahState is SurahLoadingState)
                                const AppIndicator(),
                              ////
                              if (surahState is SurahOfflineLoadedState)
                                Expanded(
                                    child: SingleChildScrollView(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: BlocBuilder<PinBloc, PinState>(
                                          builder: (context, pinState) {
                                        return RichText(
                                            textAlign: TextAlign.justify,
                                            text: TextSpan(
                                                children: surahState.surah
                                                    .map((ayah) => TextSpan(
                                                          text:
                                                              "${ayah['text']!} (${ayah['verse']!.toString()}) ",
                                                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize:
                                                                  (fontSize ?? 25)
                                                                      .toDouble(),
                                                              fontFamily:
                                                                  'HafsSmart',
                                                              backgroundColor: (pinState is PinLoadedState &&
                                                                      pinState.pin !=
                                                                          null &&
                                                                      pinState.pin!
                                                                              .ayah ==
                                                                          ayah[
                                                                              'verse'] &&
                                                                      pinState.pin!
                                                                              .surah ==
                                                                          widget
                                                                              .ref
                                                                              .number)
                                                                  ? theme
                                                                      .colorScheme
                                                                      .secondary
                                                                  : null,
                                                              height: 2.2),
                                                          recognizer:
                                                              TapGestureRecognizer(
                                                                  debugOwner: ayah[
                                                                      'verse'])
                                                                ..onTap =
                                                                    () async {
                                                                  if (pinState
                                                                      is PinLoadedState) {
                                                                    if (pinState.pin !=
                                                                            null &&
                                                                        pinState.pin!.ayah ==
                                                                            ayah[
                                                                                'verse'] &&
                                                                        widget.ref.number ==
                                                                            pinState.pin!.surah) {
                                                                      context
                                                                          .read<
                                                                              PinBloc>()
                                                                          .add(const SetPinEvent(
                                                                              PinModel()));
                                                                    } else {
                                                                      context.read<PinBloc>().add(SetPinEvent(PinModel(
                                                                          ayah: ayah[
                                                                              'verse'],
                                                                          surah: widget
                                                                              .ref
                                                                              .number,
                                                                          title: widget
                                                                              .ref
                                                                              .name)));
                                                                    }
                                                                  }
                                                                },
                                                        ))
                                                    .toList()));
                                      })),
                                )),

                              ///
                              if (surahState is SurahLoadedState)
                                Expanded(
                                    child: Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child:
                                              PlayerBuilder
                                                  .realtimePlayingInfos(
                                                      player: surahPlayer!,
                                                      builder:
                                                          (context, current) {
                                                        return BlocBuilder<
                                                                PinBloc,
                                                                PinState>(
                                                            builder: (context,
                                                                pinState) {
                                                          return RichText(
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                              text: TextSpan(
                                                                  children: surahState
                                                                      .surah
                                                                      .translationData!
                                                                      .ayahs!
                                                                      .map((ayah) =>
                                                                          TextSpan(
                                                                            text:
                                                                                "${ayah.text!} (${ayah.numberInSurah!.toString()}) ",
                                                                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                                                                fontWeight: FontWeight.normal,
                                                                                backgroundColor: surahPlayer != null && current.isPlaying && current.current!.playlist.audios.isNotEmpty && ayah.number.toString() == current.current!.audio.audio.metas.id
                                                                                    ? Colors.lightGreen.withOpacity(.5)
                                                                                    : (pinState is PinLoadedState && pinState.pin != null && pinState.pin!.ayah == ayah.numberInSurah && pinState.pin!.surah == widget.ref.number)
                                                                                        ? theme.colorScheme.secondary
                                                                                        : null,
                                                                                fontFamily: 'HafsSmart',
                                                                                fontSize: (fontSize ?? 25).toDouble(),
                                                                                height: 2.2),
                                                                            recognizer: TapGestureRecognizer(debugOwner: surahState.surah.mainData!.number)
                                                                              ..onTap = () async {
                                                                                selectedAyah = ayah;
                                                                                if (current.isBuffering || current.current != null && current.current!.index == ayah.numberInSurah! - 1) return;
                                                                                await surahPlayer!.playlistPlayAtIndex(ayah.numberInSurah! - 1);
                                                                              },
                                                                          ))
                                                                      .toList()));
                                                        });
                                                      }),
                                        ),
                                      ),
                                    ),
                                    BlocBuilder<PinBloc, PinState>(
                                        builder: (context, pinState) {
                                      return AyahPlayer(
                                        pinning: () async {
                                          if (selectedAyah == null) {
                                            return;
                                          }
                                          if (pinState is PinLoadedState) {
                                            if (pinState.pin != null &&
                                                pinState.pin!.ayah ==
                                                    selectedAyah!
                                                        .numberInSurah &&
                                                widget.ref.number ==
                                                    pinState.pin!.surah) {
                                              context.read<PinBloc>().add(
                                                  const SetPinEvent(
                                                      PinModel()));
                                            } else {
                                              context.read<PinBloc>().add(
                                                  SetPinEvent(PinModel(
                                                      ayah: selectedAyah!
                                                          .numberInSurah,
                                                      surah: widget.ref.number,
                                                      title: widget.ref.name)));
                                            }
                                          }
                                        },
                                        audioPlayer: surahPlayer!
                                          ..open(
                                              Playlist(
                                                  audios: surahState
                                                      .surah.audioData!.ayahs!
                                                      .map((e) => Audio.network(
                                                          e.audio!,
                                                          metas: Metas(
                                                              title: e.text,
                                                              id: e.number
                                                                  .toString())))
                                                      .toList()),
                                              autoStart: false,
                                              seek: Duration.zero,
                                              loopMode: LoopMode.playlist),
                                      );
                                    })
                                  ],
                                ))
                            ],
                          ))),
                ],
              ));
        });
      }),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    final dSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(), top: BorderSide())),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            "assets/images/title-r.png",
            height: dSize.height * 0.05,
            color: theme.colorScheme.primary,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  name,
                  style: theme.textTheme.titleLarge!
                      .copyWith(fontFamily: "HafsSmart"),
                ),
              ),
            ),
          ),
          Image.asset(
            "assets/images/title-l.png",
            height: dSize.height * 0.05,
            color: theme.colorScheme.primary,
          )
        ],
      ),
    );
  }
}
