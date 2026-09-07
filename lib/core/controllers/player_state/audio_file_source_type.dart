part of 'player_state_controller.dart';

sealed class AudioFileSource {
  const AudioFileSource();

  bool isSome(AudioFileSource other) {
    return switch ((this, other)) {
      (NoneAudioSource(), NoneAudioSource()) => true,
      (AllFileStateSource(), AllFileStateSource()) => true,
      (FavouriteStateSource(), FavouriteStateSource()) => true,
      (LibStateSource(:final id), LibStateSource(id: final otherId)) =>
        id == otherId,
      _ => false,
    };
  }
}

class NoneAudioSource extends AudioFileSource {
  const NoneAudioSource();
}

class AllFileStateSource extends AudioFileSource {
  const AllFileStateSource();
}

class FavouriteStateSource extends AudioFileSource {
  const FavouriteStateSource();
}

class LibStateSource extends AudioFileSource {
  final String id;
  const LibStateSource(this.id);
}
