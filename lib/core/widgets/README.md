# Custom Widgets Documentation

This directory contains reusable custom widgets for the Engliya app.

## Widgets

### CustomButton

A customizable button widget with press animations and multiple styles.

**Features:**
- Three button types: primary, secondary, outlined
- Press animation (scale effect)
- Loading state
- Optional icon
- Customizable size

**Usage:**
```dart
CustomButton(
  text: 'Continue',
  onPressed: () {
    // Handle press
  },
  type: ButtonType.primary,
  icon: Icons.arrow_forward,
)
```

### CustomProgressIndicator

An animated linear progress indicator with label.

**Features:**
- Smooth animation on progress changes
- Optional label showing current/total
- Customizable colors and height

**Usage:**
```dart
CustomProgressIndicator(
  current: 3,
  total: 6,
  showLabel: true,
  progressColor: AppTheme.primaryColor,
)
```

### CircularLessonProgress

A circular progress indicator for lesson completion.

**Features:**
- Smooth animation
- Customizable size and colors
- Can contain child widget (e.g., percentage text)

**Usage:**
```dart
CircularLessonProgress(
  progress: 0.75,
  size: 60,
  child: Text('75%'),
)
```

### StatusBadge

A badge widget to display lesson status.

**Features:**
- Four status types: locked, inProgress, mastered, completed
- Icon-only or icon+label display
- Consistent styling with app theme

**Usage:**
```dart
StatusBadge(
  status: BadgeStatus.mastered,
  showLabel: true,
)
```

### FeedbackBadge

An animated badge for showing correct/incorrect feedback.

**Features:**
- Fade and scale animation
- Auto-completes after animation
- Callback on completion

**Usage:**
```dart
FeedbackBadge(
  isCorrect: true,
  onComplete: () {
    // Handle completion
  },
)
```

### LessonCard

A card widget for displaying lesson information in the unit screen.

**Features:**
- Shows lesson number, title, description
- Status indicator (locked/in progress/mastered)
- Progress bar
- Tap handling

**Usage:**
```dart
LessonCard(
  lesson: lesson,
  status: userLessonStatus,
  isUnlocked: true,
  onTap: () {
    // Navigate to lesson
  },
)
```

## Animations

### AppAnimations

Utility class providing reusable animation helpers.

**Features:**
- Duration constants (fast, normal, medium, slow)
- Curve constants
- Helper methods for common transitions
- Custom page routes

**Usage:**
```dart
// Slide transition
AppAnimations.slideTransition(
  animation: animation,
  child: widget,
)

// Custom page route
Navigator.push(
  context,
  SlidePageRoute(page: NextScreen()),
)
```

### AnimatedListItem

A widget that animates list items with staggered entrance.

**Usage:**
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return AnimatedListItem(
      index: index,
      child: ListTile(title: Text('Item $index')),
    );
  },
)
```

### PulseAnimation

A widget that creates a pulsing scale animation.

**Usage:**
```dart
PulseAnimation(
  child: Icon(Icons.star),
)
```

## Icons

### AppIcons

Centralized icon definitions for consistent usage across the app.

**Categories:**
- Audio/Media: volumeUp, mic, play, pause
- Feedback: checkCircle, cancel, check, close
- Status: lock, playCircleOutline, star
- Navigation: arrowBack, arrowForward, home
- Actions: refresh, settings, info

**Usage:**
```dart
Icon(AppIcons.volumeUp)
Icon(AppIcons.mic)
Icon(AppIcons.checkCircle)
```

## Theme

### AppTheme

Centralized theme configuration with colors, text styles, and constants.

**Colors:**
- primaryColor: Green (#4CAF50)
- accentColor: Blue (#2196F3)
- correctColor: Green
- incorrectColor: Red
- lockedColor: Grey
- masteredColor: Gold

**Text Styles:**
- headline1, headline2, headline3: Large, bold headings
- bodyText1, bodyText2: Regular body text
- buttonText: Button text style
- caption: Small secondary text

**Constants:**
- Spacing: spacingXS, spacingS, spacingM, spacingL, spacingXL
- Border radius: radiusS, radiusM, radiusL, radiusXL
- Animation durations: animationFast, animationNormal, animationMedium, animationSlow

**Usage:**
```dart
Text(
  'Hello',
  style: AppTheme.headline2,
)

Container(
  padding: EdgeInsets.all(AppTheme.spacingM),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor,
    borderRadius: BorderRadius.circular(AppTheme.radiusM),
  ),
)
```

## Testing

To view all widgets in action, use the WidgetsShowcase screen:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WidgetsShowcase(),
  ),
)
```

This screen demonstrates all custom widgets, animations, and styling options.
