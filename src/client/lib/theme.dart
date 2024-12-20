import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282998162),
      surfaceTint: Color(4282998162),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292535039),
      onPrimaryContainer: Color(4278196296),
      secondary: Color(4283981425),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292666105),
      onSecondaryContainer: Color(4279573292),
      tertiary: Color(4285748337),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294891513),
      onTertiaryContainer: Color(4281012779),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294637823),
      onSurface: Color(4279900961),
      onSurfaceVariant: Color(4282730063),
      outline: Color(4285888384),
      outlineVariant: Color(4291151568),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inversePrimary: Color(4289906175),
      primaryFixed: Color(4292535039),
      onPrimaryFixed: Color(4278196296),
      primaryFixedDim: Color(4289906175),
      onPrimaryFixedVariant: Color(4281353592),
      secondaryFixed: Color(4292666105),
      onSecondaryFixed: Color(4279573292),
      secondaryFixedDim: Color(4290823901),
      onSecondaryFixedVariant: Color(4282402393),
      tertiaryFixed: Color(4294891513),
      onTertiaryFixed: Color(4281012779),
      tertiaryFixedDim: Color(4292983772),
      onTertiaryFixedVariant: Color(4284104025),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293124841),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4281090420),
      surfaceTint: Color(4282998162),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284445610),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282139221),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285428872),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4283775317),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287326856),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294637823),
      onSurface: Color(4279900961),
      onSurfaceVariant: Color(4282466891),
      outline: Color(4284309351),
      outlineVariant: Color(4286151299),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inversePrimary: Color(4289906175),
      primaryFixed: Color(4284445610),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282800783),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285428872),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283849583),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4287326856),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4285551215),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293124841),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278525777),
      surfaceTint: Color(4282998162),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281090420),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280033843),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282139221),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281473330),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4283775317),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294637823),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280427563),
      outline: Color(4282466891),
      outlineVariant: Color(4282466891),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281282614),
      inversePrimary: Color(4293389311),
      primaryFixed: Color(4281090420),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279446108),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282139221),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280691774),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4283775317),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282262589),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292532704),
      surfaceBright: Color(4294637823),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294243322),
      surfaceContainer: Color(4293848564),
      surfaceContainerHigh: Color(4293453807),
      surfaceContainerHighest: Color(4293124841),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289906175),
      surfaceTint: Color(4289906175),
      onPrimary: Color(4279774816),
      primaryContainer: Color(4281353592),
      onPrimaryContainer: Color(4292535039),
      secondary: Color(4290823901),
      onSecondary: Color(4280954946),
      secondaryContainer: Color(4282402393),
      onSecondaryContainer: Color(4292666105),
      tertiary: Color(4292983772),
      onTertiary: Color(4282525505),
      tertiaryContainer: Color(4284104025),
      onTertiaryContainer: Color(4294891513),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279374616),
      onSurface: Color(4293124841),
      onSurfaceVariant: Color(4291151568),
      outline: Color(4287598746),
      outlineVariant: Color(4282730063),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124841),
      inversePrimary: Color(4282998162),
      primaryFixed: Color(4292535039),
      onPrimaryFixed: Color(4278196296),
      primaryFixedDim: Color(4289906175),
      onPrimaryFixedVariant: Color(4281353592),
      secondaryFixed: Color(4292666105),
      onSecondaryFixed: Color(4279573292),
      secondaryFixedDim: Color(4290823901),
      onSecondaryFixedVariant: Color(4282402393),
      tertiaryFixed: Color(4294891513),
      onTertiaryFixed: Color(4281012779),
      tertiaryFixedDim: Color(4292983772),
      onTertiaryFixedVariant: Color(4284104025),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281545786),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4290300671),
      surfaceTint: Color(4289906175),
      onPrimary: Color(4278195005),
      primaryContainer: Color(4286287816),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4291152609),
      onSecondary: Color(4279244326),
      secondaryContainer: Color(4287271077),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293246945),
      onTertiary: Color(4280618278),
      tertiaryContainer: Color(4289234597),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279374616),
      onSurface: Color(4294769407),
      onSurfaceVariant: Color(4291414740),
      outline: Color(4288783020),
      outlineVariant: Color(4286677900),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124841),
      inversePrimary: Color(4281484922),
      primaryFixed: Color(4292535039),
      onPrimaryFixed: Color(4278193970),
      primaryFixedDim: Color(4289906175),
      onPrimaryFixedVariant: Color(4280169574),
      secondaryFixed: Color(4292666105),
      onSecondaryFixed: Color(4278849825),
      secondaryFixedDim: Color(4290823901),
      onSecondaryFixedVariant: Color(4281349704),
      tertiaryFixed: Color(4294891513),
      onTertiaryFixed: Color(4280223776),
      tertiaryFixedDim: Color(4292983772),
      onTertiaryFixedVariant: Color(4282920263),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281545786),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294769407),
      surfaceTint: Color(4289906175),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4290300671),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294769407),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4291152609),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4293246945),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279374616),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294769407),
      outline: Color(4291414740),
      outlineVariant: Color(4291414740),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293124841),
      inversePrimary: Color(4279248730),
      primaryFixed: Color(4292929279),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4290300671),
      onPrimaryFixedVariant: Color(4278195005),
      secondaryFixed: Color(4292994814),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4291152609),
      onSecondaryFixedVariant: Color(4279244326),
      tertiaryFixed: Color(4294958586),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4293246945),
      onTertiaryFixedVariant: Color(4280618278),
      surfaceDim: Color(4279374616),
      surfaceBright: Color(4281874751),
      surfaceContainerLowest: Color(4279045651),
      surfaceContainerLow: Color(4279900961),
      surfaceContainer: Color(4280164133),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281545786),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
