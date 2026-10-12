# RRB JE CBT-1 Mock Test (Flutter)

Mock-test app built from `RRB_JE_CBT_1_Key_Hindi.pdf`:
7 shifts x 100 questions = **700 questions**, correct answers read from the key's green ticks.

## Run it
Requires Flutter 3.22 or newer (Dart 3.4+).

    cd prep_insta_test
    flutter create --project-name prep_insta .    # generates android/ ios/ etc. (keeps lib/ and pubspec.yaml)
    flutter pub get
    flutter run                                     # or: flutter build apk --release

## Features
- 7 full mock tests (one per exam shift) + "Quick practice" (25 random questions, 25 min)
- 90-minute countdown, auto-submit at 0:00
- Question palette (answered / not answered / marked / not visited), Mark for review, Clear response
- Marking: +1 correct, -1/3 wrong, 0 skipped
- Result screen with score, accuracy, time used and full answer review (filter: correct / wrong / skipped)
- Attempt history saved on the device (shared_preferences)
- Questions with fractions, tables or figures are shown as pictures cropped from the PDF; tap to zoom

## Data
- `assets/data/test_N.json` - questions: `n` number, `q` text, `o` 4 options, `a` correct option (0-3),
  `qi` optional question image, `oi` optional option images
- `assets/images/tN/` - cropped images
- `tools/` - the Python scripts used to extract everything (`parse1.py` then `build.py`; needs pdfplumber, pypdfium2, Pillow, poppler-utils)

## Known limitations
- The answer key has no explanations, so the review shows only the correct option.
- Text was extracted from the PDF; a few Hindi words that the PDF itself splits were repaired by rules,
  so a rare odd spacing may remain. If a question looks wrong, compare it with the PDF.
- Not compiled or run by the author (no Flutter SDK was available) - please run `flutter analyze` first.
