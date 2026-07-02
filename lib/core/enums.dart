enum SoundType {
  type4,
  type1,
  type2,
  type3;

  SoundType getNext() {
    switch (this) {
      case SoundType.type4:
        return SoundType.type1;
      case SoundType.type1:
        return SoundType.type2;
      case SoundType.type2:
        return SoundType.type3;
      case SoundType.type3:
        return SoundType.type4;
    }
  }
}
